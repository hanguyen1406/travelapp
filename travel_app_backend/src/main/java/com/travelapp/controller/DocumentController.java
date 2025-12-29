package com.travelapp.controller;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.travelapp.dto.DocumentDTO;
import com.travelapp.model.MessageResponse;
import com.travelapp.model.User;
import com.travelapp.repository.UserRepository;
import com.travelapp.service.DocumentService;

@RestController
@RequestMapping("/api/documents")
@CrossOrigin(origins = "*")
public class DocumentController {

    @Autowired
    private DocumentService documentService;

    @Autowired
    private UserRepository userRepository;

    /**
     * Upload a document to a trip
     * POST /api/documents/upload
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadDocument(
            @RequestParam("tripId") Long tripId,
            @RequestParam("title") String title,
            @RequestParam("category") String category,
            @RequestParam(value = "isImportant", defaultValue = "false") Boolean isImportant,
            @RequestParam("file") MultipartFile file,
            Authentication authentication) {
        try {
            // Validate file
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body(
                        new MessageResponse("error", "File is required"));
            }

            if (file.getSize() > 52428800) { // 50MB
                return ResponseEntity.badRequest().body(
                        new MessageResponse("error", "File size exceeds 50MB limit"));
            }

            // Get current user from authentication
            Long userId = null;
            if (authentication != null && authentication.getPrincipal() instanceof UserDetails) {
                UserDetails userDetails = (UserDetails) authentication.getPrincipal();
                Optional<User> userOpt = userRepository.findByUsername(userDetails.getUsername());
                if (userOpt.isPresent()) {
                    userId = userOpt.get().getId();
                }
            }

            // Fallback to user ID 1 if authentication fails (development only)
            if (userId == null) {
                userId = 1L;
            }

            DocumentDTO documentDTO = documentService.uploadDocument(
                    tripId, title, category, isImportant, file, userId);

            return ResponseEntity.status(HttpStatus.CREATED).body(documentDTO);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(
                    new MessageResponse("error", e.getMessage()));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to upload file: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "An error occurred: " + e.getMessage()));
        }
    }

    /**
     * Get all documents for a trip
     * GET /api/documents/trip?tripId={tripId}
     */
    @GetMapping("/trip")
    public ResponseEntity<?> getDocumentsByTrip(@RequestParam("tripId") Long tripId) {
        try {
            List<DocumentDTO> documents = documentService.getDocumentsByTrip(tripId);
            return ResponseEntity.ok(documents);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to fetch documents: " + e.getMessage()));
        }
    }

    /**
     * Get documents by category
     * GET /api/documents/category?tripId={tripId}&category={category}
     */
    @GetMapping("/category")
    public ResponseEntity<?> getDocumentsByCategory(
            @RequestParam("tripId") Long tripId,
            @RequestParam("category") String category) {
        try {
            List<DocumentDTO> documents = documentService.getDocumentsByCategory(tripId, category);
            return ResponseEntity.ok(documents);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to fetch documents: " + e.getMessage()));
        }
    }

    /**
     * Get important documents
     * GET /api/documents/important?tripId={tripId}
     */
    @GetMapping("/important")
    public ResponseEntity<?> getImportantDocuments(@RequestParam("tripId") Long tripId) {
        try {
            List<DocumentDTO> documents = documentService.getImportantDocuments(tripId);
            return ResponseEntity.ok(documents);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to fetch documents: " + e.getMessage()));
        }
    }

    /**
     * Search documents by title
     * GET /api/documents/search?tripId={tripId}&q=keyword
     */
    @GetMapping("/search")
    public ResponseEntity<?> searchDocuments(
            @RequestParam("tripId") Long tripId,
            @RequestParam("q") String searchTerm) {
        try {
            List<DocumentDTO> documents = documentService.searchDocuments(tripId, searchTerm);
            return ResponseEntity.ok(documents);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to search documents: " + e.getMessage()));
        }
    }

    /**
     * Get a single document
     * GET /api/documents/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getDocument(@PathVariable Long id) {
        try {
            DocumentDTO document = documentService.getDocument(id);
            return ResponseEntity.ok(document);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to fetch document: " + e.getMessage()));
        }
    }

    /**
     * Update document importance
     * PATCH /api/documents/{id}/important
     */
    @PatchMapping("/{id}/important")
    public ResponseEntity<?> updateImportance(
            @PathVariable Long id,
            @RequestBody ImportanceRequest request) {
        try {
            DocumentDTO document = documentService.updateImportance(id, request.isImportant);
            return ResponseEntity.ok(document);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to update document: " + e.getMessage()));
        }
    }

    /**
     * Delete a document
     * DELETE /api/documents/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteDocument(@PathVariable Long id) {
        try {
            documentService.deleteDocument(id);
            return ResponseEntity.ok(new MessageResponse("success", "Document deleted successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to delete document: " + e.getMessage()));
        }
    }

    /**
     * Download a document file
     * GET /api/documents/download/{fileName}
     */
    @GetMapping("/download/{fileName}")
    public ResponseEntity<?> downloadFile(@PathVariable String fileName) {
        try {
            byte[] fileContent = documentService.downloadFile(fileName);
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + fileName + "\"")
                    .body(fileContent);
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    new MessageResponse("error", "Failed to download file: " + e.getMessage()));
        }
    }

    /**
     * Inner class for importance request
     */
    public static class ImportanceRequest {
        private Boolean isImportant;

        public Boolean getIsImportant() {
            return isImportant;
        }

        public void setIsImportant(Boolean isImportant) {
            this.isImportant = isImportant;
        }

        public boolean isImportant() {
            return isImportant != null ? isImportant : false;
        }
    }
}
