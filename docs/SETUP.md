# Qeyafa MVP - Setup Guide

This guide will help you set up the Qeyafa MVP application for local development.

## Prerequisites

### Required Software

1. **Node.js** (v18 or higher)
   - Download from https://nodejs.org/
   - Verify installation: `node --version`

2. **Python** (v3.8 or higher)
   - Download from https://python.org/
   - Verify installation: `python --version`

3. **Docker & Docker Compose**
   - Download from https://docker.com/
   - Verify installation: `docker --version` and `docker-compose --version`

4. **MongoDB** (if not using Docker)
   - Download from https://mongodb.com/
   - Or use MongoDB Atlas (cloud)

5. **React Native Development Environment**
   - Follow official guide: https://reactnative.dev/docs/environment-setup
   - For iOS: Xcode (macOS only)
   - For Android: Android Studio

## Setup Options

### Option 1: Docker Setup (Recommended for Backend/AI)

This is the easiest way to run backend services.

```bash
# 1. Clone the repository
git clone https://github.com/OsmanMohamad249/Qeyafa.git
cd Qeyafa

# 2. Start all services
docker-compose up -d

# 3. Verify services are running
docker-compose ps

# You should see:
# - qeyafa-backend (port 5000)
# - qeyafa-ai (port 8000)
# - qeyafa-mongodb (port 27017)
# - qeyafa-mongo-express (port 8081)

# 4. Check logs if needed
docker-compose logs -f backend
docker-compose logs -f ai-service
```

**Service URLs:**
- Backend API: http://localhost:5000
- AI Service: http://localhost:8000
- MongoDB UI: http://localhost:8081 (login: admin/admin)

### Option 2: Manual Setup

If you prefer to run services directly without Docker:

#### Step 1: Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your settings
nano .env  # or use any text editor

# Start development server
npm run dev

# Backend will run on http://localhost:5000
```

#### Step 2: AI Models Setup

```bash
# Navigate to ai-models directory
cd ai-models

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start AI service
python measurement_model/api.py

# AI service will run on http://localhost:8000
```

#### Step 3: MongoDB Setup

**Local MongoDB:**
```bash
# Install MongoDB from mongodb.com
# Start MongoDB service
mongod --dbpath /path/to/data/db
```

**Or use MongoDB Atlas (Cloud):**
1. Create account at mongodb.com/atlas
2. Create a free cluster
3. Get connection string
4. Update MONGODB_URI in backend/.env

### Option 3: Mobile App Setup

The mobile app needs to be set up separately as it runs on a device/emulator.

```bash
# Navigate to mobile-app directory
cd mobile-app

# Install dependencies
npm install

# For iOS (macOS only):
cd ios
pod install
cd ..

# Start Metro bundler
npm start

# In another terminal, run the app:
# For iOS:
npm run ios

# For Android (make sure emulator is running):
npm run android
```

## Configuration

### Backend Environment Variables

Edit `backend/.env`:

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/qeyafa
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRE=7d
AI_SERVICE_URL=http://localhost:8000
MAX_FILE_SIZE=10485760
```

### Mobile App Configuration

Edit `mobile-app/src/services/api.js` to set API URL:

```javascript
const API_BASE_URL = 'http://localhost:5000/api/v1';
// For Android emulator use: http://10.0.2.2:5000/api/v1
// For iOS simulator use: http://localhost:5000/api/v1
// For physical device use: http://YOUR_COMPUTER_IP:5000/api/v1
```

## Verification

### Test Backend API

```bash
# Health check
curl http://localhost:5000/health

# Expected response:
# {"status":"success","message":"Qeyafa API is running","timestamp":"..."}
```

### Test AI Service

```bash
# Health check
curl http://localhost:8000/health

# Expected response:
# {"status":"healthy","service":"Qeyafa AI Measurement Service","version":"1.0.0"}
```

### Test Mobile App

1. Open the app on emulator/device
2. You should see the home screen with feature cards
3. Try navigating to different screens
4. Check console for any errors

## Troubleshooting

### Backend Issues

**Problem:** `Cannot connect to MongoDB`
```bash
# Solution: Make sure MongoDB is running
docker-compose ps  # If using Docker
# or
mongod --version  # If using local MongoDB
```

**Problem:** `Port 5000 already in use`
```bash
# Solution: Change PORT in .env file or stop other service
lsof -ti:5000 | xargs kill  # Kill process on port 5000
```

### AI Service Issues

**Problem:** `Module not found` errors
```bash
# Solution: Reinstall dependencies
cd ai-models
pip install -r requirements.txt --force-reinstall
```

**Problem:** `OpenCV error`
```bash
# Solution: Install system dependencies (Linux)
sudo apt-get install libgl1-mesa-glx libglib2.0-0
```

### Mobile App Issues

**Problem:** `Metro bundler not starting`
```bash
# Solution: Clear cache and restart
cd mobile-app
npm start -- --reset-cache
```

**Problem:** `Unable to resolve module`
```bash
# Solution: Clear node modules and reinstall
rm -rf node_modules
npm install
```

**Problem:** `iOS build fails`
```bash
# Solution: Clean and rebuild
cd ios
pod deintegrate
pod install
cd ..
npm run ios
```

**Problem:** `Android build fails`
```bash
# Solution: Clean gradle
cd android
./gradlew clean
cd ..
npm run android
```

## Development Workflow

1. **Start Backend Services**
   ```bash
   docker-compose up -d
   # or manually start backend and AI service
   ```

2. **Start Mobile App**
   ```bash
   cd mobile-app
   npm start
   ```

3. **Make Changes**
   - Backend: Changes auto-reload with nodemon
   - AI Service: Restart service after changes
   - Mobile App: Changes hot-reload automatically

4. **Test Changes**
   ```bash
   # Backend tests
   cd backend && npm test
   
   # Mobile app tests
   cd mobile-app && npm test
   ```

5. **Commit Changes**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

## Next Steps

- Read [API.md](API.md) for API documentation
- Read [DEVELOPMENT.md](DEVELOPMENT.md) for development guidelines
- Explore the interactive prototype: Open `qeyafa-prototype-v4.html` in browser

## Support

If you encounter issues:
1. Check this setup guide again
2. Search existing issues on GitHub
3. Create a new issue with:
   - Error message
   - Steps to reproduce
   - Your environment (OS, Node version, etc.)

---

Happy coding! 🚀
