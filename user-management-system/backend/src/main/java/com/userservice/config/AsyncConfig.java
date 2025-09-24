package com.userservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * Async configuration optimized for Java 21 Virtual Threads
 */
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        // With Java 21 Virtual Threads, we can use a much higher thread count
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(20);
        executor.setMaxPoolSize(1000); // Much higher with Virtual Threads
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("UserService-Async-");
        executor.initialize();
        return executor;
    }
}