#!/bin/bash
# Verification script to check if authentication fixes are working
# Run this after starting docker-compose services

echo "=========================================="
echo "Taarez Authentication Fix Verification"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if docker-compose is running
echo "1. Checking Docker services..."
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓${NC} Docker services are running"
else
    echo -e "${RED}✗${NC} Docker services are not running"
    echo "   Run: docker-compose up -d"
    exit 1
fi

# Check backend health
echo ""
echo "2. Checking backend health..."
BACKEND_PORT=$(docker-compose port backend 8000 2>/dev/null | cut -d: -f2)
if [ -n "$BACKEND_PORT" ]; then
    HEALTH_RESPONSE=$(curl -s http://localhost:$BACKEND_PORT/health)
    if echo "$HEALTH_RESPONSE" | grep -q "ok"; then
        echo -e "${GREEN}✓${NC} Backend is healthy"
        echo "   Response: $HEALTH_RESPONSE"
    else
        echo -e "${RED}✗${NC} Backend health check failed"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Cannot determine backend port"
    exit 1
fi

# Check if test users exist
echo ""
echo "3. Checking test users..."
USER_COUNT=$(docker-compose exec -T postgres psql -U taarez -d taarez_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')
if [ "$USER_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $USER_COUNT users in database"
    docker-compose exec -T postgres psql -U taarez -d taarez_db -c "SELECT email, role FROM users;" 2>/dev/null
else
    echo -e "${YELLOW}⚠${NC}  No users found in database"
    echo "   Run: docker-compose exec backend python create_test_users.py"
fi

# Test password validation
echo ""
echo "4. Testing password validation..."
TEST_RESULT=$(docker-compose exec -T backend python -c "
from core.security import hash_password
import sys

try:
    # Test normal password
    hash_password('password123')
    print('normal:ok')
    
    # Test 72-byte password (should work)
    hash_password('a' * 72)
    print('72byte:ok')
    
    # Test 73-byte password (should fail)
    try:
        hash_password('a' * 73)
        print('73byte:failed')
        sys.exit(1)
    except ValueError:
        print('73byte:rejected')
except Exception as e:
    print(f'error:{e}')
    sys.exit(1)
" 2>&1)

if echo "$TEST_RESULT" | grep -q "73byte:rejected"; then
    echo -e "${GREEN}✓${NC} Password validation is working correctly"
    echo "   - Normal passwords: OK"
    echo "   - 72-byte passwords: OK"
    echo "   - 73-byte passwords: Correctly rejected"
else
    echo -e "${RED}✗${NC} Password validation test failed"
    echo "   $TEST_RESULT"
    exit 1
fi

# Test CORS configuration
echo ""
echo "5. Testing CORS configuration..."
CORS_CONFIG=$(docker-compose exec -T backend python -c "
from main import app
for middleware in app.user_middleware:
    if 'CORSMiddleware' in str(middleware):
        if 'allow_origin_regex' in middleware.kwargs:
            print('regex:' + middleware.kwargs['allow_origin_regex'])
        elif 'allow_origins' in middleware.kwargs:
            print('origins:' + ','.join(middleware.kwargs['allow_origins']))
" 2>&1)

if echo "$CORS_CONFIG" | grep -q "regex.*github.dev"; then
    echo -e "${GREEN}✓${NC} CORS is configured for GitHub Codespaces"
    echo "   Pattern: $(echo $CORS_CONFIG | cut -d: -f2-)"
elif echo "$CORS_CONFIG" | grep -q "origins:"; then
    echo -e "${YELLOW}⚠${NC}  CORS is using explicit origins (production mode?)"
    echo "   Origins: $(echo $CORS_CONFIG | cut -d: -f2-)"
else
    echo -e "${RED}✗${NC} Could not verify CORS configuration"
fi

# Check Flutter web app
echo ""
echo "6. Checking Flutter web app..."
FLUTTER_PORT=$(docker-compose port flutter-dev 8080 2>/dev/null | cut -d: -f2)
if [ -n "$FLUTTER_PORT" ]; then
    if curl -s http://localhost:$FLUTTER_PORT >/dev/null; then
        echo -e "${GREEN}✓${NC} Flutter web app is accessible"
        echo "   Port: $FLUTTER_PORT"
    else
        echo -e "${YELLOW}⚠${NC}  Flutter web app may still be building"
        echo "   Check logs: docker-compose logs flutter-dev"
    fi
else
    echo -e "${RED}✗${NC} Cannot determine Flutter port"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Verification Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. If test users don't exist, run:"
echo "   docker-compose exec backend python create_test_users.py"
echo ""
echo "2. Access the application:"
if [ -n "$FLUTTER_PORT" ]; then
    echo "   http://localhost:$FLUTTER_PORT"
fi
echo ""
echo "3. Log in with test credentials:"
echo "   Email: test@example.com"
echo "   Password: password123"
echo ""
