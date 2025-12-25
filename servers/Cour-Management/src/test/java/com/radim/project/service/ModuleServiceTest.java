package com.radim.project.service;

import com.radim.project.dto.ModuleDto;
import com.radim.project.entity.Course;
import com.radim.project.repository.CourseRepository;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ModuleServiceTest {

    @Mock
    private ModuleRepository moduleRepository;
    @Mock
    private CourseRepository courseRepository;

    @InjectMocks
    private ModuleService moduleService;

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
    void createModule_ShouldSuccess() {
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(course));

        ModuleDto.Request request = ModuleDto.Request.builder()
                .title("Introduction")
                .description("Basics")
                .orderIndex(1)
                .build();

        com.radim.project.entity.Module module = com.radim.project.entity.Module.builder()
                .id(UUID.randomUUID())
                .course(course)
                .title(request.getTitle())
                .build();

        when(moduleRepository.save(any(com.radim.project.entity.Module.class))).thenReturn(module);

        ModuleDto.Response response = moduleService.createModule(courseId, request);

        assertThat(response).isNotNull();
        assertThat(response.getTitle()).isEqualTo("Introduction");
    }

    @Test
    void updateModule_ShouldSuccess() {
        UUID moduleId = UUID.randomUUID();
        com.radim.project.entity.Module existingModule = com.radim.project.entity.Module.builder()
                .id(moduleId)
                .course(course)
                .title("Old Title")
                .build();

        when(moduleRepository.findById(moduleId)).thenReturn(Optional.of(existingModule));

        ModuleDto.Request request = ModuleDto.Request.builder().title("New Title").build();

        when(moduleRepository.save(any(com.radim.project.entity.Module.class))).thenReturn(existingModule);

        ModuleDto.Response response = moduleService.updateModule(courseId, moduleId, request);

        assertThat(response.getTitle()).isEqualTo("New Title");
    }

    @Test
    void deleteModule_ShouldSuccess() {
        UUID moduleId = UUID.randomUUID();
        com.radim.project.entity.Module existingModule = com.radim.project.entity.Module.builder()
                .id(moduleId)
                .course(course)
                .build();

        when(moduleRepository.findById(moduleId)).thenReturn(Optional.of(existingModule));

        moduleService.deleteModule(courseId, moduleId);

        verify(moduleRepository).delete(existingModule);
    }
}
