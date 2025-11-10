#!/bin/bash
# Tiraz Infrastructure Test Script
# Tests all infrastructure components to ensure they're working correctly

set -e

echo "=============================================="
echo "Tiraz Infrastructure Tests"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo "ℹ️  $1"
}

# Check if services are running
echo "Checking Docker services..."
if ! docker compose ps | grep -q "backend"; then
    print_error "Backend service is not running. Start with: docker compose up -d"
    exit 1
fi
print_success "Docker services are running"

echo ""
echo "Testing Backend API..."

# Wait for backend to be ready
print_info "Waiting for backend to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s -f http://localhost:8000/health > /dev/null 2>&1; then
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    print_error "Backend failed to start within 30 seconds"
    echo ""
    echo "Backend logs:"
    docker compose logs backend | tail -20
    exit 1
fi
print_success "Backend is responding"

# Test health endpoint
print_info "Testing /health endpoint..."
health_response=$(curl -s http://localhost:8000/health)
if echo "$health_response" | grep -q "ok"; then
    print_success "Health endpoint working"
else
    print_error "Health endpoint returned unexpected response: $health_response"
    exit 1
fi

# Test API docs endpoint
print_info "Testing /docs endpoint..."
if curl -s -f http://localhost:8000/docs > /dev/null 2>&1; then
    print_success "API documentation is accessible at http://localhost:8000/docs"
else
    print_error "API documentation endpoint not accessible"
    exit 1
fi

# Test API v1 prefix
print_info "Testing API v1 endpoints..."
if curl -s -f http://localhost:8000/api/v1/auth/register -X POST -H "Content-Type: application/json" -d '{}' > /dev/null 2>&1; then
    print_success "API v1 endpoints are accessible"
else
    # Check if it returns 422 (validation error) which is expected for empty body
    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/v1/auth/register -X POST -H "Content-Type: application/json" -d '{}')
    if [ "$status" = "422" ]; then
        print_success "API v1 endpoints are accessible (validation working)"
    else
        print_error "API v1 endpoints returned unexpected status: $status"
    fi
fi

echo ""
echo "Testing PostgreSQL..."

# Test database connection
if docker compose exec -T postgres psql -U tiraz -d tiraz_db -c "SELECT 1;" > /dev/null 2>&1; then
    print_success "PostgreSQL is accessible"
else
    print_error "PostgreSQL connection failed"
    exit 1
fi

echo ""
echo "=============================================="
echo "All tests passed!"
echo "=============================================="
echo ""
echo "Services are running at:"
echo "  - Backend API:     http://localhost:8000"
echo "  - API Docs:        http://localhost:8000/docs"
echo "  - PostgreSQL:      localhost:5432"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop:      docker compose down"
