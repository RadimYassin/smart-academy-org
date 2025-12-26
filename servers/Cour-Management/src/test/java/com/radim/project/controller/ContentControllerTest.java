package com.radim.project.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.radim.project.dto.ContentDto;
import com.radim.project.entity.enums.ContentType;
import com.radim.project.service.ContentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.radim.project.config.TestSecurityConfig;
import com.radim.project.security.JwtAuthenticationFilter;
import com.radim.project.security.SecurityConfig;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;

@WebMvcTest(controllers = ContentController.class, excludeFilters = {
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = SecurityConfig.class),
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = JwtAuthenticationFilter.class)
})
@Import(TestSecurityConfig.class)
class ContentControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @Autowired
        private ObjectMapper objectMapper;

        @MockBean
        private ContentService contentService;

        private UUID lessonId;
        private UUID contentId;
        private ContentDto.Request contentRequest;
        private ContentDto.Response contentResponse;

        @BeforeEach
        void setUp() {
                lessonId = UUID.randomUUID();
                contentId = UUID.randomUUID();

                contentRequest = new ContentDto.Request();
                contentRequest.setType(ContentType.VIDEO);
                contentRequest.setVideoUrl("https://example.com/video.mp4");
                contentRequest.setOrderIndex(1);

                contentResponse = new ContentDto.Response();
                contentResponse.setId(contentId);
                contentResponse.setType(ContentType.VIDEO);
                contentResponse.setVideoUrl("https://example.com/video.mp4");
                contentResponse.setOrderIndex(1);
        }

        @Test
        @WithMockUser
        void testGetContent_ValidLessonId_ReturnsContentList() throws Exception {
                // Given
                List<ContentDto.Response> contentList = Arrays.asList(contentResponse);
                when(contentService.getContentByLesson(lessonId)).thenReturn(contentList);

                // When & Then
                mockMvc.perform(get("/lessons/{lessonId}/content", lessonId)
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(contentId.toString()))
                                .andExpect(jsonPath("$[0].type").value("VIDEO"));

                verify(contentService).getContentByLesson(lessonId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testCreateContent_ValidData_CreatesSuccessfully() throws Exception {
                // Given
                when(contentService.createContent(eq(lessonId), any(ContentDto.Request.class)))
                                .thenReturn(contentResponse);

                // When & Then
                mockMvc.perform(post("/lessons/{lessonId}/content", lessonId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.id").value(contentId.toString()));

                verify(contentService).createContent(eq(lessonId), any(ContentDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        void testCreateContent_AsStudent_ThrowsAccessDenied() throws Exception {
                // When & Then
                mockMvc.perform(post("/lessons/{lessonId}/content", lessonId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().isForbidden());

                verify(contentService, never()).createContent(any(UUID.class), any(ContentDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testUpdateContent_ValidData_UpdatesSuccessfully() throws Exception {
                // Given
                when(contentService.updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class)))
                                .thenReturn(contentResponse);

                // When & Then
                mockMvc.perform(put("/lessons/{lessonId}/content/{contentId}", lessonId, contentId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(contentId.toString()));

                verify(contentService).updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        void testUpdateContent_AsAdmin_UpdatesSuccessfully() throws Exception {
                // Given
                when(contentService.updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class)))
                                .thenReturn(contentResponse);

                // When & Then
                mockMvc.perform(put("/lessons/{lessonId}/content/{contentId}", lessonId, contentId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().isOk());

                verify(contentService).updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testDeleteContent_ValidId_DeletesSuccessfully() throws Exception {
                // Given
                doNothing().when(contentService).deleteContent(lessonId, contentId);

                // When & Then
                mockMvc.perform(delete("/lessons/{lessonId}/content/{contentId}", lessonId, contentId)
                                .with(csrf()))
                                .andExpect(status().isNoContent());

                verify(contentService).deleteContent(lessonId, contentId);
        }

        @Test
        @WithMockUser(roles = "STUDENT")
        void testDeleteContent_AsStudent_ThrowsAccessDenied() throws Exception {
                // When & Then
                mockMvc.perform(delete("/lessons/{lessonId}/content/{contentId}", lessonId, contentId)
                                .with(csrf()))
                                .andExpect(status().isForbidden());

                verify(contentService, never()).deleteContent(any(UUID.class), any(UUID.class));
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testCreateContent_InvalidData_ReturnsBadRequest() throws Exception {
                // Given - missing required fields
                // Given - missing required fields
                contentRequest.setType(null);

                // When & Then
                mockMvc.perform(post("/lessons/{lessonId}/content", lessonId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().isBadRequest());

                verify(contentService, never()).createContent(any(UUID.class), any(ContentDto.Request.class));
        }

        @Test
        @WithMockUser
        void testGetContent_EmptyList_ReturnsEmptyArray() throws Exception {
                // Given
                when(contentService.getContentByLesson(lessonId)).thenReturn(Arrays.asList());

                // When & Then
                mockMvc.perform(get("/lessons/{lessonId}/content", lessonId)
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$").isArray())
                                .andExpect(jsonPath("$").isEmpty());

                verify(contentService).getContentByLesson(lessonId);
        }

        @Test
        @WithMockUser(roles = "TEACHER")
        void testUpdateContent_NonExistentContent_ThrowsException() throws Exception {
                // Given
                when(contentService.updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class)))
                                .thenThrow(new RuntimeException("Content not found"));

                // When & Then
                mockMvc.perform(put("/lessons/{lessonId}/content/{contentId}", lessonId, contentId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(contentRequest))
                                .with(csrf()))
                                .andExpect(status().is4xxClientError());

                verify(contentService).updateContent(eq(lessonId), eq(contentId), any(ContentDto.Request.class));
        }
}
