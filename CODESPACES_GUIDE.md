# GitHub Codespaces Deployment Guide

## Quick Start for GitHub Codespaces

This guide will help you get the Taarez application running in GitHub Codespaces with proper authentication.

### 1. Start the Application

```bash
# Navigate to the project root
cd /workspaces/Tiraz  # or wherever your workspace is

# Start all services with Docker Compose
docker-compose up -d

# Wait for services to start (about 30 seconds)
docker-compose ps
```

### 2. Set Up Test Users

```bash
# Run the test user creation script
docker-compose exec backend python create_test_users.py
```

This will create three test users:
- **Customer**: `test@example.com` / `password123`
- **Designer**: `designer@example.com` / `password123`
- **Admin**: `admin@example.com` / `password123`

### 3. Access the Application

In GitHub Codespaces, the ports are automatically forwarded:

- **Flutter Web App**: Port 8080 → `https://[codespace-name]-8080.app.github.dev`
- **Backend API**: Port 8000 → `https://[codespace-name]-8000.app.github.dev`

### 4. Test the Application

1. Open the Flutter web app URL (port 8080)
2. Log in with: `test@example.com` / `password123`
3. You should see the user dashboard

### Troubleshooting

#### CORS Errors

The application is now configured to automatically allow GitHub Codespaces URLs in development mode. The backend uses a regex pattern to allow all `*.app.github.dev` domains.

#### Password Validation Errors

If you see errors about password length:
- Passwords must be between 8 and 72 characters
- Bcrypt has a 72-byte limit - the app now validates this before hashing
- Multi-byte UTF-8 characters count more than 1 byte

#### Network Errors (XMLHttpRequest error)

The Flutter web app now auto-detects the backend URL in Codespaces by:
1. Checking the current URL
2. If it matches `*-8080.app.github.dev`, it constructs the backend URL as `*-8000.app.github.dev`
3. This happens automatically without configuration

#### Port Visibility

Make sure your Codespaces ports are set to "Public" visibility:
1. Go to the PORTS tab in VS Code
2. Right-click on ports 8000 and 8080
3. Select "Port Visibility" → "Public"

### Manual Backend URL Configuration

If auto-detection doesn't work, you can manually set the backend URL:

1. Find your backend URL (port 8000)
2. Set it as an environment variable when building:
   ```bash
   flutter build web --dart-define=API_BASE_URL=https://your-backend-url
   ```

### Check Service Health

```bash
# Check backend health
curl https://[codespace-name]-8000.app.github.dev/health

# Check database connection
docker-compose exec backend python -c "from core.database import engine; print('DB OK' if engine.connect() else 'DB FAIL')"

# View backend logs
docker-compose logs backend --tail=50 -f
```

## Architecture Changes

### Backend Changes
1. **CORS Configuration** (`backend/main.py`):
   - Uses `allow_origin_regex` in development mode
   - Allows all `*.app.github.dev` domains
   - Strict CORS in production mode

2. **Password Validation** (`backend/core/security.py`):
   - Validates password byte length before bcrypt hashing
   - Raises clear error if password exceeds 72 bytes
   - Prevents bcrypt internal errors

3. **Test User Script** (`backend/create_test_users.py`):
   - Creates standard test users for all roles
   - Validates passwords before creation
   - Idempotent - safe to run multiple times

### Frontend Changes
1. **Dynamic Backend URL** (`mobile-app/lib/utils/app_config.dart`):
   - Auto-detects GitHub Codespaces environment
   - Constructs backend URL from current URL
   - Falls back to Docker backend for local development
   - Supports explicit API_BASE_URL override

## Development Tips

### Running Locally (without Codespaces)

```bash
# Start services
docker-compose up -d

# Create test users
docker-compose exec backend python create_test_users.py

# Access at:
# - Frontend: http://localhost:8080
# - Backend: http://localhost:8000
```

### Debugging

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs backend -f
docker-compose logs flutter-dev -f

# Restart a service
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build backend
```

### Database Management

```bash
# Access PostgreSQL
docker-compose exec postgres psql -U taarez -d taarez_db

# View users
docker-compose exec postgres psql -U taarez -d taarez_db -c "SELECT email, role FROM users;"

# Reset database (WARNING: Deletes all data!)
docker-compose down -v
docker-compose up -d
docker-compose exec backend python create_test_users.py
```

## Security Considerations

- The regex CORS pattern is **only active in development mode**
- In production (ENVIRONMENT=production), strict CORS origins are enforced
- Never commit real secrets to `.env` file
- Use strong SECRET_KEY in production (min 32 characters)
- Test users should be removed or have passwords changed in production
