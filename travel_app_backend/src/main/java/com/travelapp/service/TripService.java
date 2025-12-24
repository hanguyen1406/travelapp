package com.travelapp.service;

import com.travelapp.model.Trip;
import com.travelapp.dto.TripDTO;
import com.travelapp.repository.TripRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TripService {
    @Autowired
    private TripRepository tripRepository;

    public Trip saveTrip(Trip trip) {
        return tripRepository.save(trip);
    }

    public List<Trip> getAllTrips() {
        return tripRepository.findAll();
    }

    public TripDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id).orElseThrow(() -> new RuntimeException("Trip not found"));
        return convertToDTO(trip);
    }

    private TripDTO convertToDTO(Trip trip) {
        TripDTO dto = new TripDTO();
        dto.setId(trip.getId());
        dto.setTripName(trip.getTripName());
        dto.setDescription(trip.getDescription());
        dto.setCoverImage(trip.getCoverImage());
        dto.setStartDate(trip.getStartDate());
        dto.setEndDate(trip.getEndDate());
        dto.setCurrency(trip.getCurrency());
        dto.setCreatedAt(trip.getCreatedAt());

        if (trip.getCreatedBy() != null) {
            dto.setCreatedById(trip.getCreatedBy().getId());
            dto.setCreatedByName(trip.getCreatedBy().getUsername());
        }

        // Set counts
        dto.setItineraryCount(trip.getItineraries() != null ? trip.getItineraries().size() : 0);
        dto.setExpenseCount(trip.getExpenses() != null ? trip.getExpenses().size() : 0);
        dto.setDocumentCount(trip.getDocuments() != null ? trip.getDocuments().size() : 0);
        dto.setChecklistCount(trip.getChecklists() != null ? trip.getChecklists().size() : 0);

        // Members count
        dto.setMemberCount(trip.getMembers() != null ? trip.getMembers().size() : 0);

        return dto;
    }
}
