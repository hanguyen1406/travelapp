# 🔍 Balance Settlement Data Flow - Debug Guide

## 📊 Database Schema (MySQL)

### 1. **expenses** table
```sql
CREATE TABLE expenses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    description TEXT,
    amount DOUBLE,
    currency VARCHAR(10),
    category VARCHAR(50),
    paid_by BIGINT,  -- FK to users.id (người trả tiền)
    trip_id BIGINT,  -- FK to trips.id
    split_method VARCHAR(20),  -- ENUM: EVEN, CUSTOM, PERCENTAGE
    expense_date TIMESTAMP,
    created_at TIMESTAMP,
    FOREIGN KEY (paid_by) REFERENCES users(id),
    FOREIGN KEY (trip_id) REFERENCES trips(id)
);
```

### 2. **expense_splits** table (QUAN TRỌNG!)
```sql
CREATE TABLE expense_splits (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    expense_id BIGINT,  -- FK to expenses.id
    user_id BIGINT,     -- FK to users.id (người phải trả)
    share_amount DOUBLE, -- số tiền người này phải trả
    share_percentage DOUBLE,
    is_paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### 3. **trips** table
```sql
CREATE TABLE trips (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    ...
);
```

### 4. **trip_members** table (many-to-many)
```sql
CREATE TABLE trip_members (
    trip_id BIGINT,
    user_id BIGINT,
    PRIMARY KEY (trip_id, user_id),
    FOREIGN KEY (trip_id) REFERENCES trips(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 🔄 Data Flow Diagram

```
User clicks "Thêm chi phí"
    ↓
AddExpense.dart creates Expense with splits
    ↓
POST /api/expenses/create
    ↓
ExpenseService.createExpense()
    ├─ Saves Expense record
    ├─ Saves ExpenseSplit records (N splits for N members)
    └─ Returns ExpenseDTO with splits
    ↓
Data saved to DB:
    └─ expenses table: 1 record
    └─ expense_splits table: N records
    ↓
User views balance settlement screen
    ↓
GET /api/balance/trip/{tripId}/user/{userId}
    ↓
BalanceService.calculateBalance()
    ├─ ExpenseRepository.findByTripId(tripId)
    │   └─ NOW: Uses LEFT JOIN FETCH e.splits ✅
    │   └─ BEFORE: Splits were NULL ❌
    ├─ Iterates all expenses + splits
    ├─ Calculates user balances
    ├─ Matches debtors ↔ creditors
    └─ Returns BalanceDTO with settlements
    ↓
Flutter BalanceSu.dart receives response
    ├─ Parses settlements[]
    ├─ Displays settlement cards
    └─ Sets dataLoaded = true
```

---

## 🐛 THE BUG (and fix)

### ❌ Before (splits were NULL)
```java
List<Expense> expenses = expenseRepository.findByTripId(tripId);
// This only loaded Expense records, NOT the related ExpenseSplit records!

for (Expense expense : expenses) {
    if (expense.getSplits() != null) {  // ❌ getSplits() was NULL!
        for (ExpenseSplit split : expense.getSplits()) {
            // Never executed because splits = null
        }
    }
}
// Result: All balances = 0, no settlements calculated
```

### ✅ After (splits are eager loaded)
```java
@Query("SELECT DISTINCT e FROM Expense e LEFT JOIN FETCH e.splits WHERE e.trip.id = :tripId ORDER BY e.expenseDate DESC")
List<Expense> findByTripId(@Param("tripId") Long tripId);

// Now expense.getSplits() contains all ExpenseSplit records!
for (Expense expense : expenses) {
    if (expense.getSplits() != null && !expense.getSplits().isEmpty()) {
        for (ExpenseSplit split : expense.getSplits()) {
            // ✅ Now processes all splits correctly
            Long debtor = split.getUser().getId();
            userBalances.put(debtor, ...);
        }
    }
}
```

---

## 📋 Backend Processing (BalanceService)

### Step 1: Load all expenses with splits
```
Trip 24 has 3 expenses:
  - Expense 1: 300k paid by user 1, splits: [user 2: 100k, user 3: 100k, user 1: 100k]
  - Expense 2: 200k paid by user 2, splits: [user 1: 100k, user 2: 100k]
  - Expense 3: 150k paid by user 3, splits: [user 3: 150k]
```

### Step 2: Calculate net balance per user
```
User 1: +300k (paid exp1) -100k (exp1 split) -100k (exp2 split) = +100k (creditor - others owe)
User 2: +200k (paid exp2) -100k (exp1 split) -100k (exp2 split) = 0 (settled)
User 3: +150k (paid exp3) -100k (exp1 split) -150k (exp3 split) = -100k (debtor - owes)
```

### Step 3: Match debtors ↔ creditors
```
Debtors: [user 3: -100k]
Creditors: [user 1: +100k]
Settlement: user 3 → user 1: 100k
```

### Step 4: Return BalanceDTO
```json
{
  "userBalance": 100.0,
  "totalOwed": 0.0,
  "totalToReceive": 100.0,
  "settlements": [
    {
      "fromUserId": 3,
      "fromUserName": "Ha2",
      "toUserId": 1,
      "toUserName": "Nguyen",
      "amount": 100000.0
    }
  ]
}
```

---

## 🎯 Frontend Processing (BalanceSu.dart)

```dart
final balanceData = await ExpenseRepository.getBalance(tripId, userId);

// Parse fields
userBalance = balanceData['userBalance']  // 100.0
totalDebt = balanceData['totalOwed']      // 0.0
totalPayment = balanceData['totalToReceive']  // 100.0

// Parse settlements
settlements = [];
for (var s in balanceData['settlements']) {
    settlements.add(Settlement(
        from: s['fromUserName'],  // "Ha2"
        to: s['toUserName'],      // "Nguyen"
        amount: s['amount']       // 100000.0
    ));
}

// UI Display
if (settlements.isEmpty && dataLoaded) {
    show "Tất cả đã thanh toán!"  // All paid message
} else if (settlements.isNotEmpty) {
    show settlement cards with details
}
```

---

## 🔧 Console Logs to Watch

### Backend Console
```
🔍 [BalanceService] Trip 24 has 3 expenses
  - Expense 1: 300.0 paid by 1, splits: 3
    - User 2 owes 100.0
    - User 3 owes 100.0
    - User 1 owes 100.0
  - Expense 2: 200.0 paid by 2, splits: 2
    - User 1 owes 100.0
    - User 2 owes 100.0
  - Expense 3: 150.0 paid by 3, splits: 1
    - User 3 owes 150.0

📊 [BalanceService] Initialized members: 1, 2, 3

💰 [BalanceService] Final balances: {1=100.0, 2=0.0, 3=-100.0}

🔄 [calculateSettlements] Processing balances: {1=100.0, 2=0.0, 3=-100.0}
💔 [calculateSettlements] Debtors: [3]
💰 [calculateSettlements] Creditors: [1]
  ⚖️ Matching: Debtor 3 owes 100.0, Creditor 1 gets 100.0 → Settlement: 100.0

✅ [BalanceService] User 1 balance in trip 24: 100.0 (Owes: 0.0, Receives: 100.0, Settlements: 1)
```

### Flutter Console
```
✅ [BalanceSu] Loaded balance from API
💰 [BalanceSu API] Balance: 100.0, Debt: 0.0, Payment: 100.0
📊 [BalanceSu API] Full response: {userBalance: 100.0, totalOwed: 0.0, ...}
📋 [BalanceSu API] Settlements count: 1
➕ [BalanceSu API] Adding settlement: Bạn <- Ha2: 100000.0
✅ [BalanceSu API] Parsed settlements: 1
```

---

## ✅ What Was Fixed Today

| Component | Issue | Fix |
|-----------|-------|-----|
| **ExpenseRepository** | Splits not loaded | Added `LEFT JOIN FETCH e.splits` to both queries |
| **BalanceService** | Couldn't access splits | Now receives fully loaded Expense objects |
| **ExpenseRepository URLs** | Wrong endpoint paths | Fixed `/api` prefix in all URLs |
| **BalanceSu.dart** | False "all paid" message | Added `dataLoaded` flag to distinguish loading state |

---

## 🚀 Testing Checklist

- [ ] Add expense with multiple members
- [ ] Check backend logs: see 3+ splits created ✅
- [ ] Check Flutter logs: see settlement count > 0 ✅
- [ ] View balance screen: see settlement cards (not "all paid") ✅
- [ ] Verify amounts match: expense amount = sum of splits ✅

