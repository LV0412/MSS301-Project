package com.mss301.userservice.repository;

import com.mss301.userservice.entity.DietPreference;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DietPreferenceRepository extends JpaRepository<DietPreference, Long> {

    List<DietPreference> findAllByUserUserId(Long userId);

    Optional<DietPreference> findByPreferenceIdAndUserUserId(Long preferenceId, Long userId);

    Optional<DietPreference> findByUserUserIdAndDietTypeIgnoreCase(Long userId, String dietType);
}
