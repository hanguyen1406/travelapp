package com.travelapp.controller;

import com.travelapp.model.Trip;
import com.travelapp.service.TripService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/trips")
public class TripController {
    @Autowired
    private TripService tripService;

    @PostMapping
    public ResponseEntity<Trip> createTrip(@RequestBody Trip trip) {
        Trip savedTrip = tripService.saveTrip(trip);
        return ResponseEntity.ok(savedTrip);
    }

    @GetMapping
    public ResponseEntity<?> getAllTrips() {
        return ResponseEntity.ok(tripService.getAllTrips());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTripById(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.getTripById(id));
    }

    @PostMapping("/{id}/members")
    public ResponseEntity<?> addMemberToTrip(@PathVariable Long id, @RequestBody java.util.Map<String, String> body) {
        String email = body.get("email");
        String userIdStr = body.get("userId");

        try {
            if (userIdStr != null && !userIdStr.isEmpty()) {
                try {
                    Long userId = Long.parseLong(userIdStr);
                    return ResponseEntity.ok(tripService.addMemberToTripById(id, userId));
                } catch (NumberFormatException e) {
                    return ResponseEntity.badRequest().body("Invalid User ID format");
                }
            } else if (email != null && !email.isEmpty()) {
                return ResponseEntity.ok(tripService.addMemberToTrip(id, email));
            } else {
                return ResponseEntity.badRequest().body("Email or User ID is required");
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
