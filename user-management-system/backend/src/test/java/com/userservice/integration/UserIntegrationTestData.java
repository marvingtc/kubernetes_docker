package com.userservice.integration;

import com.userservice.model.User;
import com.userservice.dto.UserDto.CreateUserRequest;
import com.userservice.dto.UserDto.UpdateUserRequest;

/**
 * Test data factory for integration tests
 */
public class UserIntegrationTestData {

    public static CreateUserRequest createValidUserRequest() {
        return new CreateUserRequest(
            "testuser", 
            "test@example.com", 
            "Test User"
        );
    }

    public static CreateUserRequest createUserRequest(String username, String email, String fullName) {
        return new CreateUserRequest(username, email, fullName);
    }

    public static UpdateUserRequest createUpdateUserRequest() {
        return new UpdateUserRequest(
            "updateduser", 
            "updated@example.com", 
            "Updated Test User", 
            true
        );
    }

    public static UpdateUserRequest createPartialUpdateRequest(String fullName) {
        return new UpdateUserRequest(null, null, fullName, null);
    }

    public static User createTestUser(Long id, String username, String email, String fullName) {
        User user = new User(username, email, fullName);
        user.setId(id);
        return user;
    }

    // Invalid data for testing validation
    public static CreateUserRequest createInvalidUserRequest() {
        return new CreateUserRequest(
            "ab", // too short
            "invalid-email", // invalid format
            "" // empty name
        );
    }

    public static CreateUserRequest createUserWithLongUsername() {
        return new CreateUserRequest(
            "a".repeat(51), // too long
            "valid@email.com",
            "Valid Name"
        );
    }
}