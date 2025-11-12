# Qeyafa Infrastructure Guide

## Overview

Qeyafa is a full-stack application with three main components:
- **Backend**: FastAPI (Python) REST API running on port 8000
- **Admin Portal**: Next.js (React/TypeScript) web application running on port 3000
- **Mobile App**: Flutter mobile application

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Admin Portal   │────▶│     Backend     │────▶│   PostgreSQL    │
│   (Next.js)     │     │    (FastAPI)    │     │    Database     │
│   Port 3000     │     │   Port 8000     │     │   Port 5432     │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       ▲
         │                       │
         │              ┌────────┴────────┐
         │              │                 │
         └──────────────│   Mobile App    │
                        │    (Flutter)    │
                        │                 │
                        └─────────────────┘
```

## Prerequisites

- Docker and Docker Compose
- Python 3.11+ (for local backend development)
- Node.js 18+ (for admin portal development)
- Flutter 3.7+ (for mobile app development)

## Quick Start

### 1. Setup Environment

Run the setup script to create environment files:

```bash
./setup-infrastructure.sh
```

This will:
- Create `.env` files from templates
- Generate secure SECRET_KEY values
- Validate environment configuration

### 2. Start Infrastructure with Docker

Start all services:

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

### 3. Verify Services

- **Backend API**: http://localhost:8000/docs (Swagger UI)
- **Backend Health**: http://localhost:8000/health
- **PostgreSQL**: localhost:5432
- **AI Models**: localhost:8001

### 4. Setup Admin Portal (Development)

```bash
cd admin-portal
npm install
npm run dev
```

Access at: http://localhost:3000

### 5. Setup Mobile App (Development)

```bash
cd mobile-app
flutter pub get
flutter run
```

## Environment Configuration

### Root .env File

Controls Docker Compose environment:

```bash
# Database credentials
POSTGRES_USER=qeyafa
POSTGRES_PASSWORD=qeyafa_password
POSTGRES_DB=qeyafa_db

# Backend configuration
SECRET_KEY=<generated-secure-key>
DATABASE_URL=postgresql://qeyafa:qeyafa_password@postgres:5432/qeyafa_db

# Environment
ENVIRONMENT=development
DEBUG=true
```

### Backend .env File

Controls backend application:

```bash
# Database
DATABASE_URL=postgresql://qeyafa:qeyafa_password@postgres:5432/qeyafa_db

# Security
SECRET_KEY=<generated-secure-key>
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Environment
ENVIRONMENT=development
DEBUG=true
```

### Admin Portal .env File

Controls admin portal:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

## Docker Services

### Backend Service

- **Image**: Python 3.11-slim
- **Port**: 8000
- **Features**:
  - Auto-reloading for development
  - Database migrations on startup
  - Health check endpoint
  - API documentation at /docs

### PostgreSQL Service

- **Image**: PostgreSQL 15
- **Port**: 5432
- **Credentials**: Set via environment variables
- **Persistent Storage**: Docker volume `postgres-data`

### AI Models Service

- **Port**: 8001
- **Purpose**: Machine learning model inference
- **Persistent Storage**: Docker volume `ai-data`

### Flutter Dev Service (Optional)

- **Image**: cirrusci/flutter:stable (Flutter 3.7.7)
- **Port**: 8080
- **Purpose**: Development container for Flutter web

## Backend Development

### Local Setup (Without Docker)

1. Create virtual environment:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Setup environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Run migrations:
```bash
alembic upgrade head
```

5. Start server:
```bash
uvicorn main:app --reload --port 8000
```

### Running Tests

Tests require a running PostgreSQL database:

```bash
# Start database with Docker
docker compose up -d postgres

# Run tests
cd backend
pytest tests/ -v
```

### Database Migrations

Create a new migration:
```bash
cd backend
alembic revision --autogenerate -m "Description of changes"
```

Apply migrations:
```bash
alembic upgrade head
```

Rollback migration:
```bash
alembic downgrade -1
```

## Admin Portal Development

### Local Setup

1. Install dependencies:
```bash
cd admin-portal
npm install
```

2. Setup environment:
```bash
cp .env.example .env
```

3. Start development server:
```bash
npm run dev
```

4. Build for production:
```bash
npm run build
npm start
```

### Linting

```bash
npm run lint
```

## Mobile App Development

### Local Setup

1. Get dependencies:
```bash
cd mobile-app
flutter pub get
```

2. Run on device/emulator:
```bash
flutter run
```

3. Run on web:
```bash
flutter run -d chrome
```

### Analysis

```bash
flutter analyze
```

### Testing

```bash
flutter test
```

## Common Tasks

### Reset Database

```bash
docker compose down -v
docker compose up -d
```

### View Backend Logs

```bash
docker compose logs -f backend
```

### Access PostgreSQL

```bash
docker compose exec postgres psql -U qeyafa -d qeyafa_db
```

### Rebuild Services

```bash
docker compose build --no-cache
docker compose up -d
```

### Stop All Services

```bash
docker compose down
```

## Troubleshooting

### Backend won't start

1. Check environment variables:
```bash
cd backend
python validate_env.py
```

2. Check database connection:
```bash
docker compose logs postgres
```

3. Check backend logs:
```bash
docker compose logs backend
```

### Database connection errors

1. Ensure PostgreSQL is running:
```bash
docker compose ps postgres
```

2. Check DATABASE_URL format:
```
postgresql://user:password@host:port/database
```

3. For Docker services, use `postgres` as host
4. For local development, use `localhost` as host

### Port conflicts

If ports are already in use:

1. Check what's using the port:
```bash
lsof -i :8000  # On macOS/Linux
netstat -ano | findstr :8000  # On Windows
```

2. Stop the conflicting process or change the port in docker-compose.yml

### Admin portal can't connect to backend

1. Verify backend is running: http://localhost:8000/health
2. Check NEXT_PUBLIC_API_BASE_URL in admin-portal/.env
3. Check CORS_ORIGINS in backend .env includes http://localhost:3000

### Flutter dependency issues

1. Clean and get dependencies:
```bash
cd mobile-app
flutter clean
flutter pub get
```

2. Check Flutter version:
```bash
flutter --version
```

Required: Flutter 2.19+ (compatible with SDK constraint in pubspec.yaml)

## Production Deployment

### Environment Variables

1. Set ENVIRONMENT=production
2. Use strong SECRET_KEY (generate with: `python -c "import secrets; print(secrets.token_urlsafe(32))"`)
3. Set proper DATABASE_URL for production database
4. Update CORS_ORIGINS to production domains
5. Set DEBUG=false

### Backend

1. Use production-grade WSGI server (Gunicorn is included)
2. Setup reverse proxy (Nginx/Caddy)
3. Enable HTTPS
4. Setup database backups
5. Monitor logs and metrics

### Admin Portal

1. Build optimized bundle: `npm run build`
2. Deploy to hosting platform (Vercel, Netlify, etc.)
3. Set production environment variables
4. Enable CDN

## Security Checklist

- [ ] Strong SECRET_KEY values (min 32 chars)
- [ ] ENVIRONMENT set to production
- [ ] DEBUG set to false in production
- [ ] Proper CORS_ORIGINS configured
- [ ] Database credentials secured
- [ ] .env files not committed to git
- [ ] HTTPS enabled in production
- [ ] Regular security updates

## Support

For issues or questions:
1. Check this documentation
2. Review error logs
3. Open an issue on GitHub
4. Contact the development team
