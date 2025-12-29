package com.travelapp.dto;

import java.util.Date;

public class DocumentDTO {
    private Long id;
    private String name; // Document name
    private String category;
    private String originalFileName;
    private String url; // File URL
    private String fileSize;
    private String type; // MIME type
    private Boolean offlineAvailable;
    private Boolean isImportant;
    private Long uploadedById;
    private String uploadedByName;
    private Long tripId;
    private Date createdAt;
    private Date updatedAt;

    public DocumentDTO() {}

    public DocumentDTO(Long id, String name, String category, String originalFileName, 
                      String url, String type, Boolean isImportant, Date createdAt) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.originalFileName = originalFileName;
        this.url = url;
        this.type = type;
        this.isImportant = isImportant;
        this.createdAt = createdAt;
        this.offlineAvailable = false;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getOriginalFileName() { return originalFileName; }
    public void setOriginalFileName(String originalFileName) { this.originalFileName = originalFileName; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getFileSize() { return fileSize; }
    public void setFileSize(String fileSize) { this.fileSize = fileSize; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Boolean getOfflineAvailable() { return offlineAvailable; }
    public void setOfflineAvailable(Boolean offlineAvailable) { this.offlineAvailable = offlineAvailable; }

    public Boolean getIsImportant() { return isImportant; }
    public void setIsImportant(Boolean isImportant) { this.isImportant = isImportant; }

    public Long getUploadedById() { return uploadedById; }
    public void setUploadedById(Long uploadedById) { this.uploadedById = uploadedById; }

    public String getUploadedByName() { return uploadedByName; }
    public void setUploadedByName(String uploadedByName) { this.uploadedByName = uploadedByName; }

    public Long getTripId() { return tripId; }
    public void setTripId(Long tripId) { this.tripId = tripId; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}
