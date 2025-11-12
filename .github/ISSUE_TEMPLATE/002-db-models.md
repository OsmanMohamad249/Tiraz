---
name: 002 - Database Models and Access Layer
about: Create MongoDB database models and access layer
title: '[DB] Create Database Models and Access Layer'
labels: enhancement, database
assignees: ''

---

## Description
Create MongoDB database models and data access layer for the Qeyafa application.

## Objectives
- [ ] Set up MongoDB connection using Motor (async MongoDB driver)
- [ ] Create User model and repository
- [ ] Create Measurement model and repository
- [ ] Create Profile model and repository
- [ ] Implement CRUD operations for each model
- [ ] Add database migrations/seeding scripts

## Database Models

### User Model
- `_id`: ObjectId
- `email`: string (unique, indexed)
- `password_hash`: string
- `name`: string
- `created_at`: datetime
- `updated_at`: datetime
- `is_active`: boolean

### Measurement Model
- `_id`: ObjectId
- `user_id`: ObjectId (reference to User)
- `measurements`: dict (chest, waist, shoulders, etc.)
- `height`: float
- `weight`: float
- `unit`: string (cm, inch)
- `image_paths`: list of strings
- `processed_at`: datetime
- `ai_confidence`: float (optional)
- `source`: string (ai_service, manual, mock)

### Profile Model
- `_id`: ObjectId
- `user_id`: ObjectId (reference to User, unique)
- `date_of_birth`: datetime
- `gender`: string
- `preferences`: dict (preferred_unit, etc.)
- `created_at`: datetime
- `updated_at`: datetime

## Technical Requirements
- Use Motor for async MongoDB operations
- Create repository pattern for data access
- Implement connection pooling
- Add proper error handling
- Create indexes for frequently queried fields
- Implement database configuration from environment variables

## API Endpoints to Update
- Update measurement endpoints to persist data
- Add measurement history endpoint: `GET /api/v1/measurements/history/{userId}`
- Add profile endpoints: `GET/PUT /api/v1/profile/{userId}`

## Environment Variables
```
MONGODB_URL=mongodb://localhost:27017
DATABASE_NAME=qeyafa_db
```

## Acceptance Criteria
- [ ] MongoDB connection is established successfully
- [ ] All models are properly defined with validation
- [ ] CRUD operations work for all models
- [ ] Data is properly indexed for performance
- [ ] Error handling for database operations
- [ ] Unit tests for repository methods
- [ ] Integration tests with test database

## Dependencies
- motor (already in requirements.txt)
- pymongo
- pydantic

## References
- Motor Documentation: https://motor.readthedocs.io/
- FastAPI with MongoDB: https://www.mongodb.com/languages/python/pymongo-tutorial
