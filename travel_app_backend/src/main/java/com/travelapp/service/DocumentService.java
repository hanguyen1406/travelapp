package com.travelapp.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.travelapp.dto.DocumentDTO;
import com.travelapp.model.Document;
import com.travelapp.model.Trip;
import com.travelapp.model.User;
import com.travelapp.repository.DocumentRepository;
import com.travelapp.repository.TripRepository;
import com.travelapp.repository.UserRepository;

@Service
public class DocumentService {

    @Autowired
    private DocumentRepository documentRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private UserRepository userRepository;

    @Value("${file.upload-dir:uploads/documents}")
    private String uploadDir;

    /**
     * Upload a document to a trip
     */
    public DocumentDTO uploadDocument(Long tripId, String title, String category, 
                                     Boolean isImportant, MultipartFile file, Long userId) throws IOException {
        // Get trip and user
        Optional<Trip> tripOpt = tripRepository.findById(tripId);
        Optional<User> userOpt = userRepository.findById(userId);

        if (!tripOpt.isPresent()) {
            throw new IllegalArgumentException("Trip not found with id: " + tripId);
        }
        if (!userOpt.isPresent()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }

        Trip trip = tripOpt.get();
        User user = userOpt.get();

        // Save file to disk
        String fileName = saveFile(file);
        String fileUrl = "/api/documents/download/" + fileName;

        // Create document entity
        Document document = new Document();
        document.setName(title); // Store title as name
        document.setCategory(category);
        document.setOriginalFileName(file.getOriginalFilename());
        document.setUrl(fileUrl); // Store URL
        document.setFileSize(formatFileSize(file.getSize()));
        document.setType(file.getContentType()); // Set MIME type
        document.setOfflineAvailable(false); // Default false
        document.setIsImportant(isImportant != null ? isImportant : false);
        document.setUploadedBy(user);
        document.setTrip(trip);
        document.setCreatedAt(new Date());
        document.setUpdatedAt(new Date());

        Document savedDocument = documentRepository.save(document);
        return convertToDTO(savedDocument);
    }

    /**
     * Get all documents for a trip
     */
    public List<DocumentDTO> getDocumentsByTrip(Long tripId) {
        List<Document> documents = documentRepository.findByTripId(tripId);
        return documents.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * Get documents by category
     */
    public List<DocumentDTO> getDocumentsByCategory(Long tripId, String category) {
        List<Document> documents = documentRepository.findByTripIdAndCategory(tripId, category);
        return documents.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * Get important documents
     */
    public List<DocumentDTO> getImportantDocuments(Long tripId) {
        List<Document> documents = documentRepository.findImportantDocuments(tripId);
        return documents.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * Search documents by title
     */
    public List<DocumentDTO> searchDocuments(Long tripId, String searchTerm) {
        List<Document> documents = documentRepository.searchByTitle(tripId, searchTerm);
        return documents.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    /**
     * Get a single document
     */
    public DocumentDTO getDocument(Long documentId) {
        Optional<Document> doc = documentRepository.findById(documentId);
        if (!doc.isPresent()) {
            throw new IllegalArgumentException("Document not found with id: " + documentId);
        }
        return convertToDTO(doc.get());
    }

    /**
     * Update document importance
     */
    public DocumentDTO updateImportance(Long documentId, Boolean isImportant) {
        Optional<Document> docOpt = documentRepository.findById(documentId);
        if (!docOpt.isPresent()) {
            throw new IllegalArgumentException("Document not found with id: " + documentId);
        }

        Document document = docOpt.get();
        document.setIsImportant(isImportant != null ? isImportant : false);
        document.setUpdatedAt(new Date());
        Document updated = documentRepository.save(document);
        return convertToDTO(updated);
    }

    /**
     * Delete a document
     */
    public void deleteDocument(Long documentId) {
        Optional<Document> docOpt = documentRepository.findById(documentId);
        if (!docOpt.isPresent()) {
            throw new IllegalArgumentException("Document not found with id: " + documentId);
        }

        Document document = docOpt.get();
        
        // Delete file from disk
        try {
            String fileName = extractFileNameFromUrl(document.getUrl());
            deleteFile(fileName);
        } catch (IOException e) {
            // Log error but continue with deletion
            System.err.println("Error deleting file: " + e.getMessage());
        }

        documentRepository.deleteById(documentId);
    }

    /**
     * Convert Document to DocumentDTO
     */
    private DocumentDTO convertToDTO(Document document) {
        DocumentDTO dto = new DocumentDTO();
        dto.setId(document.getId());
        dto.setName(document.getName()); // Use name field
        dto.setCategory(document.getCategory());
        dto.setOriginalFileName(document.getOriginalFileName());
        dto.setUrl(document.getUrl()); // Use url field
        dto.setFileSize(document.getFileSize());
        dto.setType(document.getType()); // Set MIME type
        dto.setOfflineAvailable(document.getOfflineAvailable()); // Set offline availability
        dto.setIsImportant(document.getIsImportant());
        dto.setCreatedAt(document.getCreatedAt());
        dto.setUpdatedAt(document.getUpdatedAt());
        
        if (document.getUploadedBy() != null) {
            dto.setUploadedById(document.getUploadedBy().getId());
            dto.setUploadedByName(document.getUploadedBy().getUsername());
        }
        
        if (document.getTrip() != null) {
            dto.setTripId(document.getTrip().getId());
        }
        
        return dto;
    }

    /**
     * Save file to disk
     */
    private String saveFile(MultipartFile file) throws IOException {
        // Create uploads directory if not exists
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique file name
        String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(fileName);

        // Save file
        Files.copy(file.getInputStream(), filePath);
        return fileName;
    }

    /**
     * Delete file from disk
     */
    private void deleteFile(String fileName) throws IOException {
        Path filePath = Paths.get(uploadDir).resolve(fileName);
        if (Files.exists(filePath)) {
            Files.delete(filePath);
        }
    }

    /**
     * Extract file name from URL
     */
    private String extractFileNameFromUrl(String fileUrl) {
        if (fileUrl != null && fileUrl.contains("/")) {
            return fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
        }
        return fileUrl;
    }

    /**
     * Format file size to human readable
     */
    private String formatFileSize(long size) {
        if (size <= 0) return "0 B";
        final String[] units = new String[]{"B", "KB", "MB", "GB", "TB"};
        int digitGroups = (int) (Math.log10(size) / Math.log10(1024));
        return String.format("%.1f %s", size / Math.pow(1024, digitGroups), units[digitGroups]);
    }

    /**
     * Get file for download
     */
    public byte[] downloadFile(String fileName) throws IOException {
        Path filePath = Paths.get(uploadDir).resolve(fileName);
        if (!Files.exists(filePath)) {
            throw new IOException("File not found: " + fileName);
        }
        return Files.readAllBytes(filePath);
    }
}
