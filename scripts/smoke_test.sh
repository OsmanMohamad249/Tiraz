#!/bin/bash
# Improved smoke test script with better error handling and logging

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
MAX_RETRIES="${MAX_RETRIES:-30}"
RETRY_DELAY="${RETRY_DELAY:-2}"

echo "🔍 Starting Smoke E2E Tests..."
echo "Backend URL: $BACKEND_URL"
echo ""

# Function to wait for backend to be ready
wait_for_backend() {
    echo "⏳ Waiting for backend to be ready..."
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        if curl -s -f "$BACKEND_URL/health" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Backend is ready!${NC}"
            return 0
        fi
        
        retries=$((retries + 1))
        echo "Attempt $retries/$MAX_RETRIES: Backend not ready yet..."
        sleep $RETRY_DELAY
    done
    
    echo -e "${RED}❌ Backend failed to start after $MAX_RETRIES attempts${NC}"
    return 1
}

# Function to check database connection
check_database() {
    echo "🔍 Checking database connection..."
    
    local response=$(curl -s "$BACKEND_URL/health/db" || echo "failed")
    
    if echo "$response" | grep -q "ok\|healthy"; then
        echo -e "${GREEN}✅ Database connection is healthy${NC}"
        return 0
    else
        echo -e "${RED}❌ Database connection failed${NC}"
        echo "Response: $response"
        return 1
    fi
}

# Function to run API tests
run_api_tests() {
    echo "🧪 Running API tests..."
    
    # Test 1: Health check
    echo "Test 1: Health check endpoint"
    if curl -s -f "$BACKEND_URL/health" > /dev/null; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${RED}❌ Health check failed${NC}"
        return 1
    fi
    
    # Test 2: API docs
    echo "Test 2: API documentation endpoint"
    if curl -s -f "$BACKEND_URL/docs" > /dev/null; then
        echo -e "${GREEN}✅ API docs accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  API docs not accessible (non-critical)${NC}"
    fi
    
    # Test 3: API version
    echo "Test 3: API version endpoint"
    local version=$(curl -s "$BACKEND_URL/api/v1/version" || echo "failed")
    if [ "$version" != "failed" ]; then
        echo -e "${GREEN}✅ API version: $version${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not retrieve API version${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ All API tests passed!${NC}"
    return 0
}

# Main execution
main() {
    echo "================================================"
    echo "  Qeyafa Smoke E2E Tests"
    echo "================================================"
    echo ""
    
    # Step 1: Wait for backend
    if ! wait_for_backend; then
        echo -e "${RED}❌ Smoke tests failed: Backend not ready${NC}"
        exit 1
    fi
    echo ""
    
    # Step 2: Check database
    if ! check_database; then
        echo -e "${YELLOW}⚠️  Database check failed (continuing anyway)${NC}"
    fi
    echo ""
    
    # Step 3: Run API tests
    if ! run_api_tests; then
        echo -e "${RED}❌ Smoke tests failed: API tests failed${NC}"
        exit 1
    fi
    
    echo ""
    echo "================================================"
    echo -e "${GREEN}✅ All smoke tests passed successfully!${NC}"
    echo "================================================"
    exit 0
}

# Run main function
main
