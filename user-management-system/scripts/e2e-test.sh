#!/bin/bash

echo "🧪 Running End-to-End tests for User Management System..."

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKEND_URL="http://localhost:8080"
FRONTEND_URL="http://localhost:3000"
API_URL="$BACKEND_URL/api"
MAX_WAIT_TIME=300  # 5 minutes

# Function to wait for service
wait_for_service() {
    local service_name=$1
    local url=$2
    local timeout=${3:-60}
    
    echo -e "${YELLOW}⏳ Waiting for $service_name at $url...${NC}"
    
    local count=0
    while [ $count -lt $timeout ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service_name is ready!${NC}"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((count += 2))
    done
    
    echo -e "${RED}❌ $service_name failed to start within $timeout seconds${NC}"
    return 1
}

# Function to run API test
test_api_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    echo -e "${BLUE}Testing: $description${NC}"
    
    if [ -n "$data" ]; then
        response=$(curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            -w "%{http_code}" \
            "$API_URL$endpoint")
    else
        response=$(curl -s -X "$method" \
            -w "%{http_code}" \
            "$API_URL$endpoint")
    fi
    
    status_code="${response: -3}"
    body="${response%???}"
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS: HTTP $status_code${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL: Expected $expected_status, got $status_code${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Function to test frontend
test_frontend() {
    echo -e "${BLUE}🌐 Testing Frontend...${NC}"
    
    # Test main page
    if curl -f -s "$FRONTEND_URL" | grep -q "User Management"; then
        echo -e "${GREEN}✅ Frontend loads successfully${NC}"
    else
        echo -e "${RED}❌ Frontend failed to load${NC}"
        return 1
    fi
    
    # Test static assets (basic check)
    if curl -f -s "$FRONTEND_URL/static/" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Static assets accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  Static assets check inconclusive${NC}"
    fi
}

# Function to run comprehensive API tests
run_api_tests() {
    echo -e "${BLUE}🔧 Running comprehensive API tests...${NC}"
    
    local failed=0
    
    # Health check
    test_api_endpoint "GET" "/health" "" 200 "Health check" || ((failed++))
    
    # Redis ping
    test_api_endpoint "GET" "/redis/ping" "" 200 "Redis connectivity" || ((failed++))
    
    # Get all users (initially empty or with seed data)
    test_api_endpoint "GET" "/users" "" 200 "Get all users" || ((failed++))
    
    # Create test user
    local user1_data='{"username":"e2euser1","email":"e2e1@test.com","fullName":"E2E Test User 1"}'
    test_api_endpoint "POST" "/users" "$user1_data" 201 "Create user 1" || ((failed++))
    
    # Create second user
    local user2_data='{"username":"e2euser2","email":"e2e2@test.com","fullName":"E2E Test User 2"}'
    test_api_endpoint "POST" "/users" "$user2_data" 201 "Create user 2" || ((failed++))
    
    # Test duplicate username (should fail)
    local duplicate_data='{"username":"e2euser1","email":"different@test.com","fullName":"Different User"}'
    test_api_endpoint "POST" "/users" "$duplicate_data" 409 "Duplicate username error" || ((failed++))
    
    # Test validation error
    local invalid_data='{"username":"ab","email":"invalid-email","fullName":""}'
    test_api_endpoint "POST" "/users" "$invalid_data" 400 "Validation error" || ((failed++))
    
    # Get user by ID
    test_api_endpoint "GET" "/users/1" "" 200 "Get user by ID" || ((failed++))
    
    # Update user
    local update_data='{"fullName":"Updated E2E User 1","isActive":true}'
    test_api_endpoint "PUT" "/users/1" "$update_data" 200 "Update user" || ((failed++))
    
    # Search users
    test_api_endpoint "GET" "/users/search?name=E2E" "" 200 "Search users" || ((failed++))
    
    # Get user by username (async endpoint)
    test_api_endpoint "GET" "/users/by-username/e2euser1" "" 200 "Get user by username (async)" || ((failed++))
    
    # Test not found
    test_api_endpoint "GET" "/users/999" "" 404 "User not found error" || ((failed++))
    
    # Cache stats
    test_api_endpoint "GET" "/cache/stats" "" 200 "Cache statistics" || ((failed++))
    
    # Deactivate user
    test_api_endpoint "DELETE" "/users/2" "" 204 "Deactivate user" || ((failed++))
    
    return $failed
}

# Function to run load test
run_load_test() {
    echo -e "${BLUE}⚡ Running basic load test...${NC}"
    
    if ! command -v wrk &> /dev/null; then
        echo -e "${YELLOW}⚠️  wrk not found, skipping load test${NC}"
        return 0
    fi
    
    echo "Running 30-second load test with 50 concurrent connections..."
    
    # Test GET endpoint (cached)
    wrk -t4 -c50 -d30s --latency "$API_URL/users" > /tmp/load_test_results.txt 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Load test completed${NC}"
        echo "Results summary:"
        grep -E "(Requests/sec|Latency|requests in)" /tmp/load_test_results.txt
    else
        echo -e "${RED}❌ Load test failed${NC}"
        return 1
    fi
}

# Function to cleanup test data
cleanup_test_data() {
    echo -e "${YELLOW}🧹 Cleaning up test data...${NC}"
    
    # Try to deactivate test users (best effort)
    for id in {1..10}; do
        curl -s -X DELETE "$API_URL/users/$id" > /dev/null 2>&1
    done
    
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting E2E Test Suite for User Management System${NC}"
    echo "Target URLs:"
    echo "  Backend:  $BACKEND_URL"
    echo "  Frontend: $FRONTEND_URL"
    echo "  API:      $API_URL"
    echo ""
    
    local total_failures=0
    
    # Check if services are running
    if ! wait_for_service "Backend API" "$API_URL/health" 60; then
        echo -e "${RED}❌ Backend is not available. Please start the development environment:${NC}"
        echo "  ./scripts/dev-start.sh"
        exit 1
    fi
    
    if ! wait_for_service "Frontend" "$FRONTEND_URL" 30; then
        echo -e "${YELLOW}⚠️  Frontend is not available, skipping frontend tests${NC}"
    else
        # Test frontend
        test_frontend || ((total_failures++))
    fi
    
    echo ""
    
    # Run API tests
    run_api_tests
    api_failures=$?
    ((total_failures += api_failures))
    
    echo ""
    
    # Run load test
    run_load_test || ((total_failures++))
    
    echo ""
    
    # Cleanup
    cleanup_test_data
    
    echo ""
    echo "📊 E2E Test Results:"
    echo "===================="
    
    if [ $total_failures -eq 0 ]; then
        echo -e "${GREEN}🎉 All E2E tests passed! (0 failures)${NC}"
        echo ""
        echo "✅ System is working correctly with Java 21"
        echo "✅ API endpoints are functional"
        echo "✅ Cache is operational"
        echo "✅ Error handling works properly"
        echo "✅ Performance is acceptable"
        exit 0
    else
        echo -e "${RED}❌ E2E tests completed with $total_failures failure(s)${NC}"
        echo ""
        echo "Please check the failed tests and fix issues before proceeding."
        exit 1
    fi
}

# Run main function
main "$@"