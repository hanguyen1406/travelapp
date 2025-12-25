package com.travelapp.repository;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.travelapp.model.User;

@Repository
public interface UserRepository extends PagingAndSortingRepository<User, Long> {

	@Query(value = "SELECT users.* FROM users WHERE users.username = :username", nativeQuery = true)
	Optional<User> findByUsername(@Param("username") String username);

	@Query(value = "SELECT CASE WHEN COUNT(*) >= 1 THEN 'true' ELSE 'false' END FROM users WHERE users.username = :username", nativeQuery = true)
	Boolean existsByUsername(@Param("username") String username);
	
	@Query(value = "SELECT CASE WHEN COUNT(*) >= 1 THEN 'true' ELSE 'false' END FROM users WHERE users.email = :email", nativeQuery = true)
	Boolean existsByEmail(@Param("email") String email);
	
	 @Query(value = "SELECT COUNT(DISTINCT username) FROM users "
			 + "INNER JOIN user_roles ON users.id = user_roles.user_id "
			 + "WHERE UPPER(users.name) like CONCAT('%',UPPER(:name),'%') and UPPER(users.surname) like CONCAT('%',UPPER(:surname),'%') AND user_roles.role_id LIKE CONCAT('%',:roleId,'%')", nativeQuery = true)
	int countUser(@Param("name") String name, @Param("surname") String surname, @Param("roleId") String roleId);
	
    @Query(value = "SELECT * FROM users "
    			 + "INNER JOIN user_roles ON users.id = user_roles.user_id "
    			 + "WHERE UPPER(users.name) like CONCAT('%',UPPER(:name),'%') and UPPER(users.surname) like CONCAT('%',UPPER(:surname),'%') AND user_roles.role_id LIKE CONCAT('%',:roleId,'%')", nativeQuery = true)
    Page<User> findByNameAndSurname(@Param("name") String name, @Param("surname") String surname, @Param("roleId") String roleId, Pageable pageable);
	
	@Query(value = "SELECT COUNT(*) FROM trips WHERE created_by = :userId", nativeQuery = true)
	int getTotalTripsByUser(@Param("userId") Long userId);
	
	@Query(value = "SELECT COUNT(*) FROM trips WHERE created_by = :userId AND end_date < NOW()", nativeQuery = true)
	int getCompletedTripsByUser(@Param("userId") Long userId);
	
	@Query(value = "SELECT COUNT(DISTINCT i.destination) FROM trips t " +
			"INNER JOIN itineraries i ON t.id = i.trip_id " +
			"WHERE t.created_by = :userId", nativeQuery = true)
	int getTotalCountriesByUser(@Param("userId") Long userId);
	
	@Query(value = "SELECT COUNT(DISTINCT i.city) FROM trips t " +
			"INNER JOIN itineraries i ON t.id = i.trip_id " +
			"WHERE t.created_by = :userId", nativeQuery = true)
	int getTotalCitiesByUser(@Param("userId") Long userId);
	
}
