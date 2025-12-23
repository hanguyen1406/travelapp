package com.travelapp.dto;

public class BalanceDTO {
    private Long userId;
    private String userName;
    private Double totalPaid;
    private Double totalOwed;
    private Double balance; // positive = người khác nợ, negative = nợ người khác

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
}
