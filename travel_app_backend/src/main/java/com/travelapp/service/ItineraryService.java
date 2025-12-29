package com.travelapp.service;

import com.travelapp.dto.ItineraryDTO;
import com.travelapp.model.Itinerary;
import com.travelapp.model.Trip;
import com.travelapp.model.User;
import com.travelapp.model.Vote;
import com.travelapp.repository.ItineraryRepository;
import com.travelapp.repository.TripRepository;
import com.travelapp.repository.UserRepository;
import com.travelapp.repository.VoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ItineraryService {

    @Autowired
    private ItineraryRepository itineraryRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VoteRepository voteRepository;

    public List<ItineraryDTO> getItinerariesByTripId(Long tripId) {
        List<Itinerary> itineraries = itineraryRepository.findByTripId(tripId);
        return itineraries.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @Transactional
    public ItineraryDTO createItinerary(Long tripId, ItineraryDTO dto) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new RuntimeException("Trip not found"));

        Itinerary itinerary = new Itinerary();
        itinerary.setTitle(dto.getTitle());
        itinerary.setDescription(dto.getDescription());
        itinerary.setActivityDate(dto.getActivityDate());
        itinerary.setActivityTime(dto.getActivityTime());
        itinerary.setLocationName(dto.getLocationName());
        itinerary.setLocationLat(dto.getLocationLat());
        itinerary.setLocationLng(dto.getLocationLng());
        itinerary.setDayNumber(dto.getDayNumber());
        itinerary.setTrip(trip);

        if (dto.getSuggestedById() != null) {
            User user = userRepository.findById(dto.getSuggestedById()).orElse(null);
            itinerary.setSuggestedBy(user);
        }

        Itinerary saved = itineraryRepository.save(itinerary);
        return convertToDTO(saved);
    }

    @Transactional
    public ItineraryDTO voteItinerary(Long itineraryId, Long userId, Boolean voteVal) {
        Itinerary itinerary = itineraryRepository.findById(itineraryId)
                .orElseThrow(() -> new RuntimeException("Itinerary not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Vote vote = voteRepository.findByItineraryIdAndUserId(itineraryId, userId)
                .orElse(new Vote());

        if (vote.getId() == null) {
            vote.setItinerary(itinerary);
            vote.setUser(user);
        }
        vote.setVote(voteVal);
        voteRepository.save(vote);

        itinerary = itineraryRepository.findById(itineraryId).get();
        return convertToDTO(itinerary);
    }

    private ItineraryDTO convertToDTO(Itinerary itinerary) {
        ItineraryDTO dto = new ItineraryDTO();
        dto.setId(itinerary.getId());
        dto.setTitle(itinerary.getTitle());
        dto.setDescription(itinerary.getDescription());
        dto.setActivityDate(itinerary.getActivityDate());
        dto.setActivityTime(itinerary.getActivityTime());
        dto.setLocationName(itinerary.getLocationName());
        dto.setLocationLat(itinerary.getLocationLat());
        dto.setLocationLng(itinerary.getLocationLng());
        dto.setDayNumber(itinerary.getDayNumber());
        dto.setStatus(itinerary.getStatus().name());
        dto.setTripId(itinerary.getTrip().getId());
        dto.setCreatedAt(itinerary.getCreatedAt());

        if (itinerary.getSuggestedBy() != null) {
            dto.setSuggestedById(itinerary.getSuggestedBy().getId());
            dto.setSuggestedByName(itinerary.getSuggestedBy().getUsername());
        }

        dto.setUpVotes(itinerary.getUpVotes());
        dto.setDownVotes(itinerary.getDownVotes());

        return dto;
    }
}
