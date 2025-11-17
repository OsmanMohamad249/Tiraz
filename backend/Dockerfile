# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install netcat for database readiness check
RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

COPY backend/ .

# Make entrypoint script executable
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
