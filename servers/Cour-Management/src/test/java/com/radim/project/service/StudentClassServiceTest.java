package com.radim.project.service;

import com.radim.project.dto.ClassDto;
import com.radim.project.entity.ClassStudent;
import com.radim.project.entity.StudentClass;
import com.radim.project.repository.ClassStudentRepository;
import com.radim.project.repository.StudentClassRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class StudentClassServiceTest {

    @Mock
    private StudentClassRepository studentClassRepository;
    @Mock
    private ClassStudentRepository classStudentRepository;

    @InjectMocks
    private StudentClassService studentClassService;

    private Long teacherId;
    private UUID classId;
    private StudentClass studentClass;

    @BeforeEach
    void setUp() {
        teacherId = 1L;
        classId = UUID.randomUUID();
        studentClass = StudentClass.builder()
                .id(classId)
                .name("Math 101")
                .teacherId(teacherId)
                .students(new ArrayList<>())
                .build();
    }

    @Test
    void createClass_ShouldSuccess() {
        ClassDto.CreateClassRequest request = new ClassDto.CreateClassRequest();
        request.setName("Math 101");

        when(studentClassRepository.save(any(StudentClass.class))).thenReturn(studentClass);

        ClassDto.ClassResponse response = studentClassService.createClass(request, teacherId);

        assertThat(response).isNotNull();
        assertThat(response.getName()).isEqualTo("Math 101");
        verify(studentClassRepository).save(any(StudentClass.class));
    }

    @Test
    void getClassById_ShouldSuccess() {
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));

        ClassDto.ClassResponse response = studentClassService.getClassById(classId, teacherId);

        assertThat(response.getId()).isEqualTo(classId);
    }

    @Test
    void getClassById_ShouldThrowException_WhenNotOwner() {
        studentClass.setTeacherId(999L);
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));

        assertThatThrownBy(() -> studentClassService.getClassById(classId, teacherId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void addStudentsToClass_ShouldSuccess() {
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));
        when(classStudentRepository.existsByStudentClassIdAndStudentId(eq(classId), anyLong())).thenReturn(false);

        studentClassService.addStudentsToClass(classId, List.of(2L, 3L), teacherId);

        verify(classStudentRepository, times(2)).save(any(ClassStudent.class));
    }

    @Test
    void removeStudentFromClass_ShouldSuccess() {
        when(studentClassRepository.findById(classId)).thenReturn(Optional.of(studentClass));

        studentClassService.removeStudentFromClass(classId, 2L, teacherId);

        verify(classStudentRepository).deleteByStudentClassIdAndStudentId(classId, 2L);
    }
}
