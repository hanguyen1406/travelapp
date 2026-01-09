package com.travelapp.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.travelapp.dto.BalanceDTO;
import com.travelapp.model.MessageResponse;
import com.travelapp.service.BalanceService;

@RestController
@RequestMapping("/api/balance")
@CrossOrigin(origins = "*")
public class BalanceController {

    @Autowired
    private BalanceService balanceService;

    /**
     * Get balance for a user in a trip
     * GET /api/balance/trip/{tripId}/user/{userId}
     */
    @GetMapping("/trip/{tripId}/user/{userId}")
    public ResponseEntity<?> getBalance(@PathVariable Long tripId, @PathVariable Long userId) {
        try {
            BalanceDTO balance = balanceService.calculateBalance(tripId, userId);
            return ResponseEntity.ok(balance);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new MessageResponse("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new MessageResponse("error", "Failed to calculate balance: " + e.getMessage()));
        }
    }
}
