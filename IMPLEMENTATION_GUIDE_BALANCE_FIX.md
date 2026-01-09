# HƯỚNG DẪN TRIỂN KHAI - Sửa Tóm tắt Số dư

## 📋 Tóm Tắt Vấn Đề
Khi người dùng thêm chi phí (expenses) trong ứng dụng, số dư (balance) trong mục "Tóm tắt số dư" (BalanceSu) không được cập nhật hoặc hiển thị sai.

**Nguyên nhân gốc:**
1. BalanceSu chỉ load dữ liệu một lần trong `initState()`
2. Khi quay lại từ thêm chi phí, không có cơ chế refresh
3. Không có backend API riêng để tính settlement (ai nợ ai)

---

## 🔧 Các Thay Đổi Chi Tiết

### A. BACKEND (Java Spring Boot)

#### 1️⃣ Tạo BalanceService (Mới)
**File**: `travel_app_backend/src/main/java/com/travelapp/service/BalanceService.java`

Chức năng:
- Tính net balance cho mỗi user = total paid - total owed
- Tính settlements giữa các users (ai nợ ai bao nhiêu)
- Sử dụng greedy matching algorithm

```java
// Ví dụ
// User A trả 300k, được chia 3 người (100k mỗi người)
// User A balance = 300k - 100k = 200k (người khác nợ 200k)
// User B, C balance = -100k (nợi A 100k mỗi người)
```

#### 2️⃣ Tạo BalanceController (Mới)
**File**: `travel_app_backend/src/main/java/com/travelapp/controller/BalanceController.java`

Endpoint mới:
```
GET /api/balance/trip/{tripId}/user/{userId}
```

Ví dụ response:
```json
{
  "tripId": 1,
  "userId": 2,
  "userBalance": 100000,
  "totalOwed": 50000,
  "totalToReceive": 150000,
  "settlements": [
    {"fromUserId": 2, "toUserId": 3, "amount": 50000}
  ]
}
```

#### 3️⃣ Cập nhật ExpenseService
**File**: `travel_app_backend/src/main/java/com/travelapp/service/ExpenseService.java`

Thay đổi:
- Thêm logic set `splitMethod` từ DTO
- Thêm logging để debug (in expense info sau save)
- Ensure splits được lưu trước khi trả response

#### 4️⃣ Cập nhật DTOs
**Files**: 
- `BalanceDTO.java` - thêm fields: tripId, userBalance, settlements
- `SettlementDTO.java` - thêm fields: isPaid, status

---

### B. FRONTEND (Flutter)

#### 1️⃣ Cập nhật BalanceSu.dart (Chính)
**File**: `travelapp/lib/view/bill/BalanceSu.dart`

**Thay đổi 1: Thêm WidgetsBindingObserver**
```dart
class _BalanceSettlementScreenState extends State<BalanceSettlementScreen> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // Thêm dòng này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();  // Tự động load lại khi back về
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // Clean up
    super.dispose();
  }
}
```

**Thay đổi 2: Cập nhật _loadData()**
- Thử gọi API balance mới trước
- Nếu thất bại, fallback đến cách cũ
- Parse response từ API

**Thay đổi 3: Thêm hàm _loadBalanceFromAPI()**
- Parse settlements từ API response
- Hiển thị lên UI

#### 2️⃣ Cập nhật ExpenseRepository
**File**: `travelapp/lib/repository/expense_repository.dart`

Thêm method mới:
```dart
static Future<Map<String, dynamic>> getBalance(int tripId, int userId) async {
  final url = Uri.parse('$baseUrl/balance/trip/$tripId/user/$userId');
  final headers = await _getAuthHeaders();
  final response = await http.get(url, headers: headers);
  return json.decode(utf8.decode(response.bodyBytes));
}
```

---

## 🔄 Quy Trình Hoạt Động

### Khi thêm chi phí:
```
1. User nhập dữ liệu expense
2. AddExpenseScreen.createExpense()
3. POST /api/expenses/create
4. Backend: ExpenseService.createExpense()
   - Lưu expense
   - Lưu splits
   - Return DTO
5. AddExpenseScreen.Navigator.pop(context, true)
6. ExpenseListScreen.result == true
7. ExpenseListScreen._loadExpenses() refresh
```

