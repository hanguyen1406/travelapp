package com.travelapp.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.travelapp.model.ERole;
import com.travelapp.model.Role;
import com.travelapp.repository.RoleRepository;

@Service
@Transactional
public class RoleService {
	
	@Autowired
	private RoleRepository roleRepository;
	
	public Iterable<Role> findAll() {
		return roleRepository.findAll();
	}
	
	public Optional<Role> findOne(Long id) {
		return roleRepository.findById(id);
	}
	
	public Optional<Role> findByName(ERole name) {
		return roleRepository.findByName(name);
	}
	
	public Role save(Role role) {
		return roleRepository.save(role);
	}
	
	public void delete(Long id) {
		roleRepository.deleteById(id);
	}
	
	public void delete(Role role) {
		roleRepository.delete(role);
	}
	
	public int countAdministrator() {
		return roleRepository.countAdministrator();
	}
	
}
