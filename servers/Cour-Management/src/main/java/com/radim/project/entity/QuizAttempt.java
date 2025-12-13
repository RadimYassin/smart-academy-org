package com.radim.project.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "quiz_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    @ToString.Exclude
    private Quiz quiz;

    @Column(nullable = false)
    private Long studentId; // From User-Management service

    @Column(nullable = false)
    private Integer score; // Total score achieved

    @Column(nullable = false)
    private Integer maxScore; // Total possible score

    @Column(nullable = false)
    private Double percentage; // Score as percentage

    @Column(nullable = false)
    private Boolean passed; // Whether student passed (e.g., >=60%)

    @OneToMany(mappedBy = "quizAttempt", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StudentAnswer> studentAnswers;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    private LocalDateTime submittedAt;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    /**
     * Calculate percentage based on score and maxScore
     */
    public void calculatePercentage() {
        if (maxScore != null && maxScore > 0) {
            this.percentage = (score.doubleValue() / maxScore.doubleValue()) * 100;
        } else {
            this.percentage = 0.0;
        }
    }

    /**
     * Determine if student passed (60% threshold)
     */
    public void determinePassed() {
        this.passed = this.percentage >= 60.0;
    }
}
