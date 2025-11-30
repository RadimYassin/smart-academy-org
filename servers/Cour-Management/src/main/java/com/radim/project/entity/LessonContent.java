package com.radim.project.entity;

import com.radim.project.entity.enums.ContentType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "lesson_contents")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LessonContent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    @ToString.Exclude
    private Lesson lesson;

    @Enumerated(EnumType.STRING)
    @NotNull
    private ContentType type;

    @Column(columnDefinition = "TEXT")
    private String textContent;

    private String pdfUrl;

    private String videoUrl;

    private String imageUrl;

    private UUID quizId; // Reference to a Quiz

    private int orderIndex;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
