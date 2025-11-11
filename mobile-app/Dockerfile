# mobile-app/Dockerfile (optional dev container for Flutter web)
FROM cirrusci/flutter:stable

WORKDIR /app
COPY . .

# Skip flutter pub get during build due to network restrictions
# It will be run at container startup
CMD ["sh", "-c", "flutter pub get && flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0"]
