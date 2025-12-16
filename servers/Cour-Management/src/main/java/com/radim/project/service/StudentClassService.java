package com.radim.project.service;

import com.radim.project.dto.ClassDto;
import com.radim.project.entity.ClassStudent;
import com.radim.project.entity.StudentClass;
import com.radim.project.repository.ClassStudentRepository;
import com.radim.project.repository.StudentClassRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentClassService {

    private final StudentClassRepository studentClassRepository;
    private final ClassStudentRepository classStudentRepository;

    public ClassDto.ClassResponse createClass(ClassDto.CreateClassRequest request, Long teacherId) {
        log.info("Creating class '{}' for teacher {}", request.getName(), teacherId);

        StudentClass studentClass = StudentClass.builder()
                .name(request.getName())
                .description(request.getDescription())
                .teacherId(teacherId)
                .build();

        StudentClass saved = studentClassRepository.save(studentClass);
        return toClassResponse(saved);
    }

    public List<ClassDto.ClassResponse> getClassesByTeacher(Long teacherId) {
        log.info("Fetching classes for teacher {}", teacherId);
        return studentClassRepository.findByTeacherId(teacherId)
                .stream()
                .map(this::toClassResponse)
                .collect(Collectors.toList());
    }

    public ClassDto.ClassResponse getClassById(UUID classId, Long teacherId) {
        log.info("Fetching class {} for teacher {}", classId, teacherId);
        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        return toClassResponse(studentClass);
    }

    @Transactional
    public ClassDto.ClassResponse updateClass(UUID classId, ClassDto.UpdateClassRequest request, Long teacherId) {
        log.info("Updating class {} for teacher {}", classId, teacherId);
        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        studentClass.setName(request.getName());
        studentClass.setDescription(request.getDescription());

        StudentClass updated = studentClassRepository.save(studentClass);
        return toClassResponse(updated);
    }

    @Transactional
    public void deleteClass(UUID classId, Long teacherId) {
        log.info("Deleting class {} for teacher {}", classId, teacherId);
        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        studentClassRepository.delete(studentClass);
    }

    @Transactional
    public void addStudentsToClass(UUID classId, List<Long> studentIds, Long teacherId) {
        log.info("Adding {} students to class {} by teacher {}", studentIds.size(), classId, teacherId);

        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        for (Long studentId : studentIds) {
            // Check if student already in class
            if (classStudentRepository.existsByStudentClassIdAndStudentId(classId, studentId)) {
                log.warn("Student {} already in class {}, skipping", studentId, classId);
                continue;
            }

            ClassStudent classStudent = ClassStudent.builder()
                    .studentClass(studentClass)
                    .studentId(studentId)
                    .addedBy(teacherId)
                    .build();

            classStudentRepository.save(classStudent);
        }
    }

    @Transactional
    public void removeStudentFromClass(UUID classId, Long studentId, Long teacherId) {
        log.info("Removing student {} from class {} by teacher {}", studentId, classId, teacherId);

        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        classStudentRepository.deleteByStudentClassIdAndStudentId(classId, studentId);
    }

    public List<ClassDto.ClassStudentResponse> getClassStudents(UUID classId, Long teacherId) {
        log.info("Fetching students for class {} by teacher {}", classId, teacherId);

        StudentClass studentClass = studentClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));

        if (!studentClass.getTeacherId().equals(teacherId)) {
            throw new RuntimeException("Access denied: You do not own this class");
        }

        return classStudentRepository.findByStudentClassId(classId)
                .stream()
                .map(cs -> ClassDto.ClassStudentResponse.builder()
                        .studentId(cs.getStudentId())
                        .addedBy(cs.getAddedBy())
                        .addedAt(cs.getAddedAt())
                        .build())
                .collect(Collectors.toList());
    }

    private ClassDto.ClassResponse toClassResponse(StudentClass studentClass) {
        return ClassDto.ClassResponse.builder()
                .id(studentClass.getId())
                .name(studentClass.getName())
                .description(studentClass.getDescription())
                .teacherId(studentClass.getTeacherId())
                .studentCount(studentClass.getStudents() != null ? studentClass.getStudents().size() : 0)
                .createdAt(studentClass.getCreatedAt())
                .updatedAt(studentClass.getUpdatedAt())
                .build();
    }
}
