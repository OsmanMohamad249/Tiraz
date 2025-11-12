# Sprint 1: User Authentication System - Setup Guide

## Overview
This guide will help you set up and run the complete Qeyafa authentication system with FastAPI backend and Flutter mobile app.

## Prerequisites

### Backend
- Docker and Docker Compose
- Python 3.11+

### Mobile App
- Flutter SDK (2.19.0 or higher)
- Android Studio or Xcode
- Android Emulator or iOS Simulator

## Backend Setup

### 1. Start the Services

```bash
# From the project root directory
docker-compose up --build
```

This will start:
- FastAPI backend on `http://localhost:8000`
- PostgreSQL database on `localhost:5432`

### 2. Run Database Migrations

Once the containers are running, open a new terminal and run:

```bash
# Access the backend container
docker-compose exec backend bash

# Run Alembic migrations
cd /app
alembic upgrade head

# Exit the container
exit
```

### 3. Verify Backend

Visit `http://localhost:8000/docs` to see the API documentation (Swagger UI).

You should see the following endpoints:
- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Login with email and password
- `GET /api/v1/users/me` - Get current user info (requires authentication)

## Mobile App Setup

### 1. Install Dependencies

```bash
cd mobile-app
flutter pub get
```

### 2. Configure Backend URL

The mobile app is configured to connect to the backend at:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: Update the URL in `lib/services/auth_service.dart` to your machine's IP address

If you need to change the backend URL, edit `mobile-app/lib/services/auth_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:8000/api/v1';
```

### 3. Run the App

```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# Or select a device
flutter devices
flutter run -d <device-id>
```

## Testing the Authentication Flow

### 1. Register a New User

1. Launch the mobile app
2. On the Login screen, click "Don't have an account? Register"
3. Fill in:
   - Email: `test@example.com`
   - Password: `password123`
   - First Name: `Test` (optional)
   - Last Name: `User` (optional)
4. Click "Register"
5. You should see a success message

### 2. Login

1. On the Login screen, enter:
   - Email: `test@example.com`
   - Password: `password123`
2. Click "Login"
3. You should be redirected to the Home screen

### 3. View User Info

The Home screen displays:
- Your display name (first name + last name or email)
- Your email address
- A logout button

### 4. Logout and Token Persistence

1. Click "Logout" - you'll be returned to the Login screen
2. Close the app completely
3. Reopen the app - you'll see the Login screen (token was cleared)

To test token persistence without logout:
1. Login successfully
2. Close the app (don't logout)
3. Reopen the app - you should automatically be taken to the Home screen

## API Testing with cURL

You can also test the backend directly:

### Register
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test2@example.com",
    "password": "password123",
    "first_name": "Test",
    "last_name": "User"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test2@example.com&password=password123"
```

Save the `access_token` from the response.

### Get Current User
```bash
curl -X GET http://localhost:8000/api/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

## Database Access

To view the PostgreSQL database:

```bash
# Access the database
docker-compose exec postgres psql -U qeyafa -d qeyafa_db

# List tables
\dt

# View users
SELECT * FROM users;

# Exit
\q
```

## Troubleshooting

### Backend Issues

**Problem**: Migration fails with "could not translate host name"
- **Solution**: Make sure the PostgreSQL container is running: `docker-compose ps`

**Problem**: Authentication endpoints return 404
- **Solution**: Check that the backend container is running and accessible at `http://localhost:8000/docs`

### Mobile App Issues

**Problem**: Network error when trying to login/register
- **Solution**: 
  - For Android Emulator, ensure you're using `http://10.0.2.2:8000`
  - For physical devices, update to your machine's IP address
  - Check that backend is accessible: `curl http://localhost:8000/health`

**Problem**: App crashes on startup
- **Solution**: Run `flutter clean && flutter pub get` and rebuild

**Problem**: Cannot save token (flutter_secure_storage error)
- **Solution**: For Android, ensure you have a device/emulator running Android 6.0+

## Architecture

### Backend (FastAPI)
- **Framework**: FastAPI with SQLAlchemy ORM
- **Database**: PostgreSQL
- **Authentication**: JWT tokens with passlib bcrypt hashing
- **Migrations**: Alembic

### Mobile App (Flutter)
- **State Management**: Riverpod
- **Secure Storage**: flutter_secure_storage for JWT tokens
- **HTTP Client**: http package
- **Architecture**: Clean separation of screens, services, providers, and models

## Security Notes

1. The `.env` file contains sensitive keys - **never commit this to version control**
2. Change the `SECRET_KEY` in production to a strong, random value
3. In production, update CORS settings to allow only specific origins
4. Use HTTPS in production for all API calls

## Next Steps

This completes Sprint 1. Future enhancements could include:
- Password reset functionality
- Email verification
- Profile editing
- Token refresh mechanism
- Social authentication
