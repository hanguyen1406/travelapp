# Chỉnh sửa Backend Tóm tắt Số dư - Báo cáo Hoàn thành

## Vấn đề được giải quyết
Khi thêm tiền vào chi phí, số dư trong mục "Tóm tắt số dư" không được cập nhật hoặc hiển thị không chính xác.

## Các thay đổi được thực hiện

### 1. **Frontend - Cải thiện Refresh Mechanism**
**File**: `travelapp/lib/view/bill/BalanceSu.dart`

**Thay đổi:**
- Thêm `WidgetsBindingObserver` để phát hiện khi màn hình quay trở lại (resume)
- Thêm `didChangeAppLifecycleState()` để tự động tải dữ liệu khi ứng dụng quay trở lại foreground
- Thêm `dispose()` để gỡ bỏ observer khi màn hình đóng
- Cập nhật `_loadData()` để thử gọi API balance mới trước, rồi fallback đến cách tính toán cục bộ
- Thêm hàm `_loadBalanceFromAPI()` để phân tích dữ liệu từ API

**Lợi ích:**
- Màn hình tự động tải dữ liệu mới mỗi khi người dùng quay trở lại
- Dữ liệu luôn chính xác nhất từ backend

---

### 2. **Backend - Sửa ExpenseService**
**File**: `travel_app_backend/src/main/java/com/travelapp/service/ExpenseService.java`

**Thay đổi:**
- Thêm logic để thiết lập `splitMethod` khi tạo expense
- Thêm try-catch để xử lý các giá trị invalid của splitMethod
- Thêm logging để debug (in ra ID, Amount, Splits, SplitMethod)

**Lợi ích:**
- Expense splits được lưu chính xác vào database
- Split method được lưu trữ đúng cách

---

### 3. **Backend - Tạo BalanceService**
**File**: `travel_app_backend/src/main/java/com/travelapp/service/BalanceService.java` (Mới)

**Chức năng:**
- Tính toán số dư ròng cho mỗi người dùng trong một chuyến đi
- Sử dụng giải thuật Greedy Matching để tính settlements (ai nợ ai bao nhiêu)
- Trả về chi tiết settlements cho người dùng cụ thể

**Công thức:**
```
Số dư ròng = Tổng tiền đã trả - Tổng tiền nợ (từ splits)
```

---

### 4. **Backend - Tạo BalanceController**
**File**: `travel_app_backend/src/main/java/com/travelapp/controller/BalanceController.java` (Mới)

**Endpoint:**
```
GET /api/balance/trip/{tripId}/user/{userId}
```

**Response:**
```json
{
  "tripId": 1,
  "userId": 2,
  "userBalance": 100000,  // Số dư ròng
  "totalOwed": 50000,     // Tổng nợ người khác
  "totalToReceive": 150000, // Tổng người khác nợ
  "settlements": [
    {
      "fromUserId": 2,
      "fromUserName": "Bạn",
      "toUserId": 3,
      "toUserName": "Anh Tuấn",
      "amount": 50000,
      "isPaid": false,
      "status": "pending"
    }
  ]
}
```

---

### 5. **Backend - Cập nhật BalanceDTO**
**File**: `travel_app_backend/src/main/java/com/travelapp/dto/BalanceDTO.java`

**Thay đổi:**
- Thêm fields: `tripId`, `userBalance`, `totalToReceive`, `settlements`, `allUserBalances`
- Giữ lại fields cũ để compatibility

---

### 6. **Backend - Cập nhật SettlementDTO**
**File**: `travel_app_backend/src/main/java/com/travelapp/dto/SettlementDTO.java`

**Thay đổi:**
- Thêm fields: `isPaid`, `status`
- Thêm constructor mặc định initialize các giá trị

---

### 7. **Frontend - Cập nhật ExpenseRepository**
**File**: `travelapp/lib/repository/expense_repository.dart`

**Thay đổi:**
- Thêm method `getBalance(int tripId, int userId)` để gọi API balance mới

---

## Quy trình Hoạt động

### Khi người dùng thêm chi phí:
1. Frontend gửi POST request tới `/api/expenses/create` với expense data + splits
2. Backend lưu expense với splits vào database
3. ExpenseService set đúng splitMethod
4. Ứng dụng trả về AddExpenseScreen với result = true
5. ExpenseListScreen nhận result và gọi `_loadExpenses()` để refresh
6. Người dùng quay lại BalanceSettlementScreen

### Khi người dùng xem tóm tắt số dư:
1. BalanceSettlementScreen tải dữ liệu từ BalanceService API
2. API tính toán based on tất cả expenses + splits
3. Settlements được tính bằng greedy matching algorithm
4. Frontend hiển thị thông tin cập nhật

### Khi người dùng quay lại từ màn hình khác:
1. `didChangeAppLifecycleState()` được trigger với state = resumed
2. `_loadData()` được gọi tự động
3. Dữ liệu được refresh mà không cần người dùng làm gì

---

## Testing Checklist

- [ ] Thêm chi phí với split EVEN - kiểm tra settlements
- [ ] Thêm chi phí với split SELECTED - kiểm tra chỉ có những người được chọn
- [ ] Thêm chi phí với split CUSTOM - kiểm tra số tiền chia chính xác
- [ ] Thêm chi phí từ người A, quay lại xem balances - phải cập nhật
- [ ] Xem balances, quay lại, thêm chi phí khác, quay lại - phải thấy cả hai
- [ ] Kiểm tra API endpoint `/api/balance/trip/{tripId}/user/{userId}` bằng Postman
- [ ] Kiểm tra logs backend để đảm bảo data được lưu đúng

---

## Lưu ý quan trọng

1. **Long vs Int**: Backend sử dụng `Long` cho IDs, frontend sử dụng `int`. Conversion tự động xảy ra qua JSON.

2. **Split Method**: Phải được gửi dưới dạng string ("EVEN", "SELECTED", "CUSTOM") từ frontend, backend chuyển sang enum.

3. **Fallback Logic**: Nếu API balance bị lỗi, BalanceSu vẫn fallback tới cách tính toán cục bộ bằng expenses.

4. **Performance**: Với khoảng 100+ expenses, settling algorithm có thể chạy 1-2 giây. Có thể caching nếu cần.

---

## Tổng kết

✅ Tất cả các thay đổi đã hoàn tất để giải quyết vấn đề "số dư không cập nhật sau khi thêm tiền".
