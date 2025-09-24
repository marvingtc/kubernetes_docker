#!/bin/bash

echo "🎲 Generating comprehensive test data for User Management System..."

API_URL="${API_URL:-http://localhost:8080/api}"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Wait for API
echo -e "${YELLOW}⏳ Waiting for API to be ready...${NC}"
for i in {1..30}; do
    if curl -f -s "$API_URL/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""

# Function to create user with error handling
create_user() {
    local username=$1
    local email=$2
    local fullName=$3
    local category=$4
    
    local payload="{\"username\":\"$username\",\"email\":\"$email\",\"fullName\":\"$fullName\"}"
    
    local response=$(curl -s -X POST "$API_URL/users" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        -w "%{http_code}")
    
    local status_code="${response: -3}"
    local body="${response%???}"
    
    if [ "$status_code" = "201" ]; then
        echo -e "${GREEN}✅ Created: $fullName${NC}"
        return 0
    elif [ "$status_code" = "409" ]; then
        echo -e "${YELLOW}⚠️  Exists: $fullName${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed: $fullName (HTTP $status_code)${NC}"
        return 1
    fi
}

echo -e "${BLUE}👥 Creating diverse user dataset...${NC}"
echo ""

# Management team
echo -e "${BLUE}🏢 Management Team:${NC}"
create_user "ceo.smith" "john.smith@company.com" "John Smith" "management"
create_user "cto.johnson" "sarah.johnson@company.com" "Sarah Johnson" "management"  
create_user "cfo.williams" "michael.williams@company.com" "Michael Williams" "management"
create_user "hr.director" "lisa.brown@company.com" "Lisa Brown" "management"

echo ""

# Development team  
echo -e "${BLUE}💻 Development Team:${NC}"
create_user "dev.alice" "alice.cooper@company.com" "Alice Cooper" "developer"
create_user "dev.bob" "bob.martin@company.com" "Bob Martin" "developer"
create_user "dev.carol" "carol.king@company.com" "Carol King" "developer"
create_user "dev.david" "david.jones@company.com" "David Jones" "developer"
create_user "dev.emma" "emma.watson@company.com" "Emma Watson" "developer"
create_user "dev.frank" "frank.sinatra@company.com" "Frank Sinatra" "developer"

echo ""

# QA team
echo -e "${BLUE}🧪 QA Team:${NC}"
create_user "qa.grace" "grace.kelly@company.com" "Grace Kelly" "qa"
create_user "qa.henry" "henry.ford@company.com" "Henry Ford" "qa"
create_user "qa.iris" "iris.murdoch@company.com" "Iris Murdoch" "qa"

echo ""

# Sales team
echo -e "${BLUE}💼 Sales Team:${NC}"
create_user "sales.jack" "jack.london@company.com" "Jack London" "sales"
create_user "sales.kate" "kate.winslet@company.com" "Kate Winslet" "sales"
create_user "sales.liam" "liam.neeson@company.com" "Liam Neeson" "sales"
create_user "sales.mary" "mary.poppins@company.com" "Mary Poppins" "sales"

echo ""

# Marketing team
echo -e "${BLUE}📢 Marketing Team:${NC}"
create_user "marketing.nina" "nina.simone@company.com" "Nina Simone" "marketing"
create_user "marketing.oscar" "oscar.wilde@company.com" "Oscar Wilde" "marketing"
create_user "marketing.penny" "penny.lane@company.com" "Penny Lane" "marketing"

echo ""

# International users (diverse names)
echo -e "${BLUE}🌍 International Team:${NC}"
create_user "akiko.tanaka" "akiko.tanaka@company.com" "田中明子" "international"
create_user "pierre.dubois" "pierre.dubois@company.com" "Pierre Dubois" "international"
create_user "maria.gonzalez" "maria.gonzalez@company.com" "María González" "international"
create_user "ahmed.hassan" "ahmed.hassan@company.com" "أحمد حسن" "international"
create_user "olga.petrov" "olga.petrov@company.com" "Ольга Петрова" "international"

echo ""

# Test users for different scenarios
echo -e "${BLUE}🧪 Test Scenario Users:${NC}"
create_user "test.user" "test.user@company.com" "Test User" "test"
create_user "long.username.test" "long.username@company.com" "User With Very Long Full Name That Tests Limits" "test"
create_user "special.chars" "special+chars@company.com" "Special-Chars User_123" "test"
create_user "minimal.user" "min@co.com" "Min" "test"

echo ""

# Get final count
echo -e "${BLUE}📊 Checking final user count...${NC}"
user_count=$(curl -s "$API_URL/users" | jq length 2>/dev/null || echo "unknown")

echo ""
echo -e "${GREEN}🎉 Test data generation completed!${NC}"
echo ""
echo -e "${BLUE}📈 Summary:${NC}"
echo "  Total users created: $user_count"
echo "  Categories: Management, Development, QA, Sales, Marketing, International, Test"
echo ""
echo -e "${BLUE}🌐 Access the application:${NC}"
echo "  Frontend: http://localhost:3000"
echo "  API: $API_URL"
echo "  API Docs: http://localhost:8080/swagger-ui.html"
echo ""
echo -e "${BLUE}🧪 Try these test scenarios:${NC}"
echo "  • Search for users by name"
echo "  • Test user creation/editing"
echo "  • Check cache performance with repeated requests"
echo "  • Test international character support"
echo "  • Monitor health dashboard"
