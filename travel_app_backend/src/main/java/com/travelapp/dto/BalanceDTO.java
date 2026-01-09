package com.travelapp.dto;

import java.util.List;
import java.util.Map;

public class BalanceDTO {
    private Long userId;
    private String userName;
    private Double totalPaid;
    private Double totalOwed;
    private Double balance; // positive = người khác nợ, negative = nợ người khác
    private Long tripId;
    private Double userBalance;
    private Double totalToReceive;
    private List<SettlementDTO> settlements;
    private Map<Long, Double> allUserBalances;

    public BalanceDTO() {}

    public BalanceDTO(Long userId, String userName, Double totalPaid, Double totalOwed) {
        this.userId = userId;
        this.userName = userName;
        this.totalPaid = totalPaid != null ? totalPaid : 0.0;
        this.totalOwed = totalOwed != null ? totalOwed : 0.0;
        this.balance = this.totalPaid - this.totalOwed;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public Double getTotalPaid() { return totalPaid; }
    public void setTotalPaid(Double totalPaid) { this.totalPaid = totalPaid; }

    public Double getTotalOwed() { return totalOwed; }
    public void setTotalOwed(Double totalOwed) { this.totalOwed = totalOwed; }

    public Double getBalance() { return balance; }
    public void setBalance(Double balance) { this.balance = balance; }

    public Long getTripId() { return tripId; }
    public void setTripId(Long tripId) { this.tripId = tripId; }

    public Double getUserBalance() { return userBalance; }
    public void setUserBalance(Double userBalance) { this.userBalance = userBalance; }

    public Double getTotalToReceive() { return totalToReceive; }
    public void setTotalToReceive(Double totalToReceive) { this.totalToReceive = totalToReceive; }

    public List<SettlementDTO> getSettlements() { return settlements; }
    public void setSettlements(List<SettlementDTO> settlements) { this.settlements = settlements; }

    public Map<Long, Double> getAllUserBalances() { return allUserBalances; }
    public void setAllUserBalances(Map<Long, Double> allUserBalances) { this.allUserBalances = allUserBalances; }
}
