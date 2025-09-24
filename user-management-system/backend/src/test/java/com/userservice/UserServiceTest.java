package com.userservice;

import com.userservice.dto.UserDto.*;
import com.userservice.model.User;
import com.userservice.repository.UserRepository;
import com.userservice.service.UserService;
import com.userservice.exception.UserNotFoundException;
import com.userservice.exception.UserAlreadyExistsException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests para UserService usando Java 21 features
 */
@SpringBootTest
@ActiveProfiles("test")
class UserServiceTest {

    @MockBean
    private UserRepository userRepository;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository);
    }

    @Test
    @DisplayName("Should create user successfully")
    void shouldCreateUserSuccessfully() {
        // Given
        var request = new CreateUserRequest(
            "testuser", 
            "test@example.com", 
            "Test User"
        );
        
        var savedUser = createTestUser(1L, "testuser", "test@example.com", "Test User");
        
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // When
        UserResponse response = userService.createUser(request);

        // Then
        assertAll(
            () -> assertEquals(1L, response.id()),
            () -> assertEquals("testuser", response.username()),
            () -> assertEquals("test@example.com", response.email()),
            () -> assertEquals("Test User", response.fullName()),
            () -> assertTrue(response.isActive())
        );
        
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception when username already exists")
    void shouldThrowExceptionWhenUsernameExists() {
        // Given
        var request = new CreateUserRequest("existing", "new@email.com", "New User");
        when(userRepository.existsByUsername("existing")).thenReturn(true);

        // When & Then
        assertThrows(UserAlreadyExistsException.class, 
            () -> userService.createUser(request));
        
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should get user by ID successfully")
    void shouldGetUserByIdSuccessfully() {
        // Given
        var user = createTestUser(1L, "testuser", "test@example.com", "Test User");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        UserResponse response = userService.getUserById(1L);

        // Then
        assertEquals(1L, response.id());
        assertEquals("testuser", response.username());
    }

    @Test
    @DisplayName("Should throw exception when user not found")
    void shouldThrowExceptionWhenUserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        var exception = assertThrows(UserNotFoundException.class,
            () -> userService.getUserById(999L));
        
        assertTrue(exception.getMessage().contains("999"));
    }

    @Test
    @DisplayName("Should get all active users")
    void shouldGetAllActiveUsers() {
        // Given
        var users = List.of(
            createTestUser(1L, "user1", "user1@test.com", "User One"),
            createTestUser(2L, "user2", "user2@test.com", "User Two")
        );
        when(userRepository.findByIsActiveTrue()).thenReturn(users);

        // When
        List<UserResponse> responses = userService.getAllActiveUsers();

        // Then
        assertEquals(2, responses.size());
        assertEquals("user1", responses.get(0).username());
        assertEquals("user2", responses.get(1).username());
    }

    @Test
    @DisplayName("Should update user successfully")
    void shouldUpdateUserSuccessfully() {
        // Given
        var existingUser = createTestUser(1L, "oldname", "old@email.com", "Old Name");
        var updateRequest = new UpdateUserRequest(
            "newname", 
            "new@email.com", 
            "New Name", 
            true
        );
        
        when(userRepository.findById(1L)).thenReturn(Optional.of(existingUser));
        when(userRepository.existsByUsername("newname")).thenReturn(false);
        when(userRepository.existsByEmail("new@email.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        UserResponse response = userService.updateUser(1L, updateRequest);

        // Then
        assertEquals("New Name", response.fullName());
        verify(userRepository).save(existingUser);
    }

    @Test
    @DisplayName("Should get user by username asynchronously")
    void shouldGetUserByUsernameAsync() throws Exception {
        // Given
        var user = createTestUser(1L, "asyncuser", "async@test.com", "Async User");
        when(userRepository.findByUsername("asyncuser")).thenReturn(Optional.of(user));

        // When
        CompletableFuture<UserResponse> future = userService.getUserByUsernameAsync("asyncuser");
        UserResponse response = future.get(); // Wait for completion

        // Then
        assertEquals("asyncuser", response.username());
        assertEquals("async@test.com", response.email());
    }

    @Test
    @DisplayName("Should search users by name")
    void shouldSearchUsersByName() {
        // Given
        var users = List.of(
            createTestUser(1L, "john", "john@test.com", "John Doe"),
            createTestUser(2L, "johnny", "johnny@test.com", "Johnny Smith")
        );
        when(userRepository.findByFullNameContaining("John")).thenReturn(users);

        // When
        List<UserResponse> responses = userService.searchUsersByName("John");

        // Then
        assertEquals(2, responses.size());
        assertTrue(responses.stream().allMatch(u -> u.fullName().contains("John")));
    }

    @Test
    @DisplayName("Should deactivate user successfully")
    void shouldDeactivateUserSuccessfully() {
        // Given
        var user = createTestUser(1L, "testuser", "test@example.com", "Test User");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        userService.deactivateUser(1L);

        // Then
        verify(userRepository).save(argThat(u -> !u.getIsActive()));
    }

    // Helper method to create test users
    private User createTestUser(Long id, String username, String email, String fullName) {
        var user = new User(username, email, fullName);
        user.setId(id);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        return user;
    }
}
