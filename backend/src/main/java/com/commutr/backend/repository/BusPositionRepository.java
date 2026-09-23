package com.commutr.backend.repository;

import com.commutr.backend.entity.BusPosition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BusPositionRepository extends JpaRepository<BusPosition, Long> {
    Optional<BusPosition> findByBusId(Long busId);
    List<BusPosition> findByRouteId(Long routeId);
}
