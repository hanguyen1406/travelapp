package com.travelapp.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.travelapp.dto.BalanceDTO;
import com.travelapp.dto.SettlementDTO;
import com.travelapp.model.Expense;
import com.travelapp.model.ExpenseSplit;
import com.travelapp.model.Trip;
import com.travelapp.model.User;
import com.travelapp.repository.ExpenseRepository;
import com.travelapp.repository.TripRepository;
import com.travelapp.repository.UserRepository;

@Service
public class BalanceService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Calculate balance for a specific user in a trip
     */
    public BalanceDTO calculateBalance(Long tripId, Long userId) {
        // Validate Trip
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new IllegalArgumentException("Trip not found"));

        // Validate User
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Get all expenses for the trip
        List<Expense> expenses = expenseRepository.findByTripId(tripId);
        
        System.out.println("🔍 [BalanceService] Trip " + tripId + " has " + expenses.size() + " expenses");
        for (Expense e : expenses) {
            System.out.println("  - Expense " + e.getId() + ": " + e.getAmount() + " paid by " + e.getPaidBy().getId() + 
                             ", splits: " + (e.getSplits() != null ? e.getSplits().size() : 0));
            if (e.getSplits() != null) {
                for (ExpenseSplit split : e.getSplits()) {
                    System.out.println("    - User " + split.getUser().getId() + " owes " + split.getShareAmount());
                }
            }
        }

        // Calculate balances
        Map<Long, Double> userBalances = new HashMap<>();
        
        // Initialize balances for all trip members
        for (User member : trip.getMembers()) {
            userBalances.put(member.getId(), 0.0);
        }
        
        System.out.println("📊 [BalanceService] Initialized members: " + trip.getMembers().stream()
                .map(m -> m.getId().toString()).collect(Collectors.joining(", ")));

        // Calculate net balance for each user
        for (Expense expense : expenses) {
            Long payerId = expense.getPaidBy().getId();
            
            // Add to payer's balance (they paid)
            userBalances.put(payerId, userBalances.getOrDefault(payerId, 0.0) + expense.getAmount());
            System.out.println("  -> Payer " + payerId + " +  " + expense.getAmount() + " = " + userBalances.get(payerId));
            
            // Subtract from each person who owes
            if (expense.getSplits() != null && !expense.getSplits().isEmpty()) {
                for (ExpenseSplit split : expense.getSplits()) {
                    Long debtor = split.getUser().getId();
                    userBalances.put(debtor, userBalances.getOrDefault(debtor, 0.0) - split.getShareAmount());
                    System.out.println("  -> Debtor " + debtor + " - " + split.getShareAmount() + " = " + userBalances.get(debtor));
                }
            }
        }
        
        System.out.println("💰 [BalanceService] Final balances: " + userBalances);

        // Create user ID to User object map
        Map<Long, User> userMap = new HashMap<>();
        for (User member : trip.getMembers()) {
            userMap.put(member.getId(), member);
        }

        // Calculate settlements (who owes whom)
        List<SettlementDTO> settlements = calculateSettlements(userBalances, userMap);

        // Filter settlements for current user
        List<SettlementDTO> userSettlements = settlements.stream()
                .filter(s -> s.getFromUserId().equals(userId) || s.getToUserId().equals(userId))
                .collect(Collectors.toList());

        double userBalance = userBalances.getOrDefault(userId, 0.0);
        double totalOwed = userSettlements.stream()
                .filter(s -> s.getFromUserId().equals(userId))
                .mapToDouble(SettlementDTO::getAmount)
                .sum();
        double totalToReceive = userSettlements.stream()
                .filter(s -> s.getToUserId().equals(userId))
                .mapToDouble(SettlementDTO::getAmount)
                .sum();

        BalanceDTO balanceDTO = new BalanceDTO();
        balanceDTO.setTripId(tripId);
        balanceDTO.setUserId(userId);
        balanceDTO.setUserName(user.getUsername());
        balanceDTO.setUserBalance(userBalance);
        balanceDTO.setTotalOwed(totalOwed);
        balanceDTO.setTotalToReceive(totalToReceive);
        balanceDTO.setSettlements(userSettlements);
        balanceDTO.setAllUserBalances(userBalances);

        System.out.println("✅ [BalanceService] User " + userId + " balance in trip " + tripId + 
                          ": " + userBalance + " (Owes: " + totalOwed + ", Receives: " + totalToReceive + 
                          ", Settlements: " + userSettlements.size() + ")");

        return balanceDTO;
    }

    /**
     * Calculate all settlements needed in a trip
     */
    private List<SettlementDTO> calculateSettlements(Map<Long, Double> balances, Map<Long, User> userMap) {
        List<SettlementDTO> settlements = new ArrayList<>();

        System.out.println("🔄 [calculateSettlements] Processing balances: " + balances);

        // Separate debtors and creditors
        List<Long> debtors = balances.entrySet().stream()
                .filter(e -> e.getValue() < -1) // Tolerance of 1
                .sorted(Comparator.comparingDouble(e -> e.getValue()))
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
        
        List<Long> creditors = balances.entrySet().stream()
                .filter(e -> e.getValue() > 1)
                .sorted((a, b) -> Double.compare(b.getValue(), a.getValue()))
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        System.out.println("💔 [calculateSettlements] Debtors: " + debtors);
        System.out.println("💰 [calculateSettlements] Creditors: " + creditors);

        // Create mutable copy of balances for modification
        Map<Long, Double> tempBalances = new HashMap<>(balances);

        // Greedy matching algorithm
        int i = 0, j = 0;
        while (i < debtors.size() && j < creditors.size()) {
            Long debtorId = debtors.get(i);
            Long creditorId = creditors.get(j);
            
            double debt = Math.abs(tempBalances.get(debtorId));
            double credit = tempBalances.get(creditorId);
            
            double settlement = Math.min(debt, credit);
            
            System.out.println("  ⚖️ Matching: Debtor " + debtorId + " owes " + debt + 
                             ", Creditor " + creditorId + " gets " + credit + 
                             " -> Settlement: " + settlement);
            
            if (settlement > 1) { // Only record significant amounts
                SettlementDTO dto = new SettlementDTO();
                dto.setFromUserId(debtorId);
                dto.setFromUserName(userMap.get(debtorId).getUsername());
                dto.setToUserId(creditorId);
                dto.setToUserName(userMap.get(creditorId).getUsername());
                dto.setAmount(settlement);
                settlements.add(dto);
            }

            tempBalances.put(debtorId, tempBalances.get(debtorId) + settlement);
            tempBalances.put(creditorId, tempBalances.get(creditorId) - settlement);

            if (Math.abs(tempBalances.get(debtorId)) < 1) i++;
            if (Math.abs(tempBalances.get(creditorId)) < 1) j++;
        }

        return settlements;
    }
}
