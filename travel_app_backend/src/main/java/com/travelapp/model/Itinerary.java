package com.travelapp.model;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "itinerary")
public class Itinerary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private Date activityDate;
    private String activityTime;
    private String locationName;
    private Double locationLat;
    private Double locationLng;
    private Integer dayNumber;
    private String city;
    private String destination;
    private String country;

    @Enumerated(EnumType.STRING)
    private Status status = Status.PENDING;

    @ManyToOne
    @JoinColumn(name = "trip_id")
    @JsonIgnore
    private Trip trip;

    @ManyToOne
    @JoinColumn(name = "suggested_by")
    private User suggestedBy;

    @OneToMany(mappedBy = "itinerary", cascade = CascadeType.ALL)
    private List<Vote> votes;

    private Date createdAt;

    public enum Status {
        PENDING, CONFIRMED
    }

    public Itinerary() {
        this.createdAt = new Date();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getActivityDate() { return activityDate; }
    public void setActivityDate(Date activityDate) { this.activityDate = activityDate; }

    public String getActivityTime() { return activityTime; }
    public void setActivityTime(String activityTime) { this.activityTime = activityTime; }

    public String getLocationName() { return locationName; }
    public void setLocationName(String locationName) { this.locationName = locationName; }

    public Double getLocationLat() { return locationLat; }
    public void setLocationLat(Double locationLat) { this.locationLat = locationLat; }

    public Double getLocationLng() { return locationLng; }
    public void setLocationLng(Double locationLng) { this.locationLng = locationLng; }

    public Integer getDayNumber() { return dayNumber; }
    public void setDayNumber(Integer dayNumber) { this.dayNumber = dayNumber; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public Trip getTrip() { return trip; }
    public void setTrip(Trip trip) { this.trip = trip; }

    public User getSuggestedBy() { return suggestedBy; }
    public void setSuggestedBy(User suggestedBy) { this.suggestedBy = suggestedBy; }

    public List<Vote> getVotes() { return votes; }
    public void setVotes(List<Vote> votes) { this.votes = votes; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public int getUpVotes() {
        if (votes == null) return 0;
        return (int) votes.stream().filter(v -> v.getVote() != null && v.getVote()).count();
    }

    public int getDownVotes() {
        if (votes == null) return 0;
        return (int) votes.stream().filter(v -> v.getVote() != null && !v.getVote()).count();
    }
}
