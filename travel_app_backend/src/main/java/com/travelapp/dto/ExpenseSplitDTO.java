package com.travelapp.dto;

public class ExpenseSplitDTO {
    private Long expenseId;
    private Long userId;
    private String userName;
    private Double shareAmount;
    private Double sharePercentage;
    private Boolean isPaid;

    public ExpenseSplitDTO() {}

    public Long getExpenseId() { return expenseId; }
    public void setExpenseId(Long expenseId) { this.expenseId = expenseId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public Double getShareAmount() { return shareAmount; }
    public void setShareAmount(Double shareAmount) { this.shareAmount = shareAmount; }

    public Double getSharePercentage() { return sharePercentage; }
    public void setSharePercentage(Double sharePercentage) { this.sharePercentage = sharePercentage; }

    public Boolean getIsPaid() { return isPaid; }
    public void setIsPaid(Boolean isPaid) { this.isPaid = isPaid; }
}
