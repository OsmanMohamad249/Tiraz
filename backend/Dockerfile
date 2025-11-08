FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Create uploads directory
RUN mkdir -p uploads/measurements

# Expose port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
