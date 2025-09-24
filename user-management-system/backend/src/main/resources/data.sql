-- Initial data for development/testing
-- This file is executed automatically by Spring Boot on startup

INSERT INTO users (username, email, full_name, is_active, created_at, updated_at) VALUES 
('admin', 'admin@userapp.local', 'System Administrator', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('alice.johnson', 'alice.johnson@company.com', 'Alice Johnson', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('bob.smith', 'bob.smith@company.com', 'Bob Smith', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('carol.williams', 'carol.williams@company.com', 'Carol Williams', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('david.brown', 'david.brown@company.com', 'David Brown', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Note: The table is auto-created by JPA/Hibernate based on the User entity
-- This insert will happen after table creation due to spring.jpa.defer-datasource-initialization=true
