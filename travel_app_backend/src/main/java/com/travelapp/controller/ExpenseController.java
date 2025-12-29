package com.travelapp.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.travelapp.dto.ExpenseDTO;
import com.travelapp.model.MessageResponse;
import com.travelapp.model.User;
import com.travelapp.repository.UserRepository;
import com.travelapp.service.ExpenseService;

@RestController
@RequestMapping("/api/expenses")
@CrossOrigin(origins = "*")
public class ExpenseController {

    @Autowired
    private ExpenseService expenseService;

    @Autowired
    private UserRepository userRepository;

    /**
     * Create a new expense
     * POST /api/expenses/create
     */
    @PostMapping("/create")
    public ResponseEntity<?> createExpense(@RequestBody ExpenseDTO expenseDTO, Authentication authentication) {
        try {
            Long userId = null;
            if (authentication != null && authentication.getPrincipal() instanceof UserDetails) {
                UserDetails userDetails = (UserDetails) authentication.getPrincipal();
                Optional<User> userOpt = userRepository.findByUsername(userDetails.getUsername());
                if (userOpt.isPresent()) {
                    userId = userOpt.get().getId();
                }
            }

            // Fallback for dev
            if (userId == null)
                userId = 1L;

            if (expenseDTO.getPaidById() == null) {
                expenseDTO.setPaidById(userId);
            }

            ExpenseDTO createdExpense = expenseService.createExpense(expenseDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdExpense);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new MessageResponse("error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new MessageResponse("error", "Failed to create expense: " + e.getMessage()));
        }
    }

    /**
     * Get all expenses for a trip
     * GET /api/expenses/trip/{tripId}
     */
    @GetMapping("/trip/{tripId}")
    public ResponseEntity<?> getExpensesByTrip(@PathVariable Long tripId) {
        try {
            List<ExpenseDTO> expenses = expenseService.getExpensesByTrip(tripId);
            return ResponseEntity.ok(expenses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new MessageResponse("error", "Failed to load expenses: " + e.getMessage()));
        }
    }

    /**
     * Get expenses by category
     * GET /api/expenses/category?tripId={tripId}&category={category}
     */
    @GetMapping("/category")
    public ResponseEntity<?> getExpensesByCategory(
            @RequestParam("tripId") Long tripId,
            @RequestParam("category") String category) {
        try {
            List<ExpenseDTO> expenses = expenseService.getExpensesByCategory(tripId, category);
            return ResponseEntity.ok(expenses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new MessageResponse("error", "Failed to filter expenses: " + e.getMessage()));
        }
    }

    /**
     * Delete an expense
     * DELETE /api/expenses/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteExpense(@PathVariable Long id) {
        try {
            expenseService.deleteExpense(id);
            return ResponseEntity.ok(new MessageResponse("success", "Expense deleted successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new MessageResponse("error", "Failed to delete expense: " + e.getMessage()));
        }
    }
}
