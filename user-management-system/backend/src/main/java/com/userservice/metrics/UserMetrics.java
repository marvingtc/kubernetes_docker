package com.userservice.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.userservice.repository.UserRepository;

/**
 * Custom metrics for monitoring user operations
 */
@Component
public class UserMetrics {

    private final Counter usersCreatedCounter;
    private final Counter usersUpdatedCounter;
    private final Counter usersDeletedCounter;
    private final Timer userOperationTimer;
    private final UserRepository userRepository;

    @Autowired
    public UserMetrics(MeterRegistry meterRegistry, UserRepository userRepository) {
        this.userRepository = userRepository;
        
        // Counters for operations
        this.usersCreatedCounter = Counter.builder("users.created.total")
                .description("Total number of users created")
                .register(meterRegistry);
                
        this.usersUpdatedCounter = Counter.builder("users.updated.total")
                .description("Total number of users updated")
                .register(meterRegistry);
                
        this.usersDeletedCounter = Counter.builder("users.deleted.total")
                .description("Total number of users deleted/deactivated")
                .register(meterRegistry);
                
        // Timer for operations
        this.userOperationTimer = Timer.builder("users.operation.duration")
                .description("Time taken for user operations")
                .register(meterRegistry);
        
        // Gauge for active users count
        Gauge.builder("users.active.count")
                .description("Number of active users")
                .register(meterRegistry, this, UserMetrics::getActiveUsersCount);
                
        // Gauge for total users count
        Gauge.builder("users.total.count")
                .description("Total number of users")
                .register(meterRegistry, this, UserMetrics::getTotalUsersCount);
    }

    public void incrementUsersCreated() {
        usersCreatedCounter.increment();
    }

    public void incrementUsersUpdated() {
        usersUpdatedCounter.increment();
    }

    public void incrementUsersDeleted() {
        usersDeletedCounter.increment();
    }

    public Timer.Sample startTimer() {
        return Timer.start();
    }

    public void recordOperationTime(Timer.Sample sample) {
        sample.stop(userOperationTimer);
    }

    private long getActiveUsersCount() {
        try {
            return userRepository.findByIsActiveTrue().size();
        } catch (Exception e) {
            return 0;
        }
    }

    private long getTotalUsersCount() {
        try {
            return userRepository.count();
        } catch (Exception e) {
            return 0;
        }
    }
}