# Hướng Dẫn Cách Sử Dụng ProfileScreen & API Thống Kê Người Dùng

## 📱 Frontend - Flutter

### 1. ProfileScreen.dart
Giao diện hồ sơ người dùng hiển thị:
- **Thông tin cá nhân**: Tên, email, ngày tham gia
- **Thống kê chuyến đi**: 
  - Tổng chuyến đi
  - Tổng số quốc gia
  - Tổng số thành phố
  - Chuyến đi đang diễn ra
  - Chuyến đi đã hoàn thành
- **Menu**: Cài đặt tài khoản, Thông báo, Trung tâm trợ giúp
- **Đăng xuất**: Nút đăng xuất

### 2. Sử Dụng
```dart
// Trong main.dart hoặc router
import 'lib/view/user/ProfileScreen.dart';

// Điều hướng đến ProfileScreen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfileScreen()),
);
```

### 3. Cập Nhật AuthViewModel
- Thêm method `getUserProfile()` để lấy thông tin hồ sơ từ API
- Thêm method `logout()` để đăng xuất

### 4. Cập Nhật LoginResponse
- Thêm model `UserLoginData` để lưu thông tin người dùng
- Thêm thuộc tính `user` để truyền dữ liệu người dùng

---

## 🔧 Backend - Java Spring Boot

### 1. UserProfileDTO.java
DTO chứa thông tin hồ sơ người dùng:
```java
{
  "id": 1,
  "name": "Nguyễn",
  "email": "user@example.com",
  "username": "nguyenuser",
  "phone": "0123456789",
  "joinDate": "Tham gia từ: 01/01/2024",
  "totalTrips": 12,
  "totalCountries": 5,
  "totalCities": 18,
  "ongoingTrips": 2,
  "completedTrips": 10
}
```

### 2. Cập Nhật Itinerary.java
Thêm các field mới:
- `city`: Thành phố
- `destination`: Điểm đến
- `country`: Quốc gia

### 3. Cập Nhật UserRepository
Thêm các query methods:
```java
getTotalTripsByUser(userId)          // Tổng chuyến đi
getCompletedTripsByUser(userId)      // Chuyến đi đã hoàn thành
getTotalCountriesByUser(userId)      // Tổng quốc gia
getTotalCitiesByUser(userId)         // Tổng thành phố
```

### 4. Cập Nhật UserService
Thêm các methods để gọi repository:
```java
getTotalTripsByUser(userId)
getCompletedTripsByUser(userId)
getTotalCountriesByUser(userId)
getTotalCitiesByUser(userId)
```

### 5. Cập Nhật UserController
Thêm endpoint API:
```
GET /api/users/profile/{username}
```

**Response:**
```json
{
  "id": 1,
  "name": "Nguyễn",
  "email": "user@example.com",
  "username": "nguyenuser",
  "phone": "0123456789",
  "joinDate": "Tham gia từ: 01/01/2024",
  "totalTrips": 12,
  "totalCountries": 5,
  "totalCities": 18,
  "ongoingTrips": 2,
  "completedTrips": 10
}
```

---

## 🔗 Luồng Hoạt Động

1. **Người dùng mở ProfileScreen**
   ↓
2. **ProfileScreen gọi `_loadUserProfile()`**
   ↓
3. **AuthViewModel.getUserProfile() được gọi**
   ↓
4. **API request: GET /api/users/profile/{username}**
   ↓
5. **UserController xử lý request**
   ↓
6. **Truy vấn database thông tin người dùng và thống kê**
   ↓
7. **Trả về UserProfileDTO**
   ↓
8. **ProfileScreen nhận dữ liệu và hiển thị UI**

---

## ⚙️ Cấu Hình Database

Để sử dụng các field mới trong Itinerary, chạy migration:

```sql
ALTER TABLE itinerary ADD COLUMN city VARCHAR(255);
ALTER TABLE itinerary ADD COLUMN destination VARCHAR(255);
ALTER TABLE itinerary ADD COLUMN country VARCHAR(255);
```

---

## 📝 Ghi Chú

- Thống kê chuyến đi dựa trên `created_by` trong bảng `trips`
- Chuyến đi "đã hoàn thành" là những chuyến có `end_date < NOW()`
- Quốc gia được đếm từ distinct `destination` trong bảng `itinerary`
- Thành phố được đếm từ distinct `city` trong bảng `itinerary`
