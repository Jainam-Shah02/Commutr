package com.commutr.backend.repository;

import com.commutr.backend.entity.GpsObservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface GpsObservationRepository extends JpaRepository<GpsObservation, Long> {
    List<GpsObservation> findByBusIdAndServerTimestampAfter(Long busId, Instant after);
    List<GpsObservation> findTop20ByBusIdOrderByServerTimestampDesc(Long busId);
}
