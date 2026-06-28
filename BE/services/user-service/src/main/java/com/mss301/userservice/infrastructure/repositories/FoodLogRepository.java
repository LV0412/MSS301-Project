package com.mss301.userservice.infrastructure.repositories;

import com.mss301.userservice.domain.FoodLog;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface FoodLogRepository extends JpaRepository<FoodLog, Long>, JpaSpecificationExecutor<FoodLog> {

    List<FoodLog> findAllByUserUserId(Long userId);

    Optional<FoodLog> findByLogIdAndUserUserId(Long logId, Long userId);
}
