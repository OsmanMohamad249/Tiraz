# Tiraz (طِرَاز) - AI Tailoring Application (MVP)

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node](https://img.shields.io/badge/Node-18+-green.svg)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![React Native](https://img.shields.io/badge/React%20Native-0.73-61dafb.svg)](https://reactnative.dev/)

## 🎯 Project Vision

**Tiraz** is an AI-powered custom tailoring platform designed to eliminate the biggest fears of online tailoring: incorrect sizing and poor fit. By leveraging computer vision and machine learning, Tiraz provides accurate body measurements from photos and enables users to design perfect-fit custom garments.

### Long-Term Vision
To build an all-in-one "Fashion-Tech Ecosystem" that becomes the global platform for custom-tailored clothing.

### Current Scope: MVP (Phase 1)
This repository contains the **Minimum Viable Product (MVP)** implementation with core features only.

## 📋 MVP Features

### 1. AI Measurement Engine (Core)
- Upload 4 photos (front, back, left, right) + height/weight
- Computer vision model for accurate body measurements
- Returns comprehensive measurements (chest, waist, shoulders, etc.)

### 2. Design Studio (Limited)
- Interactive garment design interface
- **MVP Categories**: Men's Thobes and Men's Shirts only
- Curated fabric catalog
- Customization options (collar, sleeves, buttons)

### 3. Virtual Try-On Room (Basic)
- 3D avatar generation from measurements
- Garment preview on avatar
- 360-degree rotation capability

### 4. User Accounts & Order History
- User registration and authentication
- Profile management
- Order tracking (Current Orders & Past Orders)
- Measurement storage

### 5. Backend & Tailor Integration
- RESTful API for all operations
- Admin panel for order management
- Tech pack generation (Order + Measurements + Design)
- Integration with tailoring partner

## 🏗️ Architecture

```
Tiraz-MVP/
├── mobile-app/          # React Native mobile application
├── backend/             # Node.js/Express API server
├── ai-models/           # Python AI/ML services
├── docker/              # Docker configuration
├── docs/                # Documentation
├── docker-compose.yml   # Local development environment
└── README.md           # This file
```

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18
- Python >= 3.8
- Docker & Docker Compose
- React Native development environment
- MongoDB (included in Docker setup)

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/OsmanMohamad249/Tiraz.git
cd Tiraz

# Start all services with Docker Compose
docker-compose up -d

# Check service status
docker-compose ps
```

**Services will be available at:**
- Backend API: http://localhost:5000
- AI Service: http://localhost:8000
- MongoDB UI: http://localhost:8081 (admin/admin)
- MongoDB: localhost:27017

### Option 2: Manual Setup

#### 1. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm run dev
```

#### 2. AI Models Setup

```bash
cd ai-models
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python measurement_model/api.py
```

#### 3. Mobile App Setup

```bash
cd mobile-app
npm install

# For iOS (macOS only)
cd ios && pod install && cd ..
npm run ios

# For Android
npm run android
```

## 📱 Mobile App

The React Native mobile app provides the user-facing interface for all MVP features.

**Key Screens:**
- Home Dashboard
- AI Measurement Flow
- Design Studio
- Virtual Try-On
- Order History
- Profile & Settings

See [mobile-app/README.md](mobile-app/README.md) for details.

## 🔧 Backend API

Node.js/Express backend providing RESTful APIs.

**Main Endpoints:**
- `/api/v1/users` - User authentication & profiles
- `/api/v1/measurements` - AI measurement processing
- `/api/v1/design` - Design studio operations
- `/api/v1/orders` - Order management

See [backend/README.md](backend/README.md) for API documentation.

## 🤖 AI Models

Python-based AI services for body measurement extraction.

**Components:**
- Measurement Model: Computer vision for body measurements
- Virtual Try-On: 3D avatar generation (basic)

See [ai-models/README.md](ai-models/README.md) for details.

## 📚 Documentation

- [API Documentation](docs/API.md)
- [Setup Guide](docs/SETUP.md)
- [Development Workflow](docs/DEVELOPMENT.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🎨 Interactive Prototype

A complete interactive HTML prototype (`tiraz-prototype-v4.html`) is included to visualize the full future ecosystem. This prototype demonstrates:

- Complete user flows
- Future features (AI Stylist, Subscriptions, B2B Portal)
- Inspiration Gallery
- Digital Wardrobe
- Settings & Management

Open `tiraz-prototype-v4.html` in a browser to explore the full vision.

**Note:** This prototype is for visualization only. The actual MVP implementation is limited to core features listed above.

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# AI model tests
cd ai-models
pytest tests/

# Mobile app tests
cd mobile-app
npm test
```

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild containers
docker-compose up -d --build

# Reset everything
docker-compose down -v
```

## 📊 GitHub Project Board

To set up task tracking:

1. Go to repository "Projects" tab
2. Create new project: "Tiraz MVP Development"
3. Add columns: Todo, In Progress, Testing, Done
4. Create issues for MVP tasks:
   - User Authentication
   - AI Measurement Model
   - Design Studio UI
   - Virtual Try-On Integration
   - Order Management
   - Backend API Endpoints
   - Mobile App Navigation
   - Docker Setup

## 🎯 Target Audience (MVP)

Tech-savvy professionals (B2C) who value:
- Convenience
- Perfect fit
- Personalization
- Quality craftsmanship

Primary focus: Men's traditional and modern wear (Thobes and Shirts)

## 🛣️ Roadmap

### Phase 1: MVP (Current)
- ✅ Core measurement engine
- ✅ Basic design studio
- ✅ Simple virtual try-on
- ✅ User accounts & orders
- ✅ Single tailor integration

### Phase 2: Enhanced Platform
- [ ] AI Stylist recommendations
- [ ] Expanded garment categories
- [ ] Advanced 3D visualization
- [ ] Multiple tailor network
- [ ] Mobile payments integration

### Phase 3: Full Ecosystem
- [ ] Subscription plans
- [ ] B2B/Corporate portal
- [ ] Referral program
- [ ] Inspiration gallery & social features
- [ ] Global marketplace

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

**Tiraz Development Team**
- Project Owner: Osman Mohamad - [@OsmanMohamad249](https://github.com/OsmanMohamad249)

## 🔗 Links

- Repository: [https://github.com/OsmanMohamad249/Tiraz](https://github.com/OsmanMohamad249/Tiraz)
- Issues: [https://github.com/OsmanMohamad249/Tiraz/issues](https://github.com/OsmanMohamad249/Tiraz/issues)
- Project Board: [https://github.com/OsmanMohamad249/Tiraz/projects](https://github.com/OsmanMohamad249/Tiraz/projects)

## 📧 Contact

For questions or support, please open an issue or contact the team.

---

صُنع بـ ❤️ | Made with ❤️

**Note**: This is the MVP (Phase 1) implementation. Features marked for Phase 2 and Phase 3 are part of the long-term vision and are not included in this release.
