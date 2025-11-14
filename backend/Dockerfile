# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install netcat and build tools for building Python packages
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	netcat-traditional \
	build-essential \
	gcc \
	libpq-dev \
	python3-dev \
	libffi-dev \
	wget \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
# Ensure pip, setuptools and wheel are up-to-date to build packages reliably
RUN pip install --upgrade pip setuptools wheel && \
	pip install Cython==0.29.34 || true

RUN pip install --no-cache-dir --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

COPY backend/ .

# Make entrypoint script executable
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
