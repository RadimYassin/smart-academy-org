package com.radim.project.service;

import com.radim.project.dto.CourseDto;
import com.radim.project.entity.Course;
import com.radim.project.entity.enums.CourseLevel;
import com.radim.project.repository.CourseRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("CourseService Unit Tests")
class CourseServiceTest {

    @Mock
    private CourseRepository courseRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private CourseService courseService;

    private Course testCourse;
    private CourseDto.Request courseRequest;
    private final Long teacherId = 1L;
    private final UUID courseId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .id(courseId)
                .title("Introduction to Java")
                .description("Learn Java programming")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .thumbnailUrl("http://example.com/thumb.jpg")
                .teacherId(teacherId)
                .build();

        courseRequest = CourseDto.Request.builder()
                .title("Introduction to Java")
                .description("Learn Java programming")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .thumbnailUrl("http://example.com/thumb.jpg")
                .build();
    }

    @Test
    @DisplayName("Should get all courses successfully")
    void getAllCourses_Success() {
        // Given
        List<Course> courses = Arrays.asList(testCourse);
        when(courseRepository.findAll()).thenReturn(courses);

        // When
        List<CourseDto.Response> result = courseService.getAllCourses();

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getTitle()).isEqualTo("Introduction to Java");
        assertThat(result.get(0).getTeacherId()).isEqualTo(teacherId);
        verify(courseRepository).findAll();
    }

    @Test
    @DisplayName("Should get course by ID successfully")
    void getCourseById_Success() {
        // Given
        when(courseRepository.findById(courseId)).thenReturn(Optional.of(testCourse));

        // When
        CourseDto.Response result = courseService.getCourseById(courseId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTitle()).isEqualTo("Introduction to Java");
        assertThat(result.getId()).isEqualTo(courseId);
        verify(courseRepository).findById(courseId);
    }

    @Test
    @DisplayName("Should throw exception when course not found by ID")
    void getCourseById_NotFound() {
        // Given
        UUID nonExistentId = UUID.randomUUID();
        when(courseRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> courseService.getCourseById(nonExistentId))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Course not found");

        verify(courseRepository).findById(nonExistentId);
    }

    @Test
    @DisplayName("Should get courses by teacher ID successfully")
    void getCoursesByTeacherId_Success() {
        // Given
        List<Course> courses = Arrays.asList(testCourse);
        when(courseRepository.findByTeacherId(teacherId)).thenReturn(courses);

        // When
        List<CourseDto.Response> result = courseService.getCoursesByTeacherId(teacherId);

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getTeacherId()).isEqualTo(teacherId);
        verify(courseRepository).findByTeacherId(teacherId);
    }

    @Test
    @DisplayName("Should create course successfully")
    void createCourse_Success() {
        // Given
        try (MockedStatic<SecurityContextHolder> securityContextHolderMock = mockStatic(SecurityContextHolder.class)) {
            securityContextHolderMock.when(SecurityContextHolder::getContext).thenReturn(securityContext);
            when(securityContext.getAuthentication()).thenReturn(authentication);
            when(authentication.isAuthenticated()).thenReturn(true);
            when(authentication.getPrincipal()).thenReturn(teacherId.toString());
            when(courseRepository.save(any(Course.class))).thenReturn(testCourse);

            // When
            CourseDto.Response result = courseService.createCourse(courseRequest);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTitle()).isEqualTo("Introduction to Java");
            assertThat(result.getTeacherId()).isEqualTo(teacherId);
            verify(courseRepository).save(any(Course.class));
        }
    }

    @Test
    @DisplayName("Should update course successfully when user is owner")
    void updateCourse_Success() {
        // Given
        try (MockedStatic<SecurityContextHolder> securityContextHolderMock = mockStatic(SecurityContextHolder.class)) {
            securityContextHolderMock.when(SecurityContextHolder::getContext).thenReturn(securityContext);
            when(securityContext.getAuthentication()).thenReturn(authentication);
            when(authentication.isAuthenticated()).thenReturn(true);
            when(authentication.getPrincipal()).thenReturn(teacherId.toString());

            Collection<GrantedAuthority> authorities = Arrays.asList(new SimpleGrantedAuthority("ROLE_TEACHER"));
            when(authentication.getAuthorities()).thenReturn((Collection) authorities);

            when(courseRepository.findById(courseId)).thenReturn(Optional.of(testCourse));
            when(courseRepository.save(any(Course.class))).thenReturn(testCourse);

            // When
            CourseDto.Response result = courseService.updateCourse(courseId, courseRequest);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.getTitle()).isEqualTo("Introduction to Java");
            verify(courseRepository).save(any(Course.class));
        }
    }

    @Test
    @DisplayName("Should throw AccessDeniedException when non-owner tries to update")
    void updateCourse_AccessDenied() {
        // Given
        Long differentTeacherId = 999L;
        try (MockedStatic<SecurityContextHolder> securityContextHolderMock = mockStatic(SecurityContextHolder.class)) {
            securityContextHolderMock.when(SecurityContextHolder::getContext).thenReturn(securityContext);
            when(securityContext.getAuthentication()).thenReturn(authentication);
            when(authentication.isAuthenticated()).thenReturn(true);
            when(authentication.getPrincipal()).thenReturn(differentTeacherId.toString());

            Collection<GrantedAuthority> authorities = Arrays.asList(new SimpleGrantedAuthority("ROLE_TEACHER"));
            when(authentication.getAuthorities()).thenReturn((Collection) authorities);

            when(courseRepository.findById(courseId)).thenReturn(Optional.of(testCourse));

            // When & Then
            assertThatThrownBy(() -> courseService.updateCourse(courseId, courseRequest))
                    .isInstanceOf(AccessDeniedException.class)
                    .hasMessage("You are not the owner of this course");

            verify(courseRepository, never()).save(any(Course.class));
        }
    }

    @Test
    @DisplayName("Should delete course successfully when user is owner")
    void deleteCourse_Success() {
        // Given
        try (MockedStatic<SecurityContextHolder> securityContextHolderMock = mockStatic(SecurityContextHolder.class)) {
            securityContextHolderMock.when(SecurityContextHolder::getContext).thenReturn(securityContext);
            when(securityContext.getAuthentication()).thenReturn(authentication);
            when(authentication.isAuthenticated()).thenReturn(true);
            when(authentication.getPrincipal()).thenReturn(teacherId.toString());

            Collection<GrantedAuthority> authorities = Arrays.asList(new SimpleGrantedAuthority("ROLE_TEACHER"));
            when(authentication.getAuthorities()).thenReturn((Collection) authorities);

            when(courseRepository.findById(courseId)).thenReturn(Optional.of(testCourse));

            // When
            courseService.deleteCourse(courseId);

            // Then
            verify(courseRepository).delete(testCourse);
        }
    }
}
