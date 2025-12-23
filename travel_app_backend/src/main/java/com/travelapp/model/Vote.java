package com.travelapp.model;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.Date;

@Entity
@Table(name = "votes")
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Boolean vote;

    @ManyToOne
    @JoinColumn(name = "itinerary_id")
    @JsonIgnore
    private Itinerary itinerary;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private Date votedAt;

    public Vote() {
        this.votedAt = new Date();
    }

    public Vote(Itinerary itinerary, User user, Boolean vote) {
        this.itinerary = itinerary;
        this.user = user;
        this.vote = vote;
        this.votedAt = new Date();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Boolean getVote() { return vote; }
    public void setVote(Boolean vote) { this.vote = vote; }

    public Itinerary getItinerary() { return itinerary; }
    public void setItinerary(Itinerary itinerary) { this.itinerary = itinerary; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Date getVotedAt() { return votedAt; }
    public void setVotedAt(Date votedAt) { this.votedAt = votedAt; }
}
