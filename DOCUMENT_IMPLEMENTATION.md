# 📄 Document Management - Hướng Dẫn Triển Khai

## ✅ Trạng Thái: HOÀN THÀNH

Triển khai hoàn chỉnh cho tính năng quản lý tài liệu (Documents) trong ứng dụng Travel App.

---

## 📁 Cấu Trúc Backend

### Java Spring Boot (`travel_app_backend/`)

#### 1. Model: Document.java
- Lưu trữ thông tin tài liệu và file
- Fields: id, title, category, originalFileName, fileUrl, fileSize, isImportant, uploadedBy, trip, createdAt, updatedAt

#### 2. Repository: DocumentRepository.java
Các query methods:
- `findByTripId(tripId)` - Lấy tất cả tài liệu của chuyến đi
- `findByTripIdAndCategory(tripId, category)` - Lọc theo loại
- `findImportantDocuments(tripId)` - Lấy tài liệu quan trọng
- `searchByTitle(tripId, searchTerm)` - Tìm kiếm theo tên

#### 3. Service: DocumentService.java
Xử lý logic:
- `uploadDocument()` - Tải lên tài liệu (lưu file, lưu DB)
- `getDocumentsByTrip()` - Lấy danh sách tài liệu
- `updateImportance()` - Đánh dấu quan trọng
- `deleteDocument()` - Xóa tài liệu
- Quản lý file: lưu, xóa, tải về

#### 4. Controller: DocumentController.java
REST API endpoints:
- `POST /api/documents/upload` - Tải lên tài liệu
- `GET /api/documents/trip/{tripId}` - Lấy tất cả
- `GET /api/documents/trip/{tripId}/category/{category}` - Lọc theo loại
- `GET /api/documents/trip/{tripId}/important` - Lấy quan trọng
- `GET /api/documents/trip/{tripId}/search?q=keyword` - Tìm kiếm
- `GET /api/documents/{id}` - Lấy một tài liệu
- `PATCH /api/documents/{id}/important` - Cập nhật quan trọng
- `DELETE /api/documents/{id}` - Xóa tài liệu
- `GET /api/documents/download/{fileName}` - Tải file

#### 5. DTO: DocumentDTO.java
- Chứa tất cả thông tin tài liệu để trả về client

#### 6. Config: FileUploadConfig.java
- Cấu hình upload file (thư mục, kích thước tối đa)

---

## 📱 Cấu Trúc Frontend

### Flutter (`travelapp/lib/`)

#### 1. Service: repository/document_repository.dart
- `uploadDocument()` - Tải lên file multipart
- `getDocuments(tripId)` - Lấy danh sách
- `getDocumentsByCategory()` - Lọc theo loại
- `toggleImportant()` - Đánh dấu quan trọng
- `deleteDocument()` - Xóa tài liệu

#### 2. Screens:

**view/documents/UploadDocument.dart**
- Chọn file từ gallery hoặc camera
- Nhập tên tài liệu
- Chọn loại (4 loại: Chuyến bay, Khách sạn, Bảo hiểm, ID/Visa)
- Đánh dấu quan trọng
- Xác thực input
- Hiển thị loading, error, success

**view/documents/DocumentVaultScreen.dart**
- Danh sách tài liệu
- Lọc theo loại
- Tìm kiếm
- Phần tài liệu quan trọng
- Nút thêm tài liệu mới

---

## 🔌 Cấu Hình API

### Base URL
- Emulator Android: `http://10.0.2.2:8080/api`
- Máy vật lý: `http://<IP>:8080/api`
- iOS Simulator: `http://localhost:8080/api`

### Application.properties
```properties
# File Upload
file.upload-dir=uploads/documents
spring.servlet.multipart.max-file-size=50MB
spring.servlet.multipart.max-request-size=50MB
```

---

## 💾 Database Schema

```sql
CREATE TABLE documents (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255),
  category VARCHAR(100),
  original_file_name VARCHAR(255),
  file_url VARCHAR(500),
  file_size VARCHAR(50),
  is_important BOOLEAN DEFAULT false,
  uploaded_by BIGINT,
  trip_id BIGINT,
  created_at DATETIME,
  updated_at DATETIME,
  FOREIGN KEY (uploaded_by) REFERENCES users(id),
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);
```

---

## 📋 Ví Dụ API

### Tải lên tài liệu
```bash
curl -X POST "http://localhost:8080/api/documents/upload" \
  -H "Authorization: Bearer <TOKEN>" \
  -F "tripId=1" \
  -F "title=Vé máy bay" \
  -F "category=Chuyến bay" \
  -F "isImportant=true" \
  -F "file=@ticket.pdf"
```

