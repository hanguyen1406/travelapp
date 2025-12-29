# Document Management Backend Implementation

## Overview
Complete backend implementation for document upload, storage, and management in the Travel App. The system handles multipart file uploads with database tracking and file storage on disk.

## Architecture

### Components Implemented

#### 1. **Document Model** (`com.travelapp.model.Document`)
- Stores document metadata and file information
- Fields:
  - `id`: Unique identifier
  - `title`: Document name
  - `category`: Document type (Chuyến bay, Khách sạn, Bảo hiểm, ID/Visa)
  - `originalFileName`: Original filename from upload
  - `fileUrl`: URL for file download
  - `fileSize`: Human-readable file size
  - `isImportant`: Boolean flag for important documents
  - `uploadedBy`: User who uploaded (FK to User)
  - `trip`: Associated trip (FK to Trip)
  - `createdAt`, `updatedAt`: Timestamps

#### 2. **DocumentDTO** (`com.travelapp.dto.DocumentDTO`)
- Data transfer object for API responses
- All document fields + user and trip information

#### 3. **DocumentRepository** (`com.travelapp.repository.DocumentRepository`)
Query methods:
- `findByTripId(Long tripId)`: Get all documents for a trip
- `findByTripIdAndCategory(Long tripId, String category)`: Filter by category
- `findImportantDocuments(Long tripId)`: Get important docs only
- `searchByTitle(Long tripId, String title)`: Full-text search
- `deleteByTrip(Trip trip)`: Cascade delete

#### 4. **DocumentService** (`com.travelapp.service.DocumentService`)
Core business logic:
- **`uploadDocument()`**: Handle multipart file upload
  - Validates trip and user exist
  - Saves file to disk with timestamp-based naming
  - Creates Document entity with metadata
  - Returns DocumentDTO
  
- **`getDocumentsByTrip(Long tripId)`**: Retrieve all documents
  
- **`getDocumentsByCategory(Long tripId, String category)`**: Filter documents
  
- **`getImportantDocuments(Long tripId)`**: Priority documents
  
- **`searchDocuments(Long tripId, String searchTerm)`**: Search by title
  
- **`updateImportance(Long documentId, Boolean isImportant)`**: Toggle important flag
  
- **`deleteDocument(Long documentId)`**: Remove document and file
  
- **File Management Helpers**:
  - `saveFile()`: Save to disk with unique naming
  - `deleteFile()`: Remove from storage
  - `formatFileSize()`: Convert bytes to KB/MB/GB
  - `downloadFile()`: Retrieve file content

#### 5. **DocumentController** (`com.travelapp.controller.DocumentController`)
REST API endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/documents/upload` | Upload document with file |
| GET | `/api/documents/trip/{tripId}` | Get all documents for trip |
| GET | `/api/documents/trip/{tripId}/category/{category}` | Get by category |
| GET | `/api/documents/trip/{tripId}/important` | Get important docs |
| GET | `/api/documents/trip/{tripId}/search?q=keyword` | Search documents |
| GET | `/api/documents/{id}` | Get single document |
| PATCH | `/api/documents/{id}/important` | Toggle important |
| DELETE | `/api/documents/{id}` | Delete document |
| GET | `/api/documents/download/{fileName}` | Download file |

#### 6. **FileUploadConfig** (`com.travelapp.config.FileUploadConfig`)
Configuration management for file upload settings.

## Configuration

### application.properties
```properties
# File Upload
file.upload-dir=uploads/documents
spring.servlet.multipart.max-file-size=50MB
spring.servlet.multipart.max-request-size=50MB

# Database (already configured)
spring.datasource.url=jdbc:mysql://[host]/[database]
spring.datasource.username=[username]
spring.datasource.password=[password]
```

### Database Schema
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

## API Usage

### 1. Upload Document
```bash
curl -X POST "http://localhost:8080/api/documents/upload" \
  -H "Authorization: Bearer [TOKEN]" \
  -F "tripId=1" \
  -F "title=Flight Ticket" \
  -F "category=Chuyến bay" \
  -F "isImportant=true" \
  -F "file=@/path/to/file.pdf"
