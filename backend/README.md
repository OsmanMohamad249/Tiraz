```markdown
# Backend (FastAPI) - Boilerplate

This folder contains a minimal FastAPI application to be used as the backend for Tiraz.

Quick start (local):
1. Create virtual env:
   python -m venv .venv
   source .venv/bin/activate
2. Install deps:
   pip install -r requirements.txt
3. Run:
   uvicorn main:app --reload --port 8000

Docker (local):
   docker build -t tiraz-backend:dev -f Dockerfile .
   docker run --rm -p 8000:8000 tiraz-backend:dev

Endpoints:
- GET /health -> basic health check

Next steps:
- Add routers: auth, users, measurements, designs, orders
- Add DB (PostgreSQL) integration and config
- Add tests and CI steps
```
