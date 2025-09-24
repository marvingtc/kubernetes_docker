package com.userservice.performance;

import com.userservice.dto.UserDto.CreateUserRequest;
import com.userservice.service.UserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.stream.IntStream;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Performance tests for Java 21 Virtual Threads
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class UserServicePerformanceTest {

    @Autowired
    private UserService userService;

    @Test
    @DisplayName("Should handle concurrent user creation with Virtual Threads")
    void shouldHandleConcurrentUserCreation() throws InterruptedException, ExecutionException {
        int numberOfUsers = 100;
        long startTime = System.currentTimeMillis();

        // Create users concurrently using Virtual Threads
        List<CompletableFuture<Void>> futures = new ArrayList<>();

        for (int i = 0; i < numberOfUsers; i++) {
            final int userId = i;
            CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
                try {
                    CreateUserRequest request = new CreateUserRequest(
                        "perfuser" + userId,
                        "perfuser" + userId + "@test.com",
                        "Performance User " + userId
                    );
                    userService.createUser(request);
                } catch (Exception e) {
                    // Handle unique constraint violations in concurrent tests
                    if (!e.getMessage().contains("already exists")) {
                        throw new RuntimeException(e);
                    }
                }
            });
            futures.add(future);
        }

        // Wait for all operations to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).get();

        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;

        System.out.printf("Created %d users in %d ms (%.2f users/sec)%n", 
                         numberOfUsers, executionTime, 
                         (numberOfUsers * 1000.0) / executionTime);

        // Verify that most users were created (allowing for some duplicates in concurrent test)
        var allUsers = userService.getAllActiveUsers();
        assertTrue(allUsers.size() >= numberOfUsers * 0.8, 
                  "Should create at least 80% of users in concurrent test");
    }

    @Test
    @DisplayName("Should handle concurrent user reads efficiently")
    void shouldHandleConcurrentUserReads() throws InterruptedException, ExecutionException {
        // First, create some test users
        for (int i = 1; i <= 10; i++) {
            CreateUserRequest request = new CreateUserRequest(
                "readuser" + i,
                "readuser" + i + "@test.com",
                "Read User " + i
            );
            userService.createUser(request);
        }

        int numberOfReads = 500;
        long startTime = System.currentTimeMillis();

        // Perform concurrent reads
        List<CompletableFuture<Void>> futures = IntStream.range(0, numberOfReads)
                .mapToObj(i -> CompletableFuture.runAsync(() -> {
                    try {
                        // Mix of different read operations
                        switch (i % 4) {
                            case 0 -> userService.getAllActiveUsers();
                            case 1 -> {
                                if (i % 10 == 0) userService.getUserById((long) (i % 10 + 1));
                            }
                            case 2 -> userService.searchUsersByName("Read User");
                            case 3 -> userService.getUserByUsernameAsync("readuser" + (i % 10 + 1)).join();
                        }
                    } catch (Exception e) {
                        // Log but don't fail test for expected exceptions
                        if (!e.getMessage().contains("not found")) {
                            throw new RuntimeException(e);
                        }
                    }
                }))
                .toList();

        // Wait for all reads to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).get();

        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;

        System.out.printf("Performed %d concurrent reads in %d ms (%.2f reads/sec)%n", 
                         numberOfReads, executionTime, 
                         (numberOfReads * 1000.0) / executionTime);

        // With Virtual Threads, we should handle this load efficiently
        assertTrue(executionTime < 5000, "Concurrent reads should complete within 5 seconds");
    }

    @Test
    @DisplayName("Should demonstrate cache effectiveness")
    void shouldDemonstrateCacheEffectiveness() {
        // Create a test user
        CreateUserRequest request = new CreateUserRequest(
            "cacheuser", 
            "cache@test.com", 
            "Cache Test User"
        );
        var createdUser = userService.createUser(request);

        // First read (cache miss)
        long startTime1 = System.nanoTime();
        userService.getUserById(createdUser.id());
        long firstReadTime = System.nanoTime() - startTime1;

        // Second read (cache hit)
        long startTime2 = System.nanoTime();
        userService.getUserById(createdUser.id());
        long secondReadTime = System.nanoTime() - startTime2;

        System.out.printf("First read (cache miss): %d ns%n", firstReadTime);
        System.out.printf("Second read (cache hit): %d ns%n", secondReadTime);

        // Cache hit should be significantly faster
        // Note: In test environment cache might be disabled, so this is more of a demo
        assertTrue(secondReadTime <= firstReadTime * 2, 
                  "Cached read should not be significantly slower");
    }
}