package radim.ma.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import radim.ma.entities.User;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    @Modifying
    @Query(value = "UPDATE users SET deleted = false WHERE id = :id", nativeQuery = true)
    void restoreUser(@Param("id") Long id);
}
