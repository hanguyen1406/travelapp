package com.travelapp.repository;

import com.travelapp.model.Itinerary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ItineraryRepository extends JpaRepository<Itinerary, Long> {
    List<Itinerary> findByTripId(Long tripId);

    List<Itinerary> findByTripIdAndDayNumber(Long tripId, Integer dayNumber);
}
