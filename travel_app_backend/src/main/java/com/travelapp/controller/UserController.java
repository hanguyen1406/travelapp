package com.travelapp.controller;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.travelapp.dto.RoleDTO;
import com.travelapp.dto.UserDTO;
import com.travelapp.dto.UserProfileDTO;
import com.travelapp.model.ERole;
import com.travelapp.model.MessageResponse;
import com.travelapp.model.Role;
import com.travelapp.model.User;
import com.travelapp.service.RoleService;
import com.travelapp.service.UserService;
import java.text.SimpleDateFormat;
import java.util.Date;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/users")
public class UserController {

	String roleName;

	@Autowired
	UserService userService;

	@Autowired
	RoleService roleService;

	@Autowired
	private PasswordEncoder encoder;

	@GetMapping
	public Iterable<UserDTO> getAll(@RequestParam(name = "pageNo") Integer pageNo,
			@RequestParam(name = "pageSize") Integer pageSize, @RequestParam(name = "sortBy") String sortBy,
			@RequestParam(name = "name") String name, @RequestParam(name = "surname") String surname,
			@RequestParam(name = "roleId") String roleId) {
		Pageable pageable = PageRequest.of(pageNo, pageSize, Sort.by(sortBy));
		if (name.equals("") && surname.equals("") && roleId.equals("")) {
			Page<User> userPaged = userService.findAll(pageable);
			Page<UserDTO> userDTO = userPaged.map(user -> {
				Set<RoleDTO> roles = new HashSet<>();
				for (Role role : user.getRoles()) {
					roles.add(new RoleDTO(role.getId(), role.getName()));
				}
				UserDTO dto = new UserDTO(user.getId(), user.getName(), user.getSurname(), user.getUsername(),
						user.getEmail(), user.getPassword(), roles);
				return dto;
			});
			return userDTO.getContent();
		} else {
			Page<User> userPaged = userService.findByNameAndSurname(name, surname, roleId, pageNo, pageSize);
			Page<UserDTO> userDTO = userPaged.map(user -> {
				Set<RoleDTO> roles = new HashSet<>();
				for (Role role : user.getRoles()) {
					roles.add(new RoleDTO(role.getId(), role.getName()));
				}
				UserDTO dto = new UserDTO(user.getId(), user.getName(), user.getSurname(), user.getUsername(),
						user.getEmail(), user.getPassword(), roles);
				return dto;
			});
			return userDTO.getContent();
		}
	}

	@GetMapping("/{username}")
	public ResponseEntity<?> getByUsername(@PathVariable("username") String username) {
		Optional<User> user = userService.findByUsername(username);
		if (user.isPresent()) {
			return new ResponseEntity(user, HttpStatus.OK);
		}
		return new ResponseEntity<UserDTO>(HttpStatus.NOT_FOUND);
	}

	@GetMapping("/id/{id}")
	public ResponseEntity<?> getUserById(@PathVariable("id") Long id) {
		Optional<User> user = userService.findOne(id);
		if (user.isPresent()) {
			User u = user.get();
			Set<RoleDTO> roles = new HashSet<>();
			for (Role role : u.getRoles()) {
				roles.add(new RoleDTO(role.getId(), role.getName()));
			}
			UserDTO dto = new UserDTO(u.getId(), u.getName(), u.getSurname(), u.getUsername(),
					u.getEmail(), u.getPassword(), roles);
			return new ResponseEntity<>(dto, HttpStatus.OK);
		}
		return new ResponseEntity<>(HttpStatus.NOT_FOUND);
	}

