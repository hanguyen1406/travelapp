package com.travelapp.model;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "expense_split")
public class ExpenseSplit {

    @EmbeddedId
    private ExpenseSplitId id;

    @ManyToOne
    @MapsId("expenseId")
    @JoinColumn(name = "expense_id")
    @JsonIgnore
    private Expense expense;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    private Double shareAmount;
    private Double sharePercentage;
    private Boolean isPaid = false;

    public ExpenseSplit() {}

    public ExpenseSplit(Expense expense, User user, Double shareAmount) {
        this.id = new ExpenseSplitId(expense.getId(), user.getId());
        this.expense = expense;
        this.user = user;
        this.shareAmount = shareAmount;
    }

    public ExpenseSplitId getId() { return id; }
    public void setId(ExpenseSplitId id) { this.id = id; }

    public Expense getExpense() { return expense; }
    public void setExpense(Expense expense) { this.expense = expense; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Double getShareAmount() { return shareAmount; }
    public void setShareAmount(Double shareAmount) { this.shareAmount = shareAmount; }

    public Double getSharePercentage() { return sharePercentage; }
    public void setSharePercentage(Double sharePercentage) { this.sharePercentage = sharePercentage; }

    public Boolean getIsPaid() { return isPaid; }
    public void setIsPaid(Boolean isPaid) { this.isPaid = isPaid; }
}

@Embeddable
class ExpenseSplitId implements Serializable {
    private Long expenseId;
    private Long userId;

    public ExpenseSplitId() {}

    public ExpenseSplitId(Long expenseId, Long userId) {
        this.expenseId = expenseId;
        this.userId = userId;
    }

    public Long getExpenseId() { return expenseId; }
    public void setExpenseId(Long expenseId) { this.expenseId = expenseId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ExpenseSplitId that = (ExpenseSplitId) o;
        return Objects.equals(expenseId, that.expenseId) && Objects.equals(userId, that.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(expenseId, userId);
    }
}
