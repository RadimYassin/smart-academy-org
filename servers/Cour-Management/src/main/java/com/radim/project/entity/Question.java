package com.radim.project.entity;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.io.IOException;
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
    private String content;

    @Column(columnDefinition = "TEXT") // Store as JSON string
    private String options;

    @Min(0)
    @Max(3)
    private int correctOptionIndex;

    // Helper methods to handle List<String> <-> JSON String conversion if needed
    // For now, we expose the raw String or we can add a transient getter/setter

    public List<String> getOptionsList() {
        if (options == null)
            return List.of();
        try {
            return new ObjectMapper().readValue(options, new TypeReference<List<String>>() {
            });
        } catch (IOException e) {
            return List.of();
        }
    }

    public void setOptionsList(List<String> optionsList) {
        try {
            this.options = new ObjectMapper().writeValueAsString(optionsList);
        } catch (JsonProcessingException e) {
            this.options = "[]";
        }
    }
}
