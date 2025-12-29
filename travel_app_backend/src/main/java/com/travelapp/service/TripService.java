package com.travelapp.service;

import com.travelapp.model.Trip;
import com.travelapp.dto.TripDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TripService {
    @Autowired
    private com.travelapp.repository.TripRepository tripRepository;

    @Autowired
    private com.travelapp.repository.UserRepository userRepository;

    public Trip saveTrip(Trip trip) {
        return tripRepository.save(trip);
    }

    public java.util.List<TripDTO> getAllTrips() {
        return tripRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(java.util.stream.Collectors.toList());
    }

    public java.util.List<TripDTO> getTripsByUserId(Long userId) {
        return tripRepository.findDistinctByCreatedByIdOrMembersId(userId, userId).stream()
                .map(this::convertToDTO)
                .collect(java.util.stream.Collectors.toList());
    }

    public TripDTO getTripById(Long id) {
        Trip trip = tripRepository.findById(id).orElseThrow(() -> new RuntimeException("Trip not found"));
        return convertToDTO(trip);
    }

    public TripDTO addMemberToTrip(Long tripId, String email) {
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new RuntimeException("Trip not found"));
        com.travelapp.model.User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));

        return addMemberToTripInternal(trip, user);
    }

    public TripDTO addMemberToTripById(Long tripId, Long userId) {
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new RuntimeException("Trip not found"));
        com.travelapp.model.User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

        return addMemberToTripInternal(trip, user);
    }

    private TripDTO addMemberToTripInternal(Trip trip, com.travelapp.model.User user) {
        // Check if user is already a member
        if (trip.getMembers().contains(user)) {
            throw new RuntimeException("User is already a member of this trip");
        }

        trip.getMembers().add(user);
        Trip savedTrip = tripRepository.save(trip);
        return convertToDTO(savedTrip);
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

        // Members count & list
        dto.setMemberCount(trip.getMembers() != null ? trip.getMembers().size() : 0);
        if (trip.getMembers() != null) {
            java.util.List<com.travelapp.dto.UserDTO> memberDTOs = trip.getMembers().stream()
                    .map(this::convertUserToDTO)
                    .collect(java.util.stream.Collectors.toList());
            dto.setMembers(memberDTOs);
        }

        return dto;
    }

    private com.travelapp.dto.UserDTO convertUserToDTO(com.travelapp.model.User user) {
        com.travelapp.dto.UserDTO dto = new com.travelapp.dto.UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setName(user.getName());
        dto.setSurname(user.getSurname());
        dto.setEmail(user.getEmail());
        // Do not return password
        return dto;
    }
}