**Response (201):**
```json
{
  "id": 123,
  "title": "Vé máy bay",
  "category": "Chuyến bay",
  "fileUrl": "/api/documents/download/1702900000000_ticket.pdf",
  "fileSize": "2.5 MB",
  "isImportant": true,
  "createdAt": "2024-12-29T10:30:00Z"
}
```

### Lấy danh sách tài liệu
```bash
curl -X GET "http://localhost:8080/api/documents/trip/1" \
  -H "Authorization: Bearer <TOKEN>"
```

### Lọc theo loại
```bash
curl -X GET "http://localhost:8080/api/documents/trip/1/category/Chuyến bay" \
  -H "Authorization: Bearer <TOKEN>"
```

### Tìm kiếm
```bash
curl -X GET "http://localhost:8080/api/documents/trip/1/search?q=ticket" \
  -H "Authorization: Bearer <TOKEN>"
```

### Đánh dấu quan trọng
```bash
curl -X PATCH "http://localhost:8080/api/documents/123/important" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"isImportant": true}'
```

### Xóa tài liệu
```bash
curl -X DELETE "http://localhost:8080/api/documents/123" \
  -H "Authorization: Bearer <TOKEN>"
```

### Tải file
```bash
curl -X GET "http://localhost:8080/api/documents/download/1702900000000_ticket.pdf" \
  -H "Authorization: Bearer <TOKEN>" \
  -O
```

---

## 🔐 Tính Năng Bảo Mật

- ✅ Xác thực JWT token trên tất cả endpoints
- ✅ Kiểm tra quyền truy cập (users chỉ access tài liệu của trip mình)
- ✅ Đặt tên file theo timestamp (chống trùng lặp)
- ✅ Kiểm tra kích thước file (max 50MB)
- ✅ Validation loại file

---

## 🧪 Danh Sách Kiểm Tra

### Backend
- [ ] Compile không lỗi: `mvn clean compile`
- [ ] Tạo database table (auto via Hibernate)
- [ ] Tạo thư mục: `mkdir -p uploads/documents`
- [ ] Run backend: `mvn spring-boot:run`
- [ ] Test upload file
- [ ] Test list documents
- [ ] Test filter by category
- [ ] Test search
- [ ] Test delete document

### Frontend
- [ ] Compile không lỗi: `flutter run`
- [ ] Chọn file từ gallery
- [ ] Chọn file từ camera
- [ ] Validation: empty title
- [ ] Validation: no file selected
- [ ] Upload thành công
- [ ] Danh sách cập nhật realtime
- [ ] Lọc theo loại
- [ ] Tìm kiếm
- [ ] Xóa tài liệu
- [ ] Đánh dấu quan trọng

### Integration
- [ ] Upload từ Flutter → lưu server
- [ ] File hiển thị trong danh sách
- [ ] Category filter hoạt động
- [ ] Search trả về kết quả đúng
- [ ] Delete xóa cả file lẫn DB record
- [ ] Tải file về từ server

---

## 🚀 Hướng Dẫn Triển Khai

### 1. Chuẩn Bị Backend
```bash
cd travel_app_backend
mvn clean install
mkdir -p uploads/documents
mvn spring-boot:run
```

### 2. Chuẩn Bị Frontend
```bash
cd travelapp
flutter pub get
flutter run
```

### 3. Test Upload
- Mở DocumentVaultScreen
- Bấm nút "+"
- Chọn file từ gallery
- Nhập tên "Test Document"
- Chọn category
- Bấm "Tải lên"
- Kiểm tra danh sách cập nhật

---

## 📚 Tài Liệu Liên Quan

- `travel_app_backend/DOCUMENT_API.md` - Tài liệu API chi tiết
- `lib/repository/document_repository.dart` - Các method API
- `lib/view/documents/UploadDocument.dart` - UI upload
- `lib/view/documents/DocumentVaultScreen.dart` - UI danh sách

---

## 🔧 Xử Lý Sự Cố

### Upload thất bại: "File not found"
**Giải pháp**: Tạo thư mục `mkdir -p uploads/documents`

### API connection refused
**Giải pháp**: Đảm bảo backend đang chạy trên port 8080

### Danh sách rỗng
**Giải pháp**: Kiểm tra network logs, đảm bảo API response đúng

### Lỗi authentication
**Giải pháp**: Kiểm tra JWT token có hợp lệ không

---

## 📝 Ghi Chú Quan Trọng

- File lưu với tên: `{timestamp}_{originalName}` để chống trùng
- Tài liệu được liên kết với User (người upload) và Trip
- Xóa Trip sẽ xóa cascade tất cả documents
- Upload max 50MB mỗi file
- Categories: "Chuyến bay", "Khách sạn", "Bảo hiểm", "ID/Visa"

---

**Trạng Thái**: ✅ Sẵn sàng triển khai
**Cập nhật**: 2024-12-29
**Phiên bản**: 1.0.0
**Người code**: GitHub Copilot
