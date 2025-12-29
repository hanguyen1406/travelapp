package com.travelapp.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.travelapp.model.Document;
import com.travelapp.model.Trip;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {

    /**
     * Find all documents for a specific trip
     */
    List<Document> findByTrip(Trip trip);

    /**
     * Find all documents by trip ID
     */
    @Query("SELECT d FROM Document d WHERE d.trip.id = :tripId ORDER BY d.createdAt DESC")
    List<Document> findByTripId(@Param("tripId") Long tripId);

    /**
     * Find documents by trip and category
     */
    @Query("SELECT d FROM Document d WHERE d.trip.id = :tripId AND d.category = :category ORDER BY d.createdAt DESC")
    List<Document> findByTripIdAndCategory(@Param("tripId") Long tripId, @Param("category") String category);

    /**
     * Find important documents for a trip
     */
    @Query("SELECT d FROM Document d WHERE d.trip.id = :tripId AND d.isImportant = true ORDER BY d.createdAt DESC")
    List<Document> findImportantDocuments(@Param("tripId") Long tripId);

    /**
     * Find documents by title containing a string
     */
    @Query("SELECT d FROM Document d WHERE d.trip.id = :tripId AND d.name LIKE %:title% ORDER BY d.createdAt DESC")
    List<Document> searchByTitle(@Param("tripId") Long tripId, @Param("title") String title);

    /**
     * Delete all documents for a trip
     */
    void deleteByTrip(Trip trip);
}