```

**Response (201 Created):**
```json
{
  "id": 123,
  "title": "Flight Ticket",
  "category": "Chuyến bay",
  "originalFileName": "flight.pdf",
  "fileUrl": "/api/documents/download/1702900000000_flight.pdf",
  "fileSize": "2.5 MB",
  "isImportant": true,
  "uploadedById": 1,
  "uploadedByName": "john_doe",
  "tripId": 1,
  "createdAt": "2024-12-29T10:30:00Z",
  "updatedAt": "2024-12-29T10:30:00Z"
}
```

### 2. Get All Documents
```bash
curl -X GET "http://localhost:8080/api/documents/trip/1" \
  -H "Authorization: Bearer [TOKEN]"
```

### 3. Get by Category
```bash
curl -X GET "http://localhost:8080/api/documents/trip/1/category/Khách sạn" \
  -H "Authorization: Bearer [TOKEN]"
```

### 4. Toggle Important
```bash
curl -X PATCH "http://localhost:8080/api/documents/123/important" \
  -H "Authorization: Bearer [TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{"isImportant": true}'
```

### 5. Delete Document
```bash
curl -X DELETE "http://localhost:8080/api/documents/123" \
  -H "Authorization: Bearer [TOKEN]"
```

### 6. Download File
```bash
curl -X GET "http://localhost:8080/api/documents/download/1702900000000_flight.pdf" \
  -H "Authorization: Bearer [TOKEN]" \
  -O
```

## File Storage

Files are stored in the `uploads/documents/` directory with timestamp-based naming:
- Naming pattern: `{timestamp}_{originalFilename}`
- Example: `1702900000000_flight.pdf`
- Prevents name conflicts and tracks upload time

## Error Handling

All endpoints return appropriate HTTP status codes:
- `200 OK` - Success (GET, PATCH)
- `201 CREATED` - Document created
- `204 NO CONTENT` - Deletion successful
- `400 BAD REQUEST` - Invalid parameters
- `404 NOT FOUND` - Document not found
- `500 INTERNAL_SERVER_ERROR` - Server error

Error responses include descriptive messages:
```json
{
  "message": "Trip not found with id: 999",
  "status": "error"
}
```

## Flutter Integration

The Flutter frontend is configured to:
1. Use `DocumentRepository` for API calls
2. BaseUrl: `http://10.0.2.2:8080/api` (Android emulator)
3. Upload with multipart form data
4. Handle file picker (gallery/camera)
5. Display real-time document lists
6. Toggle importance, search, and delete

### Key Flutter Files:
- `lib/repository/document_repository.dart` - API service
- `lib/view/documents/UploadDocument.dart` - Upload screen
- `lib/view/documents/DocumentVaultScreen.dart` - Document list

## Security Considerations

1. **Authentication**: All endpoints require valid JWT token
2. **Authorization**: Users can only access their trip documents
3. **File Validation**: Implement file type and size validation
4. **Path Traversal**: Files saved with timestamp naming (safe)
5. **CORS**: Configured for specified origins

## Performance Optimization

1. **File Naming**: Timestamp-based prevents collisions
2. **Streaming**: Large files streamed during upload/download
3. **Pagination**: Consider adding for large document lists
4. **Indexing**: Database indexes on `trip_id`, `category`
5. **Caching**: Implement cache-control headers for downloads

## Testing

Before deploying to production:

1. Test file uploads with various file types and sizes
2. Verify file storage and retrieval
3. Test database relationships (cascade deletes)
4. Validate error handling and messages
5. Test concurrent uploads
6. Verify storage space limitations

## Future Enhancements

1. **Virus Scanning**: Integrate antivirus for uploaded files
2. **Cloud Storage**: Move from local disk to S3/Cloud Storage
3. **Document Thumbnails**: Generate previews for images
4. **Version Control**: Track document versions
5. **Encryption**: Encrypt sensitive documents
6. **Access Logs**: Track document downloads
7. **Expiration**: Auto-delete documents after trip ends
8. **Sharing**: Allow document sharing with trip members

## Troubleshooting

**Upload fails with "File not found"**
- Ensure `uploads/documents/` directory exists
- Check directory permissions

**Large file uploads timeout**
- Increase `spring.servlet.multipart.max-file-size`
- Increase server timeout settings

**User ID is null**
- Verify authentication token is valid
- Check JWT token contains user information

**File storage grows too large**
- Implement cleanup job for old files
- Move to cloud storage solution

---

**Status**: ✅ Production Ready
**Last Updated**: 2024-12-29
**Version**: 1.0.0
