package com.travelapp.service;

import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.travelapp.dto.ExpenseDTO;
import com.travelapp.dto.ExpenseSplitDTO;
import com.travelapp.model.Expense;
import com.travelapp.model.ExpenseSplit;
import com.travelapp.model.Trip;
import com.travelapp.model.User;
import com.travelapp.repository.ExpenseRepository;
import com.travelapp.repository.TripRepository;
import com.travelapp.repository.UserRepository;

@Service
public class ExpenseService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Upload/Create a new expense
     */
    @Transactional
    public ExpenseDTO createExpense(ExpenseDTO expenseDTO) {
        // Validate Trip
        Trip trip = tripRepository.findById(expenseDTO.getTripId())
                .orElseThrow(() -> new IllegalArgumentException("Trip not found"));

        // Validate Payer
        User paidBy = userRepository.findById(expenseDTO.getPaidById())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Expense expense = new Expense();
        expense.setTitle(expenseDTO.getTitle());
        expense.setDescription(expenseDTO.getDescription());
        expense.setAmount(expenseDTO.getAmount());
        expense.setCurrency(expenseDTO.getCurrency());
        expense.setCategory(expenseDTO.getCategory());
        expense.setPaidBy(paidBy);
        expense.setTrip(trip);
        expense.setExpenseDate(expenseDTO.getExpenseDate() != null ? expenseDTO.getExpenseDate() : new Date());
        expense.setCreatedAt(new Date());

        // Save expense first to get ID
        expense = expenseRepository.save(expense);

        // Handle Splits
        if (expenseDTO.getSplits() != null && !expenseDTO.getSplits().isEmpty()) {
            List<ExpenseSplit> splits = new java.util.ArrayList<>();
            List<Long> userIds = expenseDTO.getSplits().stream()
                    .map(ExpenseSplitDTO::getUserId)
                    .collect(Collectors.toList());

            Iterable<User> usersIterable = userRepository.findAllById(userIds);
            java.util.Map<Long, User> userMap = new java.util.HashMap<>();
            usersIterable.forEach(u -> userMap.put(u.getId(), u));

            for (ExpenseSplitDTO splitDTO : expenseDTO.getSplits()) {
                User user = userMap.get(splitDTO.getUserId());
                if (user != null) {
                    // Use public constructor that handles ID generation internally
                    ExpenseSplit split = new ExpenseSplit(expense, user, splitDTO.getShareAmount());

                    split.setSharePercentage(splitDTO.getSharePercentage());
                    split.setIsPaid(splitDTO.getIsPaid() != null ? splitDTO.getIsPaid() : false);
                    splits.add(split);
                }
            }
            expense.setSplits(splits);
            expense = expenseRepository.save(expense);
        }

        return mapToDTO(expense);
    }

    /**
     * Get all expenses for a trip
     */
    public List<ExpenseDTO> getExpensesByTrip(Long tripId) {
        List<Expense> expenses = expenseRepository.findByTripId(tripId);
        return expenses.stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Get expenses by category
     */
    public List<ExpenseDTO> getExpensesByCategory(Long tripId, String category) {
        List<Expense> expenses = expenseRepository.findByTripIdAndCategory(tripId, category);
        return expenses.stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Delete expense
     */
    public void deleteExpense(Long expenseId) {
        if (!expenseRepository.existsById(expenseId)) {
            throw new IllegalArgumentException("Expense not found");
        }
        expenseRepository.deleteById(expenseId);
    }

    // Helper to map Entity to DTO
    private ExpenseDTO mapToDTO(Expense expense) {
        ExpenseDTO dto = new ExpenseDTO();
        dto.setId(expense.getId());
        dto.setTitle(expense.getTitle());
        dto.setDescription(expense.getDescription());
        dto.setAmount(expense.getAmount());
        dto.setCurrency(expense.getCurrency());
        dto.setCategory(expense.getCategory());
        dto.setExpenseDate(expense.getExpenseDate());
        dto.setCreatedAt(expense.getCreatedAt());
        dto.setTripId(expense.getTrip().getId());
        dto.setSplitMethod(expense.getSplitMethod() != null ? expense.getSplitMethod().toString() : "EVEN");

        if (expense.getPaidBy() != null) {
            dto.setPaidById(expense.getPaidBy().getId());
            dto.setPaidByName(expense.getPaidBy().getUsername());
        }

        if (expense.getSplits() != null) {
            List<ExpenseSplitDTO> splitDTOs = expense.getSplits().stream().map(split -> {
                ExpenseSplitDTO splitDTO = new ExpenseSplitDTO();
                splitDTO.setExpenseId(split.getExpense().getId());
                splitDTO.setUserId(split.getUser().getId());
                splitDTO.setUserName(split.getUser().getUsername()); // Assuming User has getUsername() or getName()
                splitDTO.setShareAmount(split.getShareAmount());
                splitDTO.setSharePercentage(split.getSharePercentage());
                splitDTO.setIsPaid(split.getIsPaid());
                return splitDTO;
            }).collect(Collectors.toList());
            dto.setSplits(splitDTOs);
        }

        return dto;
    }
}
