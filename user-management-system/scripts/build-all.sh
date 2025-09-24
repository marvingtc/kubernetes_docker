#!/bin/bash

echo "🔨 Construyendo todas las imágenes con Java 21..."

set -e  # Exit on any error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REGISTRY="${REGISTRY:-localhost:5000}"
VERSION="${VERSION:-v1.0}"

# Function to build and tag image
build_service() {
    local service_name=$1
    local dockerfile_path=$2
    local image_tag="${REGISTRY}/${service_name}:${VERSION}"
    
    echo -e "${YELLOW}🔨 Building ${service_name} with Java 21...${NC}"
    
    # Build with Java 21 optimizations
    if docker build \
        --build-arg JAVA_VERSION=21 \
        --build-arg ENABLE_PREVIEW=true \
        -t "${image_tag}" \
        -t "${service_name}:latest" \
        "${dockerfile_path}"; then
        
        echo -e "${GREEN}✅ ${service_name} built successfully: ${image_tag}${NC}"
        
        # Push to registry if available
        if docker push "${image_tag}" 2>/dev/null; then
            echo -e "${GREEN}📤 ${service_name} pushed to registry${NC}"
        else
            echo -e "${YELLOW}⚠️  Registry not available, image saved locally only${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}❌ Error building ${service_name}${NC}"
        return 1
    fi
}

# Verify Java 21 availability
echo -e "${YELLOW}🔍 Checking Java 21 availability...${NC}"
if docker run --rm eclipse-temurin:21-jdk-alpine java -version; then
    echo -e "${GREEN}✅ Java 21 confirmed available${NC}"
else
    echo -e "${RED}❌ Java 21 not available${NC}"
    exit 1
fi

# Build backend service
build_service "user-service" "./backend"

# Build frontend
build_service "frontend" "./frontend"

echo -e "${GREEN}🎉 All services built successfully with Java 21!${NC}"
echo ""
echo "📋 Built images:"
docker images | grep -E "(user-service|frontend)" | head -10

echo ""
echo "🚀 Ready to deploy:"
echo "  docker-compose up    # Local development"
echo "  ./scripts/deploy.sh  # Kubernetes deployment"

---

# user-management-system/scripts/dev-start.sh
#!/bin/bash

echo "🚀 Starting Java 21 development environment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if Java 21 is available locally
check_java21() {
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        echo -e "${BLUE}ℹ️  Local Java version: ${java_version}${NC}"
    fi
}

# Function to wait for service
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${YELLOW}⏳ Waiting for ${service_name}...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ ${service_name} is ready!${NC}"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    echo -e "${RED}❌ ${service_name} failed to start${NC}"
    return 1
}

check_java21

# Navigate to docker-compose directory
cd docker-compose || exit 1

echo -e "${YELLOW}🏗️  Building and starting services with Java 21...${NC}"

# Build and start services
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d

echo -e "${YELLOW}⏳ Services starting up...${NC}"

# Wait for services
wait_for_service "Redis" "http://localhost:6379" &
wait_for_service "H2 Database" "http://localhost:8082" &
wait_for_service "User Service" "http://localhost:8080/actuator/health" &

wait  # Wait for all background jobs

echo ""
echo -e "${GREEN}✅ Development environment ready!${NC}"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "  Frontend:     http://localhost:3000"
echo "  Backend API:  http://localhost:8080/api"
echo "  API Docs:     http://localhost:8080/swagger-ui.html"
echo "  H2 Console:   http://localhost:8082 (JDBC URL: jdbc:h2:tcp://localhost:9092/~/userdb)"
echo "  Actuator:     http://localhost:8080/actuator"
echo ""
echo -e "${BLUE}📊 Useful commands:${NC}"
echo "  docker-compose logs -f user-service  # Backend logs"
echo "  docker-compose logs -f frontend      # Frontend logs"
echo "  docker-compose logs -f redis         # Redis logs"
echo "  ./cleanup.sh                         # Clean up"
echo ""
echo -e "${BLUE}🧪 Test endpoints:${NC}"
echo "  curl http://localhost:8080/api/health"
echo "  curl http://localhost:8080/api/users"
echo "  curl http://localhost:8080/api/redis/ping"

