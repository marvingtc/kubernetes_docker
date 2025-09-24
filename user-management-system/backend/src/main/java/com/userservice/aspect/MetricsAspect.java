package com.userservice.aspect;

import com.userservice.metrics.UserMetrics;
import io.micrometer.core.instrument.Timer;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * AOP Aspect to automatically record metrics for user operations
 */
@Aspect
@Component
public class MetricsAspect {

    @Autowired
    private UserMetrics userMetrics;

    @Around("execution(* com.userservice.service.UserService.createUser(..))")
    public Object recordCreateUserMetrics(ProceedingJoinPoint joinPoint) throws Throwable {
        Timer.Sample sample = userMetrics.startTimer();
        try {
            Object result = joinPoint.proceed();
            userMetrics.incrementUsersCreated();
            return result;
        } finally {
            userMetrics.recordOperationTime(sample);
        }
    }

    @Around("execution(* com.userservice.service.UserService.updateUser(..))")
    public Object recordUpdateUserMetrics(ProceedingJoinPoint joinPoint) throws Throwable {
        Timer.Sample sample = userMetrics.startTimer();
        try {
            Object result = joinPoint.proceed();
            userMetrics.incrementUsersUpdated();
            return result;
        } finally {
            userMetrics.recordOperationTime(sample);
        }
    }

    @Around("execution(* com.userservice.service.UserService.deactivateUser(..))")
    public Object recordDeleteUserMetrics(ProceedingJoinPoint joinPoint) throws Throwable {
        Timer.Sample sample = userMetrics.startTimer();
        try {
            Object result = joinPoint.proceed();
            userMetrics.incrementUsersDeleted();
            return result;
        } finally {
            userMetrics.recordOperationTime(sample);
        }
    }
}