	@PostMapping
	@PreAuthorize("hasRole('ADMINISTRATOR')")
	public ResponseEntity<User> create(@RequestBody User user) {
		try {
			user.setName(user.getName().substring(0, 1).toUpperCase() + user.getName().substring(1).toLowerCase());
			user.setSurname(
					user.getSurname().substring(0, 1).toUpperCase() + user.getSurname().substring(1).toLowerCase());
			user.setPassword(encoder.encode(user.getPassword()));
			userService.save(user);
			return new ResponseEntity<User>(user, HttpStatus.CREATED);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<User>(HttpStatus.BAD_REQUEST);
	}

	@PutMapping("/{id}")
	public ResponseEntity<User> update(@PathVariable("id") Long id, @RequestBody User user) {
		User userExsist = userService.findOne(id).orElse(null);
		if (userExsist != null) {
			user.setName(user.getName().substring(0, 1).toUpperCase() + user.getName().substring(1).toLowerCase());
			user.setSurname(
					user.getSurname().substring(0, 1).toUpperCase() + user.getSurname().substring(1).toLowerCase());
			if (user.getPassword() == null || user.getPassword().trim() == "") {
				user.setPassword(userExsist.getPassword());
			} else {
				user.setPassword(encoder.encode(user.getPassword()));
			}
			userService.save(user);
			return new ResponseEntity<User>(user, HttpStatus.OK);
		}
		return new ResponseEntity<User>(HttpStatus.NOT_FOUND);
	}

	@DeleteMapping("/{id}")
	@PreAuthorize("hasRole('ADMINISTRATOR')")
	public ResponseEntity<User> delete(@PathVariable("id") Long id) {
		if (userService.findOne(id).isPresent()) {
			userService.delete(id);
			return new ResponseEntity<User>(HttpStatus.OK);
		}
		return new ResponseEntity<User>(HttpStatus.NOT_FOUND);
	}

	@GetMapping("/checkEmail/{userId}/{mail}")
	// @PreAuthorize("hasRole('ADMINISTRATOR')")
	public ResponseEntity<?> checkEmail(@PathVariable("userId") String userId, @PathVariable("mail") String mail) {
		if (userService.existsByEmail(mail) == true) {
			if (!userId.equals("null")) {
				Optional<User> user = userService.findOne(Long.parseLong(userId));
				if (!mail.equals(user.get().getEmail())) {
					return ResponseEntity.badRequest().body(new MessageResponse("Error: E-Mail is already taken!"));
				}
			} else {
				return ResponseEntity.badRequest().body(new MessageResponse("Error: E-Mail is already taken!"));
			}
		}
		return ResponseEntity.ok(new MessageResponse("E-Mail is free!"));
	}

	@GetMapping("/checkUsername/{userId}/{username}")
	// @PreAuthorize("hasRole('ADMINISTRATOR')")
	public ResponseEntity<?> checkUsername(@PathVariable("userId") String userId,
			@PathVariable("username") String username) {
		if (userService.existsByUsername(username) == true) {
			if (!userId.equals("null")) {
				Optional<User> user = userService.findOne(Long.parseLong(userId));
				if (!username.equals(user.get().getUsername())) {
					return ResponseEntity.badRequest().body(new MessageResponse("Error: Username đã tồn tại!"));
				}
			} else {
				return ResponseEntity.badRequest().body(new MessageResponse("Error: Username đã tồn tại!"));
			}
		}
		return ResponseEntity.ok(new MessageResponse("Username is free!"));
	}

	@GetMapping("/countUser")
	public int countUser(@RequestParam(name = "name") String name, @RequestParam(name = "surname") String surname,
			@RequestParam(name = "roleId") String roleId) {
		return userService.countUser(name, surname, roleId);
	}

	@GetMapping("/profile/{username}")
	public ResponseEntity<?> getUserProfile(@PathVariable("username") String username) {
		Optional<User> user = userService.findByUsername(username);
		if (user.isPresent()) {
			User foundUser = user.get();
			// Format join date
			String joinDate = "Tham gia từ tháng 1 năm 2024";
			if (foundUser.getCreatedAt() != null) {
				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
				joinDate = "Tham gia từ: " + sdf.format(foundUser.getCreatedAt());
			}

			// Get statistics from trips (assuming trips have userId and status)
			int totalTrips = userService.getTotalTripsByUser(foundUser.getId());
			int completedTrips = userService.getCompletedTripsByUser(foundUser.getId());
			int ongoingTrips = totalTrips - completedTrips;
			int totalCountries = userService.getTotalCountriesByUser(foundUser.getId());
			int totalCities = userService.getTotalCitiesByUser(foundUser.getId());

			UserProfileDTO profileDTO = new UserProfileDTO(
					foundUser.getId(),
					foundUser.getName(),
					foundUser.getEmail(),
					foundUser.getUsername(),
					foundUser.getPhone(),
					joinDate,
					totalTrips,
					totalCountries,
					totalCities,
					ongoingTrips,
					completedTrips);

			return new ResponseEntity<>(profileDTO, HttpStatus.OK);
		}
		return new ResponseEntity<>(new MessageResponse("Người dùng không tìm thấy!"), HttpStatus.NOT_FOUND);
	}

	@GetMapping("/search")
	public ResponseEntity<java.util.List<UserDTO>> searchUsers(@RequestParam("query") String query) {
		java.util.List<User> users = userService.searchUsers(query);
		java.util.List<UserDTO> userDTOs = new java.util.ArrayList<>();
		for (User user : users) {
			Set<RoleDTO> roles = new HashSet<>();
			for (Role role : user.getRoles()) {
				roles.add(new RoleDTO(role.getId(), role.getName()));
			}
			userDTOs.add(new UserDTO(user.getId(), user.getName(), user.getSurname(), user.getUsername(),
					user.getEmail(), user.getPassword(), roles));
		}
		return ResponseEntity.ok(userDTOs);
	}

}