---

# user-management-system/scripts/test-api.sh
#!/bin/bash

echo "🧪 Testing User Management API with Java 21..."

API_URL="http://localhost:8080/api"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Testing: ${description}${NC}"
    echo "Endpoint: ${method} ${API_URL}${endpoint}"
    
    if [ -n "$data" ]; then
        response=$(curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            -w "\n%{http_code}" \
            "${API_URL}${endpoint}")
    else
        response=$(curl -s -X "$method" \
            -w "\n%{http_code}" \
            "${API_URL}${endpoint}")
    fi
    
    body=$(echo "$response" | head -n -1)
    status=$(echo "$response" | tail -n 1)
    
    if [[ $status -ge 200 && $status -lt 300 ]]; then
        echo -e "${GREEN}✅ Success (${status})${NC}"
        echo "Response: $body" | jq . 2>/dev/null || echo "Response: $body"
    else
        echo -e "${RED}❌ Failed (${status})${NC}"
        echo "Response: $body"
    fi
    echo "---"
}

echo "🔍 Checking if API is available..."
if ! curl -f -s "${API_URL}/health" > /dev/null; then
    echo -e "${RED}❌ API is not available at ${API_URL}${NC}"
    echo "Please start the development environment first:"
    echo "  ./dev-start.sh"
    exit 1
fi

echo -e "${GREEN}✅ API is available${NC}"
echo ""

# Health check
test_endpoint "GET" "/health" "" "Health check"

# Redis ping
test_endpoint "GET" "/redis/ping" "" "Redis connectivity"

# Get all users (initially empty)
test_endpoint "GET" "/users" "" "Get all users"

# Create test users
test_endpoint "POST" "/users" '{
    "username": "johndoe",
    "email": "john.doe@example.com", 
    "fullName": "John Doe"
}' "Create user: John Doe"

test_endpoint "POST" "/users" '{
    "username": "janedoe",
    "email": "jane.doe@example.com",
    "fullName": "Jane Doe"  
}' "Create user: Jane Doe"

test_endpoint "POST" "/users" '{
    "username": "bobsmith",
    "email": "bob.smith@example.com",
    "fullName": "Bob Smith"
}' "Create user: Bob Smith"

# Get all users again
test_endpoint "GET" "/users" "" "Get all users (after creation)"

# Get user by ID
test_endpoint "GET" "/users/1" "" "Get user by ID (1)"

# Update user
test_endpoint "PUT" "/users/1" '{
    "fullName": "John Updated Doe",
    "isActive": true
}' "Update user 1"

# Search users
test_endpoint "GET" "/users/search?name=Jane" "" "Search users by name 'Jane'"

# Get user by username (async endpoint)
test_endpoint "GET" "/users/by-username/johndoe" "" "Get user by username (async)"

# Test validation error
test_endpoint "POST" "/users" '{
    "username": "ab",
    "email": "invalid-email",
    "fullName": ""
}' "Test validation error"

# Test duplicate user error
test_endpoint "POST" "/users" '{
    "username": "johndoe",
    "email": "different@email.com",
    "fullName": "Different User"
}' "Test duplicate username error"

# Test user not found
test_endpoint "GET" "/users/999" "" "Test user not found error"

# Deactivate user
test_endpoint "DELETE" "/users/3" "" "Deactivate user 3"

# Cache stats
test_endpoint "GET" "/cache/stats" "" "Get cache statistics"

echo ""
echo -e "${GREEN}🎉 API testing completed!${NC}"
echo ""
echo "📊 Summary:"
echo "- Health endpoints tested"
echo "- CRUD operations tested"
echo "- Error handling tested"
echo "- Cache functionality tested"
echo "- Java 21 Virtual Threads (async endpoint) tested"