package com.radim.project.repository;

import com.radim.project.entity.Course;
import com.radim.project.entity.Module;
import com.radim.project.entity.enums.CourseLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("ModuleRepository Integration Tests")
class ModuleRepositoryTest {

    @Autowired
    private ModuleRepository moduleRepository;

    @Autowired
    private TestEntityManager entityManager;

    private Course testCourse;
    private Module module1;
    private Module module2;

    @BeforeEach
    void setUp() {
        testCourse = Course.builder()
                .title("Java Course")
                .description("Learn Java")
                .category("Programming")
                .level(CourseLevel.BEGINNER)
                .teacherId(1L)
                .build();

        testCourse = entityManager.persistAndFlush(testCourse);

        module1 = Module.builder()
                .title("Module 1: Basics")
                .course(testCourse)
                .orderIndex(1)
                .build();

        module2 = Module.builder()
                .title("Module 2: Advanced")
                .course(testCourse)
                .orderIndex(2)
                .build();
    }

    @Test
    @DisplayName("Should save module successfully")
    void save_Success() {
        // When
        Module saved = moduleRepository.save(module1);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getTitle()).isEqualTo("Module 1: Basics");
        assertThat(saved.getCourse().getId()).isEqualTo(testCourse.getId());
    }

    @Test
    @DisplayName("Should find module by ID")
    void findById_Success() {
        // Given
        Module saved = entityManager.persistAndFlush(module1);

        // When
        Optional<Module> found = moduleRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getTitle()).isEqualTo("Module 1: Basics");
    }

    @Test
    @DisplayName("Should find modules by course ID ordered")
    void findByCourseIdOrderByOrderIndexAsc_Success() {
        // Given
        entityManager.persist(module2);
        entityManager.persist(module1);
        entityManager.flush();

        // When
        List<Module> modules = moduleRepository.findByCourseIdOrderByOrderIndexAsc(testCourse.getId());

        // Then
        assertThat(modules).hasSize(2);
        assertThat(modules.get(0).getOrderIndex()).isEqualTo(1);
        assertThat(modules.get(1).getOrderIndex()).isEqualTo(2);
    }

    @Test
    @DisplayName("Should return empty list when no modules for course")
    void findByCourseIdOrderByOrderIndexAsc_Empty() {
        // Given
        UUID nonExistentCourseId = UUID.randomUUID();

        // When
        List<Module> modules = moduleRepository.findByCourseIdOrderByOrderIndexAsc(nonExistentCourseId);

        // Then
        assertThat(modules).isEmpty();
    }

    @Test
    @DisplayName("Should delete module successfully")
    void delete_Success() {
        // Given
        Module saved = entityManager.persistAndFlush(module1);
        UUID moduleId = saved.getId();

        // When
        moduleRepository.delete(saved);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<Module> found = moduleRepository.findById(moduleId);
        assertThat(found).isEmpty();
    }
}
