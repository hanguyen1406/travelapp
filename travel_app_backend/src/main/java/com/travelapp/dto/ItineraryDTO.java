package com.travelapp.dto;

import java.util.Date;
import java.util.List;

public class ItineraryDTO {
    private Long id;
    private String title;
    private String description;
    private Date activityDate;
    private String activityTime;
    private String locationName;
    private Double locationLat;
    private Double locationLng;
    private Integer dayNumber;
    private String status;
    private Long tripId;
    private Long suggestedById;
    private String suggestedByName;
    private int upVotes;
    private int downVotes;
    private Boolean userVote; // null = chưa vote, true = upvote, false = downvote
    private Date createdAt;

    public ItineraryDTO() {}

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

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getTripId() { return tripId; }
    public void setTripId(Long tripId) { this.tripId = tripId; }

    public Long getSuggestedById() { return suggestedById; }
    public void setSuggestedById(Long suggestedById) { this.suggestedById = suggestedById; }

    public String getSuggestedByName() { return suggestedByName; }
    public void setSuggestedByName(String suggestedByName) { this.suggestedByName = suggestedByName; }

    public int getUpVotes() { return upVotes; }
    public void setUpVotes(int upVotes) { this.upVotes = upVotes; }

    public int getDownVotes() { return downVotes; }
    public void setDownVotes(int downVotes) { this.downVotes = downVotes; }

    public Boolean getUserVote() { return userVote; }
    public void setUserVote(Boolean userVote) { this.userVote = userVote; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
