package radim.ma.repositories;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import radim.ma.entities.Role;
import radim.ma.entities.User;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("UserRepository Integration Tests")
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TestEntityManager entityManager;

    private User student;
    private User teacher;

    @BeforeEach
    void setUp() {
        student = User.builder()
                .email("student@example.com")
                .password("encodedPassword")
                .firstName("John")
                .lastName("Doe")
                .role(Role.STUDENT)
                .isVerified(true)
                .build();

        teacher = User.builder()
                .email("teacher@example.com")
                .password("encodedPassword")
                .firstName("Jane")
                .lastName("Smith")
                .role(Role.TEACHER)
                .isVerified(true)
                .build();
    }

    @Test
    @DisplayName("Should save and find user by email")
    void findByEmail_Success() {
        // Given
        entityManager.persistAndFlush(student);

        // When
        Optional<User> found = userRepository.findByEmail("student@example.com");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("student@example.com");
        assertThat(found.get().getFirstName()).isEqualTo("John");
        assertThat(found.get().getRole()).isEqualTo(Role.STUDENT);
    }

    @Test
    @DisplayName("Should return empty when user not found by email")
    void findByEmail_NotFound() {
        // When
        Optional<User> found = userRepository.findByEmail("nonexistent@example.com");

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("Should check if user exists by email")
    void existsByEmail_True() {
        // Given
        entityManager.persistAndFlush(student);

        // When
        boolean exists = userRepository.existsByEmail("student@example.com");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    @DisplayName("Should return false when email does not exist")
    void existsByEmail_False() {
        // When
        boolean exists = userRepository.existsByEmail("nonexistent@example.com");

        // Then
        assertThat(exists).isFalse();
    }

    @Test
    @DisplayName("Should find users by role")
    void findByRole_Success() {
        // Given
        entityManager.persist(student);
        entityManager.persist(teacher);
        entityManager.flush();

        // When
        List<User> students = userRepository.findByRole(Role.STUDENT);
        List<User> teachers = userRepository.findByRole(Role.TEACHER);

        // Then
        assertThat(students).hasSize(1);
        assertThat(students.get(0).getEmail()).isEqualTo("student@example.com");

        assertThat(teachers).hasSize(1);
        assertThat(teachers.get(0).getEmail()).isEqualTo("teacher@example.com");
    }

    @Test
    @DisplayName("Should return empty list when no users found for role")
    void findByRole_NoResults() {
        // When
        List<User> admins = userRepository.findByRole(Role.ADMIN);

        // Then
        assertThat(admins).isEmpty();
    }

    @Test
    @DisplayName("Should soft delete user")
    void softDelete_Success() {
        // Given
        User savedUser = entityManager.persistAndFlush(student);
        Long userId = savedUser.getId();

        // When
        userRepository.delete(savedUser);
        entityManager.flush();
        entityManager.clear(); // Clear persistence context

        // Then
        Optional<User> found = userRepository.findById(userId);
        assertThat(found).isEmpty(); // Soft deleted users are filtered out
    }

    @Test
    @DisplayName("Should restore deleted user")
    void restoreUser_Success() {
        // Given
        User savedUser = entityManager.persistAndFlush(student);
        Long userId = savedUser.getId();

        // Soft delete
        userRepository.delete(savedUser);
        entityManager.flush();
        entityManager.clear();

        // When
        userRepository.restoreUser(userId);
        entityManager.flush();
        entityManager.clear();

        // Then - verify user is restored
        Optional<User> restoredUser = userRepository.findById(userId);
        assertThat(restoredUser).isPresent();
        assertThat(restoredUser.get().getEmail()).isEqualTo("student@example.com");
    }

    @Test
    @DisplayName("Should test JPA lifecycle callbacks for timestamps")
    void testTimestamps() {
        // When
        User savedUser = userRepository.save(student);

        // Then
        assertThat(savedUser.getId()).isNotNull();
        assertThat(savedUser.getCreatedAt()).isNotNull();
        assertThat(savedUser.getUpdatedAt()).isNotNull();
        assertThat(savedUser.getCreatedAt()).isEqualTo(savedUser.getUpdatedAt());
    }

    @Test
    @DisplayName("Should update timestamp on user update")
    void testUpdateTimestamp() throws InterruptedException {
        // Given
        User savedUser = entityManager.persistAndFlush(student);
        var createdAt = savedUser.getCreatedAt();

        // Wait a bit to ensure timestamp difference
        Thread.sleep(10);

        // When
        savedUser.setFirstName("UpdatedName");
        entityManager.persistAndFlush(savedUser);

        // Then
        assertThat(savedUser.getUpdatedAt()).isAfter(createdAt);
    }

    @Test
    @DisplayName("Should find user with verification code")
    void findByEmail_WithVerificationCode() {
        // Given
        student.setVerificationCode("123456");
        entityManager.persistAndFlush(student);

        // When
        Optional<User> found = userRepository.findByEmail("student@example.com");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getVerificationCode()).isEqualTo("123456");
    }

    @Test
    @DisplayName("Should save user with all fields populated")
    void saveUser_CompleteEntity() {
        // Given
        User completeUser = User.builder()
                .email("complete@example.com")
                .password("password123")
                .firstName("Complete")
                .lastName("User")
                .role(Role.ADMIN)
                .isVerified(false)
                .verificationCode("654321")
                .build();

        // When
        User saved = userRepository.save(completeUser);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getEmail()).isEqualTo("complete@example.com");
        assertThat(saved.getRole()).isEqualTo(Role.ADMIN);
        assertThat(saved.getIsVerified()).isFalse();
        assertThat(saved.getVerificationCode()).isEqualTo("654321");
    }
}
