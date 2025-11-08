# Backend API

Node.js/Express backend for the Tiraz AI Tailoring Platform (MVP).

## Features

- **RESTful API**: Well-structured endpoints for all MVP features
- **Authentication**: JWT-based user authentication
- **File Upload**: Multer for handling photo uploads
- **Database**: MongoDB with Mongoose ODM
- **Security**: Helmet, CORS, rate limiting
- **Validation**: Joi for request validation

## Tech Stack

- Node.js 18+
- Express.js 4.x
- MongoDB
- JWT for authentication
- Multer for file uploads

## Prerequisites

- Node.js >= 18
- MongoDB (local or Atlas)
- npm or yarn

## Installation

```bash
# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your configuration
```

## Environment Variables

Create a `.env` file:

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/tiraz
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRE=7d
AI_SERVICE_URL=http://localhost:8000
MAX_FILE_SIZE=10485760
```

## Running the Server

```bash
# Development mode with hot reload
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/v1/users/register` - Register new user
- `POST /api/v1/users/login` - Login user
- `GET /api/v1/users/profile` - Get user profile (protected)

### Measurements
- `POST /api/v1/measurements/upload` - Upload photos
- `POST /api/v1/measurements/process` - Process measurements with AI
- `GET /api/v1/measurements/:userId` - Get user measurements

### Design Studio
- `GET /api/v1/design/categories` - Get garment categories
- `GET /api/v1/design/fabrics/:category` - Get fabrics for category
- `POST /api/v1/design/save` - Save design
- `GET /api/v1/design/user/:userId` - Get user designs

### Orders
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders/user/:userId` - Get user orders
- `GET /api/v1/orders/:orderId` - Get order details
- `PATCH /api/v1/orders/:orderId/status` - Update order status

## Project Structure

```
src/
├── routes/           # API routes
├── controllers/      # Request handlers
├── models/           # Database models
├── middleware/       # Custom middleware
├── utils/            # Utility functions
└── server.js         # Entry point
```

## Testing

```bash
npm test
```

## License

MIT
