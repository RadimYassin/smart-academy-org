package radim.ma.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import radim.ma.entities.StudentCredit;

import java.util.Optional;

@Repository
public interface StudentCreditRepository extends JpaRepository<StudentCredit, Long> {
    Optional<StudentCredit> findByUserId(Long userId);

    boolean existsByUserId(Long userId);
}
