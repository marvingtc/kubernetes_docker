#!/bin/bash

echo "🚀 Complete setup for Java 21 User Management System..."

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in the right directory
if [[ ! -f "package.json" ]] && [[ ! -d "user-management-system" ]]; then
    echo -e "${RED}❌ Please run this script from the kubernetes_docker repository root${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Complete Setup Checklist:${NC}"
echo "1. Update devcontainer to Java 21"
echo "2. Create complete project structure"
echo "3. Setup backend with Java 21 + Spring Boot"
echo "4. Setup frontend with React + TailwindCSS"
echo "5. Configure Kubernetes manifests"
echo "6. Setup development environment"
echo ""

# 1. Update devcontainer
echo -e "${YELLOW}🐳 Updating devcontainer to Java 21...${NC}"
cat > .devcontainer/devcontainer.json << 'EOF'
{
    "name": "Java 21, Docker, Maven & Spring Boot",
    "image": "mcr.microsoft.com/devcontainers/java:21",
    "features": {
        "docker-in-docker": {
            "version": "latest"
        },
        "kubectl-helm-minikube": {
            "version": "latest",
            "helm": "latest",
            "minikube": "latest"
        }
    },
    "postCreateCommand": "sudo apt-get update && sudo apt-get install -y docker-compose maven && java -version",
    "customizations": {
        "vscode": {
            "extensions": [
                "vscjava.vscode-java-pack",
                "vscjava.vscode-spring-initializr",
                "vscjava.vscode-spring-boot-dashboard",
                "pivotal.vscode-spring-boot",
                "ms-kubernetes-tools.vscode-kubernetes-tools",
                "ms-vscode.vscode-docker",
                "redhat.vscode-yaml",
                "bradlc.vscode-tailwindcss"
            ],
            "settings": {
                "java.configuration.runtimes": [
                    {
                        "name": "JavaSE-21",
                        "path": "/usr/local/sdkman/candidates/java/current"
                    }
                ],
                "java.compile.nullAnalysis.mode": "automatic"
            }
        }
    },
    "remoteUser": "vscode"
}
EOF

# 2. Update main README
echo -e "${YELLOW}📝 Updating main README...${NC}"
cat > README.md << 'EOF'
# Kubernetes & Docker Projects

Repositorio con proyectos de Kubernetes y Docker, optimizado para Java 21 con devcontainer preconfigurado.

## 🔥 Características principales

- ☕ **Java 21** con Virtual Threads (Project Loom)
- 🍃 **Spring Boot 3.2** optimizado para Java 21
- 🐳 **Docker** con multi-stage builds
- ☸️  **Kubernetes** con manifiestos completos
- ⚛️  **React 18** con TailwindCSS
- 🔴 **Redis** para caché distribuido
- 🗄️ **H2 Database** para desarrollo
- 🚀 **DevContainer** listo para usar

## 🏃‍♂️ Inicio rápido

### Con VS Code DevContainer (Recomendado)

```bash
# 1. Clonar repositorio
git clone <your-repo-url> kubernetes_docker
cd kubernetes_docker

# 2. Abrir en VS Code
code .

# 3. Cuando VS Code pregunte: "Reopen in Container"
# O usar Command Palette: "Dev Containers: Reopen in Container"

# 4. Una vez dentro del container:
cd user-management-system
./scripts/dev-start.sh
```

### Sin DevContainer

```bash
# Requisitos: Java 21, Docker, Node.js 18+
cd user-management-system

# Desarrollo local
./scripts/dev-start.sh

# O con Kubernetes
./scripts/deploy.sh
```

## 📁 Proyectos incluidos

### 🧑‍💼 User Management System

Sistema completo de gestión de usuarios con arquitectura de microservicios.

**Stack tecnológico:**
- Backend: Java 21 + Spring Boot 3.2 + Virtual Threads
- Frontend: React 18 + TailwindCSS
- Cache: Redis 7
- Database: H2 (dev) / PostgreSQL (prod)
- Orquestación: Kubernetes

**Características:**
- ✅ API REST con OpenAPI/Swagger
- ✅ Autenticación y validación
- ✅ Cache distribuido con Redis
- ✅ Health checks y métricas
- ✅ Tests unitarios e integración
- ✅ Interfaz web moderna
- ✅ Despliegue en Kubernetes
- ✅ Docker Compose para desarrollo

## 🛠️ Comandos principales

```bash
# Desarrollo local (Docker Compose)
cd user-management-system
./scripts/dev-start.sh

# Construcción de imágenes
./scripts/build-all.sh

# Despliegue en Kubernetes
./scripts/deploy.sh

# Tests de API
./scripts/test-api.sh

# Performance tests
./scripts/performance-test.sh

# Limpieza
./scripts/cleanup.sh
```

