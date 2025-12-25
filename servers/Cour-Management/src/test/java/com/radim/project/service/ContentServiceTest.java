package com.radim.project.service;

import com.radim.project.dto.ContentDto;
import com.radim.project.entity.*;
import com.radim.project.repository.LessonContentRepository;
import com.radim.project.repository.LessonRepository;
import com.radim.project.entity.enums.ContentType;
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
class ContentServiceTest {

    @Mock
    private LessonContentRepository contentRepository;
    @Mock
    private LessonRepository lessonRepository;

    @InjectMocks
    private ContentService contentService;

    private MockedStatic<SecurityContextHolder> mockedSecurityContextHolder;
    private Long teacherId;
    private UUID lessonId;
    private Lesson lesson;

    @BeforeEach
    void setUp() {
        teacherId = 1L;
        lessonId = UUID.randomUUID();

        Course course = Course.builder().teacherId(teacherId).build();
        com.radim.project.entity.Module module = com.radim.project.entity.Module.builder().course(course).build();
        lesson = Lesson.builder().id(lessonId).module(module).build();

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
    void createContent_ShouldSuccess_WhenPdfAndValid() {
        when(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson));

        ContentDto.Request request = ContentDto.Request.builder()
                .type(ContentType.PDF)
                .pdfUrl("http://example.com/file.pdf")
                .orderIndex(1)
                .build();

        LessonContent content = LessonContent.builder()
                .id(UUID.randomUUID())
                .lesson(lesson)
                .type(ContentType.PDF)
                .pdfUrl(request.getPdfUrl())
                .build();

        when(contentRepository.save(any(LessonContent.class))).thenReturn(content);

        ContentDto.Response response = contentService.createContent(lessonId, request);

        assertThat(response).isNotNull();
        assertThat(response.getPdfUrl()).isEqualTo(request.getPdfUrl());
    }
}
