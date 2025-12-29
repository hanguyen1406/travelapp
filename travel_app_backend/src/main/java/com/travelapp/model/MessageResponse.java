package com.travelapp.model;

public class MessageResponse {
	private String message;
	private Integer code;
	private String status;

	public MessageResponse(String message) {
		this.message = message;
	}

	public MessageResponse(String status, String message) {
		this.status = status;
		this.message = message;
	}

	public MessageResponse(String message, Integer code) {
		super();
		this.message = message;
		this.code = code;
	}

	public Integer getCode() {
		return code;
	}

	public void setCode(Integer code) {
		this.code = code;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
}
