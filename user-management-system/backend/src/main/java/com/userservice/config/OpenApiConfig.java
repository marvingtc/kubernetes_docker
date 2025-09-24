package com.userservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * OpenAPI/Swagger configuration
 */
@Configuration
public class OpenApiConfig {

    @Value("${server.servlet.context-path:/}")
    private String contextPath;

    @Bean
    public OpenAPI userManagementOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("User Management API")
                        .description("""
                                RESTful API for user management system built with:
                                • Java 21 with Virtual Threads (Project Loom)
                                • Spring Boot 3.2 with reactive features
                                • Redis caching for high performance
                                • H2/PostgreSQL for data persistence
                                • OpenAPI 3.0 documentation
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Development Team")
                                .email("dev@userapp.local")
                                .url("https://github.com/yourorg/user-management"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080" + contextPath)
                                .description("Development server"),
                        new Server()
                                .url("http://userapp.local" + contextPath)  
                                .description("Local Kubernetes"),
                        new Server()
                                .url("https://api.userapp.yourdomain.com" + contextPath)
                                .description("Production server")));
    }
}