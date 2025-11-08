# Tiraz — AI-Powered Custom Tailoring Platform

Tiraz is a comprehensive application for managing custom tailoring, featuring AI-powered measurements, a modern web interface, and a RESTful API.

## 🏗️ Architecture

The repository contains multiple services:

- **Python Flask App** (root): Demo web UI with item management (runs on port 8080)
- **Node.js Backend API** (`./backend`): RESTful API for mobile apps (runs on port 8080 via Docker)
- **AI Service** (`./ai-models`): Python-based AI measurement service (runs on port 8000)
- **MongoDB**: Database for the backend API
- **Mongo Express**: Web-based MongoDB admin interface (port 8081)

## 🚀 Quick Start

### Local Development (Python Flask App)

The Python Flask app provides a demo interface for managing items and styles.

#### Prerequisites
- Python 3.8+
- pip

#### Installation

```bash
# 1. Clone the repository
git clone https://github.com/OsmanMohamad249/Tiraz.git
cd Tiraz

# 2. Create a virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run the application
python run.py
```

The application will start on **http://localhost:8080**

#### Environment Variables

You can customize the port using the `PORT` environment variable:

```bash
PORT=3000 python run.py  # Run on port 3000
```

Other environment variables:
- `FLASK_ENV`: Set to `production` for production mode (default: `development`)
- `SECRET_KEY`: Secret key for sessions (default: auto-generated for development)
- `DATABASE_URL`: Database URL (default: SQLite in instance folder)

### Docker Deployment (Full Stack)

Run all services together using Docker Compose:

#### Prerequisites
- Docker
- Docker Compose

#### Installation

```bash
# 1. Clone the repository
git clone https://github.com/OsmanMohamad249/Tiraz.git
cd Tiraz

# 2. Build and start all services
docker-compose up --build

# 3. Access the services:
# - Backend API: http://localhost:8080
# - AI Service: http://localhost:8000
# - Mongo Express: http://localhost:8081
# - MongoDB: localhost:27017
```

#### Docker Services

The `docker-compose.yml` defines the following services:

| Service | Port | Description |
|---------|------|-------------|
| backend | 8080 | Node.js REST API for mobile apps |
| ai-service | 8000 | Python AI measurement service |
| mongodb | 27017 | MongoDB database |
| mongo-express | 8081 | MongoDB web interface (admin/admin) |

#### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (data will be lost)
docker-compose down -v
```

## 📋 API Endpoints

### Python Flask App

- `GET /` - Home page
- `GET /health` - Health check endpoint (returns `{"status": "ok"}`)
- `GET /items` - List all items
- `GET /items/<id>` - View item details
- `POST /items/create` - Create new item
- `POST /items/<id>/edit` - Edit item
- `POST /items/<id>/delete` - Delete item

### Node.js Backend API

- `GET /health` - Health check
- `GET /api/v1/users` - User management
- `GET /api/v1/measurements` - Measurements
- `GET /api/v1/design` - Design management
- `GET /api/v1/orders` - Order management

## 🧪 Testing

### Python Flask App Tests

```bash
# Install development dependencies
pip install pytest

# Run all tests
pytest

# Run specific test file
pytest tests/test_health.py

# Run with verbose output
pytest -v

# Run existing unittest tests
python -m unittest tests.test_app
```

### Backend API Tests (Node.js)

```bash
cd backend
npm install
npm test
```

## 🐛 Troubleshooting

### Port Already in Use

If you get an error that port 8080 is already in use:

**For Python Flask app:**
```bash
# Use a different port
PORT=3000 python run.py
```

**For Docker:**
```bash
# Edit docker-compose.yml and change the port mapping:
# Change "8080:5000" to "3000:5000"
docker-compose up
```

### ERR_EMPTY_RESPONSE in Browser

This usually means the application isn't running or is on a different port.

**Solutions:**
1. Make sure the application is running: `python run.py`
2. Check the port in the terminal output
3. Access http://localhost:8080 (or the port shown in terminal)
4. For Docker, ensure containers are running: `docker-compose ps`

### Database Connection Issues

**Python Flask App:**
- The app uses SQLite by default (stored in `instance/tiraz.db`)
- No setup required for local development

**Docker Backend:**
- Ensure MongoDB container is running: `docker-compose ps`
- Wait for MongoDB to initialize (about 10-20 seconds on first run)
- Check logs: `docker-compose logs mongodb`

### Docker Container Won't Start

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs backend
docker-compose logs ai-service

# Rebuild containers
docker-compose down
docker-compose up --build

# Reset everything (WARNING: deletes all data)
docker-compose down -v
docker-compose up --build
```

### Python Dependencies Issues

```bash
# Upgrade pip
pip install --upgrade pip

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Clear pip cache if needed
pip cache purge
```

## 📁 Project Structure

```
Tiraz/
├── app/                      # Python Flask application
│   ├── __init__.py          # App factory
│   ├── controllers/         # Route controllers
│   ├── models/              # Database models
│   ├── static/              # CSS, JS files
│   └── templates/           # HTML templates
├── backend/                 # Node.js backend API
│   ├── src/                 # Source code
│   ├── Dockerfile           # Backend Docker config
│   └── package.json         # Node.js dependencies
├── ai-models/               # Python AI service
│   ├── Dockerfile           # AI service Docker config
│   └── requirements.txt     # Python dependencies
├── tests/                   # Test files
│   ├── test_app.py         # Flask app tests
│   └── test_health.py      # Health endpoint tests
├── config/                  # Configuration files
├── docker-compose.yml       # Docker services definition
├── requirements.txt         # Python dependencies
├── run.py                   # Flask app entry point
└── README.md               # This file
```

## 🔧 Development

### Adding New Features

1. **Python Flask App**: Add routes in `app/controllers/`, models in `app/models/`, and templates in `app/templates/`
2. **Backend API**: Add routes in `backend/src/routes/`
3. **Tests**: Add tests in `tests/` directory

### Environment Setup

Create a `.env` file in the root directory (for Docker) or backend directory:

```env
# Backend API
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://mongodb:27017/tiraz
JWT_SECRET=your-secret-key-here

# AI Service
AI_SERVICE_URL=http://ai-service:8000
```

## 📚 Documentation

- [Backend API README](./backend/README.md)
- [AI Models README](./ai-models/README.md)
- [Mobile App README](./mobile-app/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

Tiraz Team

---

**Note**: This is a development setup. For production deployment, use a production-grade WSGI server like Gunicorn for the Python app and configure proper security settings for all services.
