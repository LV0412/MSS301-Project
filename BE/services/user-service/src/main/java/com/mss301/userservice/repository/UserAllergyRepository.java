package com.mss301.userservice.repository;

import com.mss301.userservice.entity.UserAllergy;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAllergyRepository extends JpaRepository<UserAllergy, Long> {

    List<UserAllergy> findAllByUserUserId(Long userId);

    Optional<UserAllergy> findByAllergyIdAndUserUserId(Long allergyId, Long userId);

    Optional<UserAllergy> findByUserUserIdAndAllergenId(Long userId, Long allergenId);
}
