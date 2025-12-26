package radim.ma.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import radim.ma.config.TestSecurityConfig;
import radim.ma.dto.CreditDto;
import radim.ma.security.JwtUtil;
import radim.ma.services.CreditService;

import java.math.BigDecimal;
import org.springframework.context.annotation.Import;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
// Removed unused imports
// Removed unused import
// Removed unused import

@WebMvcTest(CreditController.class)
@Import(TestSecurityConfig.class)
class CreditControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CreditService creditService;

    @MockBean
    private JwtUtil jwtUtil;

    // JwtFilter and AuthenticationProvider removed as they are not needed with
    // TestSecurityConfig

    private CreditDto.CreditBalanceResponse balanceResponse;
    private CreditDto.UpdateCreditRequest updateRequest;
    private CreditDto.DeductCreditRequest deductRequest;

    @BeforeEach
    void setUp() {
        balanceResponse = CreditDto.CreditBalanceResponse.builder()
                .userId(1L)
                .balance(BigDecimal.valueOf(100))
                .build();

        updateRequest = new CreditDto.UpdateCreditRequest();
        updateRequest.setStudentId(1L);
        updateRequest.setAmount(BigDecimal.valueOf(50));

        deductRequest = new CreditDto.DeductCreditRequest();
        deductRequest.setAmount(10.0);

    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetMyBalance_ValidToken_ReturnsBalance() throws Exception {
        // Given
        when(jwtUtil.extractClaim(anyString(), any())).thenReturn(1L);
        when(creditService.getBalance(1L)).thenReturn(balanceResponse);

        // When & Then
        mockMvc.perform(get("/api/credits/balance")
                .header("Authorization", "Bearer valid.jwt.token")
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1))
                .andExpect(jsonPath("$.balance").value(100));

        verify(creditService).getBalance(1L);
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    void testGetStudentBalance_AsTeacher_ReturnsBalance() throws Exception {
        // Given
        when(creditService.getBalance(1L)).thenReturn(balanceResponse);

        // When & Then
        mockMvc.perform(get("/api/credits/student/1")
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1))
                .andExpect(jsonPath("$.balance").value(100));

        verify(creditService).getBalance(1L);
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetStudentBalance_AsStudent_ThrowsAccessDenied() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/credits/student/1")
                .with(csrf()))
                .andExpect(status().isForbidden());

        verify(creditService, never()).getBalance(anyLong());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    void testUpdateCredits_AsTeacher_UpdatesSuccessfully() throws Exception {
        // Given
        doNothing().when(creditService).updateCredits(anyLong(), any(BigDecimal.class));

        // When & Then
        mockMvc.perform(post("/api/credits/update")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(content().string("Credits updated successfully"));

        verify(creditService).updateCredits(1L, BigDecimal.valueOf(50));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testUpdateCredits_AsStudent_ThrowsAccessDenied() throws Exception {
        // When & Then
        mockMvc.perform(post("/api/credits/update")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(csrf()))
                .andExpect(status().isForbidden());

        verify(creditService, never()).updateCredits(anyLong(), any(BigDecimal.class));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testRewardLessonComplete_ValidRequest_AddsCredits() throws Exception {
        // Given
        when(jwtUtil.extractClaim(anyString(), any())).thenReturn(1L);
        when(creditService.getBalance(1L)).thenReturn(balanceResponse);
        doNothing().when(creditService).updateCredits(anyLong(), any(BigDecimal.class));

        // When & Then
        mockMvc.perform(post("/api/credits/reward/lesson-complete")
                .header("Authorization", "Bearer valid.jwt.token")
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1))
                .andExpect(jsonPath("$.balance").value(100));

        verify(creditService).updateCredits(1L, BigDecimal.valueOf(5));
        verify(creditService).getBalance(1L);
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testDeductCredits_SufficientBalance_DeductsSuccessfully() throws Exception {
        // Given
        when(jwtUtil.extractClaim(anyString(), any())).thenReturn(1L);
        when(creditService.getBalance(1L)).thenReturn(balanceResponse);
        doNothing().when(creditService).updateCredits(anyLong(), any(BigDecimal.class));

        // When & Then
        mockMvc.perform(post("/api/credits/deduct")
                .header("Authorization", "Bearer valid.jwt.token")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(deductRequest))
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1));

        verify(creditService).updateCredits(1L, BigDecimal.valueOf(-10.0));
        verify(creditService).getBalance(1L);
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testDeductCredits_InsufficientBalance_ThrowsException() throws Exception {
        // Given
        when(jwtUtil.extractClaim(anyString(), any())).thenReturn(1L);
        doThrow(new RuntimeException("Insufficient credits"))
                .when(creditService).updateCredits(anyLong(), any(BigDecimal.class));

        // When & Then
        mockMvc.perform(post("/api/credits/deduct")
                .header("Authorization", "Bearer valid.jwt.token")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(deductRequest))
                .with(csrf()))
                .andExpect(status().is4xxClientError());

        verify(creditService).updateCredits(eq(1L), any(BigDecimal.class));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetMyBalance_NoAuthHeader_ThrowsException() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/credits/balance")
                .with(csrf()))
                .andExpect(status().is4xxClientError());

        verify(creditService, never()).getBalance(anyLong());
    }

    @Test
    @WithMockUser(roles = "TEACHER")
    void testUpdateCredits_NegativeAmount_DeductsCredits() throws Exception {
        // Given
        updateRequest.setAmount(BigDecimal.valueOf(-20));
        doNothing().when(creditService).updateCredits(anyLong(), any(BigDecimal.class));

        // When & Then
        mockMvc.perform(post("/api/credits/update")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest))
                .with(csrf()))
                .andExpect(status().isOk());

        verify(creditService).updateCredits(1L, BigDecimal.valueOf(-20));
    }
}
