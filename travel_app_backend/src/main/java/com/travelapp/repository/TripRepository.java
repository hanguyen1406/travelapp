package com.travelapp.repository;

import com.travelapp.model.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository

public interface TripRepository extends JpaRepository<Trip, Long> {

    java.util.List<Trip> findDistinctByCreatedByIdOrMembersId(Long createdById, Long memberId);
}
