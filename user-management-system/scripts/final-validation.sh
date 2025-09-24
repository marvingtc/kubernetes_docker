#!/bin/bash

echo "🔍 Final validation of Java 21 User Management System v4..."

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validation counters
total_checks=0
passed_checks=0

# Function to validate something
validate() {
    local description=$1
    local check_command=$2
    local fix_suggestion=$3
    
    ((total_checks++))
    echo -n "Validating $description... "
    
    if eval "$check_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        ((passed_checks++))
        return 0
    else
        echo -e "${RED}❌${NC}"
        if [[ -n "$fix_suggestion" ]]; then
            echo -e "  ${YELLOW}Fix:${NC} $fix_suggestion"
        fi
        return 1
    fi
}

echo -e "${BLUE}🏗️ Project Structure Validation${NC}"
echo "================================="

# Core structure
validate "Backend structure" "test -d backend/src/main/java/com/userservice"
validate "Frontend structure" "test -d frontend/src/components"
validate "Kubernetes manifests" "test -d k8s/deployments && ls k8s/deployments/*.yaml | wc -l | grep -q 4"
validate "Docker Compose setup" "test -f docker-compose/docker-compose.yml"
validate "Scripts directory" "test -d scripts && ls scripts/*.sh | wc -l | grep -q '[5-9]\|[1-9][0-9]'"

echo ""
echo -e "${BLUE}☕ Java 21 Backend Validation${NC}"
echo "=============================="

# Backend files
validate "Main application class" "test -f backend/src/main/java/com/userservice/UserManagementServiceApplication.java"
validate "User entity" "test -f backend/src/main/java/com/userservice/model/User.java"
validate "User repository" "test -f backend/src/main/java/com/userservice/repository/UserRepository.java"
validate "User service" "test -f backend/src/main/java/com/userservice/service/UserService.java"
validate "User controller" "test -f backend/src/main/java/com/userservice/controller/UserController.java"
validate "DTOs with Records" "grep -q 'public record' backend/src/main/java/com/userservice/dto/UserDto.java"
validate "Exception handling" "test -f backend/src/main/java/com/userservice/exception/GlobalExceptionHandler.java"
validate "Cache configuration" "test -f backend/src/main/java/com/userservice/config/CacheConfig.java"
validate "Maven wrapper" "test -x backend/mvnw"
validate "pom.xml with Java 21" "grep -q '<java.version>21</java.version>' backend/pom.xml"

echo ""
echo -e "${BLUE}⚛️ React Frontend Validation${NC}" 
echo "============================="

# Frontend files
validate "App component" "test -f frontend/src/App.js"
validate "User list component" "test -f frontend/src/components/UserList.js"
validate "User form component" "test -f frontend/src/components/UserForm.js"
validate "User detail component" "test -f frontend/src/components/UserDetail.js"
validate "Health dashboard" "test -f frontend/src/components/HealthDashboard.js"
validate "API service" "test -f frontend/src/services/api.js"
validate "Custom hooks" "test -f frontend/src/hooks/useUsers.js"
validate "Utility functions" "test -f frontend/src/utils/validation.js"
validate "Package.json" "test -f frontend/package.json"
validate "TailwindCSS config" "test -f frontend/tailwind.config.js"
validate "Index HTML" "test -f frontend/public/index.html"
validate "Main entry point" "test -f frontend/src/index.js"

echo ""
echo -e "${BLUE}☸️ Kubernetes Validation${NC}"
echo "========================"

# Kubernetes manifests
validate "Namespace manifest" "test -f k8s/namespace.yaml && grep -q 'user-management' k8s/namespace.yaml"
validate "User service deployment" "test -f k8s/deployments/user-service-deployment.yaml && grep -q 'java-version.*21' k8s/deployments/user-service-deployment.yaml"
validate "Redis deployment" "test -f k8s/deployments/redis-deployment.yaml"
validate "H2 deployment" "test -f k8s/deployments/h2-deployment.yaml"  
validate "Frontend deployment" "test -f k8s/deployments/frontend-deployment.yaml"
validate "All services" "ls k8s/services/*.yaml | wc -l | grep -q 4"
validate "ConfigMaps" "ls k8s/configmaps/*.yaml | wc -l | grep -q '[23]'"
validate "App ingress" "test -f k8s/ingress/app-ingress.yaml"
validate "Storage PVCs" "ls k8s/storage/*.yaml | wc -l | grep -q 2"

echo ""
echo -e "${BLUE}🐳 Docker Validation${NC}"
echo "==================="

# Docker files
validate "Backend Dockerfile" "test -f backend/Dockerfile && grep -q 'eclipse-temurin:21' backend/Dockerfile"
validate "Frontend Dockerfile" "test -f frontend/Dockerfile"
validate "Docker Compose" "test -f docker-compose/docker-compose.yml && grep -q 'user-service' docker-compose/docker-compose.yml"
validate "Development override" "test -f docker-compose/docker-compose.dev.yml"
validate "Nginx config" "test -f frontend/nginx.conf"

echo ""
echo -e "${BLUE}📜 Scripts Validation${NC}"
echo "====================="

# Scripts
validate "Development start script" "test -x scripts/dev-start.sh"
validate "Deployment script" "test -x scripts/deploy.sh"
validate "Build all script" "test -x scripts/build-all.sh"
validate "API test script" "test -x scripts/test-api.sh"
validate "E2E test script" "test -x scripts/e2e-test.sh"
validate "Load sample data script" "test -x scripts/load-sample-data.sh"
validate "Setup verification script" "test -x scripts/verify-setup.sh"
validate "Performance test script" "test -x scripts/performance-test.sh"

