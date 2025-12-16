package com.radim.project.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    @ToString.Exclude
    private Quiz quiz;

    @NotBlank
    @Column(nullable = false)
    private String questionText;

    @Column(nullable = false)
    private String questionType;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<QuestionOption> options = new ArrayList<>();

    private Integer points;

    // Helper method to add option
    public void addOption(QuestionOption option) {
        options.add(option);
        option.setQuestion(this);
    }

    // Helper method to remove option
    public void removeOption(QuestionOption option) {
        options.remove(option);
        option.setQuestion(null);
    }
}
