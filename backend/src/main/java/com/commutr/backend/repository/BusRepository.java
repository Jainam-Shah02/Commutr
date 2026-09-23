package com.commutr.backend.repository;

import com.commutr.backend.entity.Bus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BusRepository extends JpaRepository<Bus, Long> {
    Optional<Bus> findByBusNumber(String busNumber);
    List<Bus> findByRouteId(Long routeId);
    List<Bus> findByStatus(String status);
}
