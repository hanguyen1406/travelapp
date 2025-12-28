package com.travelapp.controller;

import com.travelapp.dto.ItineraryDTO;
import com.travelapp.service.ItineraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ItineraryController {

    @Autowired
    private ItineraryService itineraryService;

    @GetMapping("/trips/{tripId}/itineraries")
    public ResponseEntity<List<ItineraryDTO>> getItineraries(@PathVariable Long tripId) {
        return ResponseEntity.ok(itineraryService.getItinerariesByTripId(tripId));
    }

    @PostMapping("/trips/{tripId}/itineraries")
    public ResponseEntity<ItineraryDTO> createItinerary(@PathVariable Long tripId, @RequestBody ItineraryDTO dto) {
        return ResponseEntity.ok(itineraryService.createItinerary(tripId, dto));
    }

    @PostMapping("/itineraries/{id}/vote")
    public ResponseEntity<ItineraryDTO> voteItinerary(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        // Payload expected: { "userId": 123, "vote": true }
        Long userId = ((Number) payload.get("userId")).longValue();
        Boolean vote = (Boolean) payload.get("vote");
        return ResponseEntity.ok(itineraryService.voteItinerary(id, userId, vote));
    }
}