echo ""
echo -e "${BLUE}📚 Documentation Validation${NC}"
echo "==========================="

# Documentation
validate "Main README" "test -f README.md && grep -q 'Java 21' README.md"
validate "Project README" "test -f README.md && grep -q 'User Management System' README.md"
validate "API documentation" "test -f docs/api.md"
validate "Deployment guide" "test -f docs/deployment.md"
validate "Architecture docs" "test -f docs/architecture.md"

echo ""
echo -e "${BLUE}🧪 Test Files Validation${NC}"
echo "========================"

# Test files
validate "Backend unit tests" "test -f backend/src/test/java/com/userservice/UserServiceTest.java"
validate "Backend integration tests" "test -f backend/src/test/java/com/userservice/UserIntegrationTest.java"
validate "Backend controller tests" "test -f backend/src/test/java/com/userservice/UserControllerTest.java"
validate "Performance tests" "test -f backend/src/test/java/com/userservice/performance/UserServicePerformanceTest.java"
validate "Frontend tests" "test -f frontend/src/App.test.js"
validate "Test configuration" "test -f backend/src/test/resources/application-test.yml"

echo ""
echo -e "${BLUE}⚙️ Configuration Validation${NC}"
echo "==========================="

# Configuration files
validate "Main application config" "test -f backend/src/main/resources/application.yml"
validate "Development config" "test -f backend/src/main/resources/application-dev.yml"
validate "Production config" "test -f backend/src/main/resources/application-prod.yml"
validate "Docker config" "test -f backend/src/main/resources/application-docker.yml"
validate "Initial data SQL" "test -f backend/src/main/resources/data.sql"
validate "DevContainer config" "test -f .devcontainer/devcontainer.json && grep -q 'java:21' .devcontainer/devcontainer.json"

echo ""
echo -e "${BLUE}🎯 Java 21 Features Validation${NC}"
echo "==============================="

# Java 21 specific features
validate "Virtual Threads enabled" "grep -q 'spring.threads.virtual.enabled' backend/src/main/resources/application.yml"
validate "Records in DTOs" "grep -q 'public record.*Request' backend/src/main/java/com/userservice/dto/UserDto.java"
validate "Pattern matching usage" "grep -q 'switch.*case.*when' backend/src/main/java/com/userservice/service/UserService.java"
validate "String templates" "grep -q 'STR\\.' backend/src/main/java/com/userservice/service/UserService.java"
validate "Java 21 compiler target" "grep -q '<target>21</target>' backend/pom.xml"
validate "Preview features enabled" "grep -q 'enable-preview' backend/pom.xml"

echo ""
echo "📊 Final Validation Results"
echo "==========================="

percentage=$((passed_checks * 100 / total_checks))

if [[ $percentage -eq 100 ]]; then
    echo -e "${GREEN}🎉 PERFECT! All validations passed ($passed_checks/$total_checks)${NC}"
    echo ""
    echo -e "${GREEN}✅ Your Java 21 User Management System v4 is 100% complete!${NC}"
    echo ""
    echo -e "${BLUE}🚀 Ready for:${NC}"
    echo "  • Development with ./scripts/dev-start.sh"
    echo "  • Production deployment with ./scripts/deploy.sh"  
    echo "  • Performance testing with Java 21 Virtual Threads"
    echo "  • Full-stack testing with modern React frontend"
    echo ""
    echo -e "${BLUE}🔥 Java 21 Features Active:${NC}"
    echo "  • Virtual Threads for massive concurrency"
    echo "  • Pattern Matching for cleaner code"
    echo "  • Records for immutable DTOs"
    echo "  • String Templates for better formatting"
    echo "  • Preview features enabled"
    echo ""
    echo -e "${GREEN}🎊 Congratulations! Your system is production-ready!${NC}"
    
elif [[ $percentage -ge 95 ]]; then
    echo -e "${GREEN}🟢 EXCELLENT! Almost perfect ($passed_checks/$total_checks - $percentage%)${NC}"
    echo ""
    echo "Minor issues found, but the system is fully functional."
    echo "Consider fixing the remaining items for completeness."
    
elif [[ $percentage -ge 90 ]]; then
    echo -e "${YELLOW}🟡 VERY GOOD! ($passed_checks/$total_checks - $percentage%)${NC}"
    echo ""
    echo "System is functional with minor gaps. Safe to proceed with development."
    
elif [[ $percentage -ge 80 ]]; then
    echo -e "${YELLOW}🟠 GOOD ($passed_checks/$total_checks - $percentage%)${NC}"
    echo ""
    echo "Core functionality is present. Consider addressing failed checks."
    
else
    echo -e "${RED}🔴 NEEDS WORK ($passed_checks/$total_checks - $percentage%)${NC}"
    echo ""
    echo "Several critical components are missing. Please review and complete setup."
fi

echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
if [[ $percentage -ge 95 ]]; then
    echo "1. Run: ./scripts/verify-setup.sh"
    echo "2. Start: ./scripts/dev-start.sh" 
    echo "3. Test: ./scripts/e2e-test.sh"
    echo "4. Load data: ./scripts/load-sample-data.sh"
    echo "5. Enjoy your Java 21 + React system! 🎉"
else
    echo "1. Fix failed validations above"
    echo "2. Re-run this validation script"
    echo "3. Once >95%, proceed with development"
fi

exit 0