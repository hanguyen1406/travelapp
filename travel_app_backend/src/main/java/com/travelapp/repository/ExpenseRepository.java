package com.travelapp.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.travelapp.model.Expense;
import com.travelapp.model.Trip;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    /**
     * Find all expenses for a specific trip
     */
    List<Expense> findByTrip(Trip trip);

    /**
     * Find all expenses by trip ID with splits eagerly loaded
     */
    @Query("SELECT DISTINCT e FROM Expense e LEFT JOIN FETCH e.splits WHERE e.trip.id = :tripId ORDER BY e.expenseDate DESC")
    List<Expense> findByTripId(@Param("tripId") Long tripId);

    /**
     * Find expenses by trip and category with splits eagerly loaded
     */
    @Query("SELECT DISTINCT e FROM Expense e LEFT JOIN FETCH e.splits WHERE e.trip.id = :tripId AND e.category = :category ORDER BY e.expenseDate DESC")
    List<Expense> findByTripIdAndCategory(@Param("tripId") Long tripId, @Param("category") String category);

    /**
     * Calculate total expenses for a trip
     */
    @Query("SELECT SUM(e.amount) FROM Expense e WHERE e.trip.id = :tripId")
    Double getTotalExpenseByTripId(@Param("tripId") Long tripId);
}
