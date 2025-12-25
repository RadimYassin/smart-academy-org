package com.radim.project.service;

import com.radim.project.dto.QuizDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.Quiz;
import com.radim.project.entity.enums.QuizDifficulty;
import com.radim.project.repository.CourseRepository;
import com.radim.project.repository.QuizRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class QuizServiceTest {

    @Mock
    private QuizRepository quizRepository;
    @Mock
    private CourseRepository courseRepository;

    @InjectMocks
    private QuizService quizService;

    private MockedStatic<SecurityContextHolder> mockedSecurityContextHolder;
    private Long teacherId;
    private UUID courseId;
    private Course course;

    @BeforeEach
    void setUp() {
        teacherId = 1L;
        courseId = UUID.randomUUID();

        course = Course.builder().id(courseId).teacherId(teacherId).build();

        mockedSecurityContextHolder = mockStatic(SecurityContextHolder.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        Authentication authentication = mock(Authentication.class);

        mockedSecurityContextHolder.when(SecurityContextHolder::getContext).thenReturn(securityContext);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getPrincipal()).thenReturn(teacherId.toString());
        doReturn(List.of(new SimpleGrantedAuthority("ROLE_TEACHER"))).when(authentication).getAuthorities();
    }

    @AfterEach
    void tearDown() {
        mockedSecurityContextHolder.close();
    }

    @Test
    void createQuiz_ShouldSuccess() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));

        QuizDto.Request request = QuizDto.Request.builder()
                .title("Final Quiz")
                .description("Description")
                .difficulty(QuizDifficulty.MEDIUM)
                .build();

        Quiz quiz = Quiz.builder()
                .id(UUID.randomUUID())
                .course(course)
                .title(request.getTitle())
                .build();

        when(quizRepository.save(any(Quiz.class))).thenReturn(quiz);

        QuizDto.Response response = quizService.createQuiz(courseId, request);

        assertThat(response).isNotNull();
        assertThat(response.getTitle()).isEqualTo("Final Quiz");
    }
}
