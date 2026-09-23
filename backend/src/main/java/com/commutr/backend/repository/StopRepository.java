package com.commutr.backend.repository;

import com.commutr.backend.entity.Stop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StopRepository extends JpaRepository<Stop, Long> {
    Optional<Stop> findByCode(String code);
}
