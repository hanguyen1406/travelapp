package com.travelapp.dto;

import java.io.Serializable;

public class UserProfileDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String name;
    private String email;
    private String username;
    private String phone;
    private String joinDate;
    private int totalTrips;
    private int totalCountries;
    private int totalCities;
    private int ongoingTrips;
    private int completedTrips;

    public UserProfileDTO() {
    }

    public UserProfileDTO(Long id, String name, String email, String username, 
                          String phone, String joinDate, int totalTrips, 
                          int totalCountries, int totalCities, int ongoingTrips, 
                          int completedTrips) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.username = username;
        this.phone = phone;
        this.joinDate = joinDate;
        this.totalTrips = totalTrips;
        this.totalCountries = totalCountries;
        this.totalCities = totalCities;
        this.ongoingTrips = ongoingTrips;
        this.completedTrips = completedTrips;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getJoinDate() {
        return joinDate;
    }

    public void setJoinDate(String joinDate) {
        this.joinDate = joinDate;
    }

    public int getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(int totalTrips) {
        this.totalTrips = totalTrips;
    }

    public int getTotalCountries() {
        return totalCountries;
    }

    public void setTotalCountries(int totalCountries) {
        this.totalCountries = totalCountries;
    }

    public int getTotalCities() {
        return totalCities;
    }

    public void setTotalCities(int totalCities) {
        this.totalCities = totalCities;
    }

    public int getOngoingTrips() {
        return ongoingTrips;
    }

    public void setOngoingTrips(int ongoingTrips) {
        this.ongoingTrips = ongoingTrips;
    }

    public int getCompletedTrips() {
        return completedTrips;
    }

    public void setCompletedTrips(int completedTrips) {
        this.completedTrips = completedTrips;
    }

    @Override
    public String toString() {
        return "UserProfileDTO{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", username='" + username + '\'' +
                ", phone='" + phone + '\'' +
                ", joinDate='" + joinDate + '\'' +
                ", totalTrips=" + totalTrips +
                ", totalCountries=" + totalCountries +
                ", totalCities=" + totalCities +
                ", ongoingTrips=" + ongoingTrips +
                ", completedTrips=" + completedTrips +
                '}';
    }
}