## 🌐 URLs de acceso

| Servicio | URL Local | URL K8s |
|----------|-----------|---------|
| Frontend | http://localhost:3000 | http://userapp.local |
| Backend API | http://localhost:8080/api | http://userapp.local/api |
| API Docs | http://localhost:8080/swagger-ui.html | http://userapp.local/swagger-ui.html |
| H2 Console | http://localhost:8082 | http://userapp.local/h2-console |
| Health | http://localhost:8080/actuator/health | http://userapp.local/actuator/health |

## 🏗️ Arquitectura

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│   Frontend  │───▶│ User Service │───▶│    Redis    │───▶│  H2 Database │
│  (React)    │    │ (Java 21)    │    │   (Cache)   │    │ (Persistence)│
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────┘
```

## 🔧 Configuración de desarrollo

El devcontainer incluye:
- Java 21 con preview features habilitadas
- Maven con configuración optimizada
- Docker-in-Docker para construcción de imágenes
- kubectl, helm, minikube para Kubernetes
- VS Code extensions para Java, Spring, Docker, Kubernetes

## 📚 Documentación adicional

- [User Management System](user-management-system/README.md)
- [Deployment Guide](user-management-system/docs/deployment.md)
- [Architecture Overview](user-management-system/docs/architecture.md)
- [API Documentation](user-management-system/docs/api.md)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Add nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

🚀 **Construido con Java 21, Spring Boot 3.2, React 18, y amor por la tecnología** ❤️
EOF

# 3. Make all scripts executable
echo -e "${YELLOW}🔧 Making scripts executable...${NC}"
find . -name "*.sh" -type f -exec chmod +x {} \;

# 4. Initialize git hooks (if git repo)
if [[ -d ".git" ]]; then
    echo -e "${YELLOW}🔗 Setting up git hooks...${NC}"
    
    # Pre-commit hook to run tests
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Check if we're in user-management-system
if [[ -d "user-management-system" ]]; then
    cd user-management-system
    
    # Run backend tests if backend exists
    if [[ -f "backend/pom.xml" ]]; then
        echo "Running backend tests..."
        cd backend
        ./mvnw test -q
        if [[ $? -ne 0 ]]; then
            echo "Backend tests failed!"
            exit 1
        fi
        cd ..
    fi
    
    # Run frontend tests if frontend exists
    if [[ -f "frontend/package.json" ]]; then
        echo "Running frontend tests..."
        cd frontend
        npm test -- --watchAll=false --coverage=false
        if [[ $? -ne 0 ]]; then
            echo "Frontend tests failed!"
            exit 1
        fi
        cd ..
    fi
fi

echo "All checks passed!"
EOF

    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✅ Git hooks configured${NC}"
fi

# 5. Create initial data script
echo -e "${YELLOW}📊 Creating sample data script...${NC}"
mkdir -p user-management-system/scripts
cat > user-management-system/scripts/load-sample-data.sh << 'EOF'
#!/bin/bash

echo "📊 Loading sample data into User Management System..."

API_URL="${API_URL:-http://localhost:8080/api}"

# Wait for API to be ready
echo "⏳ Waiting for API to be ready..."
for i in {1..30}; do
    if curl -f -s "$API_URL/health" > /dev/null; then
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Sample users data
declare -a users=(
    '{"username":"alice","email":"alice@company.com","fullName":"Alice Johnson"}'
    '{"username":"bob","email":"bob@company.com","fullName":"Bob Smith"}'
    '{"username":"carol","email":"carol@company.com","fullName":"Carol Williams"}'
    '{"username":"david","email":"david@company.com","fullName":"David Brown"}'
    '{"username":"eve","email":"eve@company.com","fullName":"Eve Davis"}'
    '{"username":"frank","email":"frank@company.com","fullName":"Frank Miller"}'
    '{"username":"grace","email":"grace@company.com","fullName":"Grace Wilson"}'
    '{"username":"henry","email":"henry@company.com","fullName":"Henry Moore"}'
    '{"username":"ivy","email":"ivy@company.com","fullName":"Ivy Taylor"}'
    '{"username":"jack","email":"jack@company.com","fullName":"Jack Anderson"}'
)

echo "👥 Creating sample users..."
for user in "${users[@]}"; do
    username=$(echo "$user" | jq -r '.username')
    response=$(curl -s -X POST "$API_URL/users" \
        -H "Content-Type: application/json" \
        -d "$user")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        echo "✅ Created user: $username"
    else
        echo