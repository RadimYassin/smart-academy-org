package com.radim.project.service;

import com.radim.project.dto.LessonDto;
import com.radim.project.entity.*;
import com.radim.project.repository.LessonRepository;
import com.radim.project.repository.ModuleRepository;
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
class LessonServiceTest {

    @Mock
    private LessonRepository lessonRepository;
    @Mock
    private ModuleRepository moduleRepository;

    @InjectMocks
    private LessonService lessonService;

    private MockedStatic<SecurityContextHolder> mockedSecurityContextHolder;
    private Long teacherId;
    private UUID moduleId;
    private com.radim.project.entity.Module module;

    @BeforeEach
    void setUp() {
        teacherId = 1L;
        moduleId = UUID.randomUUID();

        Course course = Course.builder().teacherId(teacherId).build();
        module = com.radim.project.entity.Module.builder().id(moduleId).course(course).build();

        mockedSecurityContextHolder = mockStatic(SecurityContextHolder.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        Authentication authentication = mock(Authentication.class);

        mockedSecurityContextHolder.when(SecurityContextHolder::getContext).thenReturn(securityContext);
        lenient().when(securityContext.getAuthentication()).thenReturn(authentication);
        lenient().when(authentication.getPrincipal()).thenReturn(teacherId.toString());
        lenient().doReturn(List.of(new SimpleGrantedAuthority("ROLE_TEACHER"))).when(authentication).getAuthorities();
    }

    @AfterEach
    void tearDown() {
        mockedSecurityContextHolder.close();
    }

    @Test
    void createLesson_ShouldSuccess() {
        when(moduleRepository.findById(moduleId)).thenReturn(Optional.of(module));

        LessonDto.Request request = LessonDto.Request.builder()
                .title("New Lesson")
                .summary("Summary")
                .orderIndex(1)
                .build();

        Lesson lesson = Lesson.builder()
                .id(UUID.randomUUID())
                .module(module)
                .title(request.getTitle())
                .build();

        when(lessonRepository.save(any(Lesson.class))).thenReturn(lesson);

        LessonDto.Response response = lessonService.createLesson(moduleId, request);

        assertThat(response).isNotNull();
        assertThat(response.getTitle()).isEqualTo("New Lesson");
    }

    @Test
    void updateLesson_ShouldSuccess() {
        UUID lessonId = UUID.randomUUID();
        Lesson existingLesson = Lesson.builder()
                .id(lessonId)
                .module(module)
                .title("Old Title")
                .build();

        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(existingLesson));

        LessonDto.Request request = LessonDto.Request.builder().title("New Title").build();

        when(lessonRepository.save(any(Lesson.class))).thenReturn(existingLesson);

        LessonDto.Response response = lessonService.updateLesson(moduleId, lessonId, request);

        assertThat(response.getTitle()).isEqualTo("New Title");
    }

    @Test
    void deleteLesson_ShouldSuccess() {
        UUID lessonId = UUID.randomUUID();
        Lesson existingLesson = Lesson.builder()
                .id(lessonId)
                .module(module)
                .build();

        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(existingLesson));

        lessonService.deleteLesson(moduleId, lessonId);

        verify(lessonRepository).delete(existingLesson);
    }

    @Test
    void updateLesson_ShouldThrowException_WhenModuleMismatch() {
        UUID lessonId = UUID.randomUUID();
        com.radim.project.entity.Module otherModule = com.radim.project.entity.Module.builder().id(UUID.randomUUID())
                .build();
        Lesson existingLesson = Lesson.builder()
                .id(lessonId)
                .module(otherModule)
                .build();

        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(existingLesson));

        LessonDto.Request request = LessonDto.Request.builder().title("Title").build();

        assertThatThrownBy(() -> lessonService.updateLesson(moduleId, lessonId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("does not belong to the specified module");
    }
}
