# Migration Note: From Flask Demo to MVP

## Overview

This repository has been transformed from a simple Flask demo application to the comprehensive Tiraz AI Tailoring MVP platform.

## What Changed

### Old Structure (Flask Demo)
```
Tiraz/
├── app/              # Flask application
├── config/           # Flask config
├── tests/            # Flask tests
├── run.py            # Flask entry point
└── requirements.txt  # Flask dependencies
```

### New Structure (MVP)
```
Tiraz/
├── mobile-app/          # React Native mobile application
├── backend/             # Node.js/Express API server
├── ai-models/           # Python AI/ML services
├── docs/                # Comprehensive documentation
├── docker-compose.yml   # Local development environment
├── tiraz-prototype-v4.html  # Interactive prototype
└── README.md            # MVP documentation
```

## Old Files

The following files from the original Flask demo are preserved for reference:

- `app/` - Original Flask application
- `config/` - Original Flask configuration
- `tests/` - Original Flask tests
- `run.py` - Original Flask entry point
- `requirements.txt` - Original Flask requirements
- `README-OLD.md` - Original README

**Note**: These files are not part of the MVP and should not be modified or used. They are kept for historical reference only.

## MVP Components

The new MVP consists of three main components:

1. **Mobile App** (`mobile-app/`)
   - React Native application
   - User-facing interface
   - iOS and Android support

2. **Backend API** (`backend/`)
   - Node.js/Express server
   - RESTful API
   - MongoDB integration

3. **AI Models** (`ai-models/`)
   - Python AI service
   - Body measurement extraction
   - Flask API wrapper

## Getting Started with MVP

To work with the new MVP structure:

1. Follow the [SETUP.md](docs/SETUP.md) guide
2. Use Docker Compose for local development
3. Read [DEVELOPMENT.md](docs/DEVELOPMENT.md) for coding guidelines
4. Check [API.md](docs/API.md) for API documentation

## Why the Change?

The original Flask demo was a learning project. The MVP represents the actual Tiraz AI Tailoring Platform with:

- Production-ready architecture
- Mobile-first approach
- AI/ML integration
- Microservices design
- Comprehensive documentation
- Docker deployment

## Questions?

If you have questions about the migration or the new structure, please:

1. Check the documentation in `docs/`
2. Review the new README.md
3. Open an issue on GitHub

---

Last Updated: November 8, 2024
