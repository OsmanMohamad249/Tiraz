# Qeyafa API Documentation

Base URL: `http://localhost:5000/api/v1`

## Authentication

Most endpoints require authentication. Include JWT token in headers:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Users

#### Register User
```http
POST /api/v1/users/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword",
  "phone": "+1234567890"
}

Response: 201 Created
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "123",
      "name": "John Doe",
      "email": "john@example.com"
    },
    "token": "jwt-token-here"
  }
}
```

#### Login
```http
POST /api/v1/users/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword"
}

Response: 200 OK
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": "123",
      "email": "john@example.com"
    },
    "token": "jwt-token-here"
  }
}
```

#### Get Profile
```http
GET /api/v1/users/profile
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "user": {
      "id": "123",
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890"
    }
  }
}
```

#### Update Profile
```http
PUT /api/v1/users/:userId
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "John Updated",
  "phone": "+9876543210"
}

Response: 200 OK
{
  "status": "success",
  "message": "Profile updated successfully",
  "data": {
    "user": {
      "id": "123",
      "name": "John Updated",
      "phone": "+9876543210"
    }
  }
}
```

### Measurements

#### Upload Photos
```http
POST /api/v1/measurements/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- photos[0]: <front-photo-file>
- photos[1]: <back-photo-file>
- photos[2]: <left-photo-file>
- photos[3]: <right-photo-file>

Response: 200 OK
{
  "status": "success",
  "message": "Photos uploaded successfully",
  "data": {
    "photos": [
      {
        "filename": "1234567890-front.jpg",
        "path": "uploads/measurements/1234567890-front.jpg",
        "size": 1024000
      },
      ...
    ]
  }
}
```

#### Process Measurements
```http
POST /api/v1/measurements/process
Authorization: Bearer <token>
Content-Type: application/json

{
  "photos": ["photo1.jpg", "photo2.jpg", "photo3.jpg", "photo4.jpg"],
  "height": 175,
  "weight": 70,
  "userId": "123"
}

Response: 200 OK
{
  "status": "success",
  "message": "Measurements processed successfully",
  "data": {
    "measurements": {
      "chest": 98,
      "waist": 82,
      "shoulders": 44,
      "armLength": 62,
      "neck": 38,
      "hip": 96,
      "height": 175,
      "weight": 70,
      "unit": "cm"
    },
    "userId": "123",
    "processedAt": "2024-11-08T02:00:00.000Z"
  }
}
```

#### Get User Measurements
```http
GET /api/v1/measurements/:userId
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "measurements": {
      "userId": "123",
      "chest": 98,
      "waist": 82,
      "shoulders": 44,
      "armLength": 62,
      "neck": 38,
      "hip": 96,
      "height": 175,
      "weight": 70,
      "unit": "cm",
      "lastUpdated": "2024-11-08T02:00:00.000Z"
    }
  }
}
```

### Design Studio

#### Get Categories
```http
GET /api/v1/design/categories

Response: 200 OK
{
  "status": "success",
  "data": {
    "categories": [
      {
        "id": "thobes",
        "name": "Men's Thobes",
        "description": "Traditional and modern thobe designs",
        "image": "/images/categories/thobes.jpg"
      },
      {
        "id": "shirts",
        "name": "Men's Shirts",
        "description": "Custom tailored shirts",
        "image": "/images/categories/shirts.jpg"
      }
    ]
  }
}
```

#### Get Fabrics
```http
GET /api/v1/design/fabrics/:category

Response: 200 OK
{
  "status": "success",
  "data": {
    "fabrics": [
      {
        "id": "1",
        "name": "Premium Cotton",
        "description": "Soft, breathable cotton",
        "price": 30,
        "color": "#E8F4F8",
        "image": "/images/fabrics/cotton.jpg"
      },
      ...
    ],
    "category": "thobes"
  }
}
```

#### Save Design
```http
POST /api/v1/design/save
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "123",
  "category": "thobes",
  "fabric": "Premium Cotton",
  "customization": {
    "collar": "classic",
    "sleeves": "full",
    "buttons": "standard"
  }
}

Response: 201 Created
{
  "status": "success",
  "message": "Design saved successfully",
  "data": {
    "design": {
      "id": "456",
      "userId": "123",
      "category": "thobes",
      "fabric": "Premium Cotton",
      "customization": {...},
      "createdAt": "2024-11-08T02:00:00.000Z"
    }
  }
}
```

#### Get User Designs
```http
GET /api/v1/design/user/:userId
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "designs": [
      {
        "id": "1",
        "userId": "123",
        "category": "thobes",
        "fabric": "Premium Cotton",
        "customization": {
          "collar": "classic",
          "sleeves": "full"
        },
        "createdAt": "2024-11-08T02:00:00.000Z"
      }
    ]
  }
}
```

### Orders

#### Create Order
```http
POST /api/v1/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "123",
  "designId": "456",
  "measurements": {...},
  "customization": {...},
  "price": 120
}

Response: 201 Created
{
  "status": "success",
  "message": "Order created successfully",
  "data": {
    "order": {
      "id": "12345",
      "userId": "123",
      "designId": "456",
      "status": "pending",
      "price": 120,
      "createdAt": "2024-11-08T02:00:00.000Z",
      "estimatedDelivery": "2024-11-15T02:00:00.000Z"
    }
  }
}
```

#### Get User Orders
```http
GET /api/v1/orders/user/:userId
Authorization: Bearer <token>
Query Parameters:
- status (optional): pending|in_progress|completed

Response: 200 OK
{
  "status": "success",
  "data": {
    "orders": [
      {
        "id": "12345",
        "userId": "123",
        "item": "Navy Blue Thobe",
        "status": "in_progress",
        "price": 120,
        "createdAt": "2024-11-06T02:00:00.000Z",
        "estimatedDelivery": "2024-11-13T02:00:00.000Z"
      }
    ],
    "count": 1
  }
}
```

#### Get Order Details
```http
GET /api/v1/orders/:orderId
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "order": {
      "id": "12345",
      "userId": "123",
      "item": "Navy Blue Thobe",
      "status": "in_progress",
      "price": 120,
      "measurements": {...},
      "customization": {...},
      "createdAt": "2024-11-08T02:00:00.000Z",
      "estimatedDelivery": "2024-11-15T02:00:00.000Z"
    }
  }
}
```

#### Update Order Status
```http
PATCH /api/v1/orders/:orderId/status
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "status": "completed"
}

Response: 200 OK
{
  "status": "success",
  "message": "Order status updated successfully",
  "data": {
    "orderId": "12345",
    "status": "completed",
    "updatedAt": "2024-11-08T02:00:00.000Z"
  }
}
```

## Error Responses

All error responses follow this format:

```json
{
  "status": "error",
  "message": "Error description"
}
```

Common HTTP status codes:
- 400: Bad Request (invalid input)
- 401: Unauthorized (missing/invalid token)
- 404: Not Found (resource doesn't exist)
- 500: Internal Server Error

## Rate Limiting

API is rate-limited to 100 requests per 15 minutes per IP address.

## Health Check

```http
GET /health

Response: 200 OK
{
  "status": "success",
  "message": "Qeyafa API is running",
  "timestamp": "2024-11-08T02:00:00.000Z"
}
```
