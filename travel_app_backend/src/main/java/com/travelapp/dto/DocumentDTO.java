package com.travelapp.dto;

import java.util.Date;

public class DocumentDTO {
    private Long id;
    private String name;
    private String originalFileName;
    private String type;
    private String url;
    private String fileSize;
    private Boolean offlineAvailable;
    private Long uploadedById;
    private String uploadedByName;
    private Long tripId;
    private Date createdAt;

    public DocumentDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getOriginalFileName() { return originalFileName; }
    public void setOriginalFileName(String originalFileName) { this.originalFileName = originalFileName; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getFileSize() { return fileSize; }
    public void setFileSize(String fileSize) { this.fileSize = fileSize; }

    public Boolean getOfflineAvailable() { return offlineAvailable; }
    public void setOfflineAvailable(Boolean offlineAvailable) { this.offlineAvailable = offlineAvailable; }

    public Long getUploadedById() { return uploadedById; }
    public void setUploadedById(Long uploadedById) { this.uploadedById = uploadedById; }

    public String getUploadedByName() { return uploadedByName; }
    public void setUploadedByName(String uploadedByName) { this.uploadedByName = uploadedByName; }

    public Long getTripId() { return tripId; }
    public void setTripId(Long tripId) { this.tripId = tripId; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