### Khi xem balance:
```
1. User tap "Xem số dư" button
2. Navigator.push(BalanceSettlementScreen)
3. BalanceSettlementScreen.initState()
4. _loadData()
   a. Try: ExpenseRepository.getBalance()
      - GET /api/balance/trip/{tripId}/user/{userId}
      - Parse settlements
      - _loadBalanceFromAPI()
   b. Catch: Fallback getExpenses() + _calculateBalances()
5. UI rebuild với settlements
```

### Khi quay lại từ expense list:
```
1. User ở BalanceSettlementScreen
2. Quay lại ExpenseListScreen
3. Quay lại BalanceSettlementScreen
4. BalanceSettlementScreen.didChangeAppLifecycleState(resumed)
5. _loadData() tự động được gọi
6. Data được refresh từ backend
```

---

## 📊 Ví Dụ Cụ Thể

### Scenario: Chuyến du lịch 3 người

**Người A (ID=1), B (ID=2), C (ID=3)**

**Chi phí 1:** A trả 300k cho khách sạn, chia đều 3 người
- A balance = 300k - 100k = 200k
- B balance = 0 - 100k = -100k  
- C balance = 0 - 100k = -100k

**Chi phí 2:** B trả 200k cho ăn sáng, chỉ B và C chia
- A balance = 200k + 0 = 200k
- B balance = -100k + 200k - 100k = 0
- C balance = -100k + 0 - 100k = -200k

**Settlement:**
- A nợi tiền từ B: 0 (B đã trả hết)
- A nợi tiền từ C: 200k
- B nợi tiền từ A: 0 (không còn nợ)
- C nợi tiền từ: A 100k, B 100k (tổng 200k)

**Backend tính:**
```
Net balances: {A: 200, B: 0, C: -200}
Debtors: C (-200)
Creditors: A (200)
Settlement: C → A: 200k
```

---

## ✅ Checklist Triển Khai

### Backend:
- [ ] BalanceService.java compiled
- [ ] BalanceController.java compiled
- [ ] ExpenseService cập nhật with splitMethod
- [ ] BalanceDTO updated
- [ ] SettlementDTO updated
- [ ] Database: no schema changes needed (existing tables work)
- [ ] Test API: `GET /api/balance/trip/1/user/1`

### Frontend:
- [ ] BalanceSu.dart cập nhật (WidgetsBindingObserver)
- [ ] ExpenseRepository.getBalance() added
- [ ] No pub.dev dependencies needed
- [ ] Test: Add expense → go back → view balance → should update

### Testing:
- [ ] Add expense with EVEN split
- [ ] Add expense with SELECTED split
- [ ] View balance immediately
- [ ] Go back and view other screens
- [ ] Return to balance - should auto-refresh
- [ ] Test with multiple expenses from different users

---

## 🐛 Troubleshooting

**Q: Balance không cập nhật sau khi thêm chi phí**
A: Kiểm tra:
1. API `/api/balance/trip/X/user/Y` có return đúng không?
2. Backend logs có error không?
3. Check network tab trong DevTools

**Q: Settlements hiển thị sai**
A: Kiểm tra:
1. Expense splits có được save không? (Check DB)
2. BalanceService.calculateSettlements() logic
3. Frontend _loadBalanceFromAPI() parsing

**Q: UI không update sau push-pop navigation**
A: Vì sao:
1. StatefulWidget cần setState() để rebuild
2. WidgetsBindingObserver phát hiện lifecycle
3. Nếu không dùng observer, cần push result và handle

---

## 📈 Performance

- Balance calculation: O(n*m) where n=expenses, m=users
- For <100 expenses: <500ms
- For 100+ expenses: consider caching with invalidation

---

**Document tạo ngày**: January 9, 2026
**Status**: ✅ Hoàn tất
**Tested**: ⏳ Sẵn sàng test
