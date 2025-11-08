# Development Workflow

This guide covers the development workflow for the Tiraz MVP application.

## Getting Started

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Tiraz.git
   cd Tiraz
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Set Up Development Environment**
   ```bash
   # Start backend services
   docker-compose up -d
   
   # Install mobile app dependencies
   cd mobile-app && npm install
   ```

## Development Process

### Backend Development

1. **Make Changes**
   - Edit files in `backend/src/`
   - Changes auto-reload with nodemon

2. **Test Locally**
   ```bash
   cd backend
   npm test
   
   # Manual testing
   curl http://localhost:5000/health
   ```

3. **Code Style**
   ```bash
   npm run lint
   ```

### AI Models Development

1. **Activate Virtual Environment**
   ```bash
   cd ai-models
   source venv/bin/activate
   ```

2. **Make Changes**
   - Edit files in `measurement_model/`
   - Restart service to see changes

3. **Test**
   ```bash
   pytest tests/
   ```

### Mobile App Development

1. **Start Metro Bundler**
   ```bash
   cd mobile-app
   npm start
   ```

2. **Run on Device/Emulator**
   ```bash
   # iOS
   npm run ios
   
   # Android
   npm run android
   ```

3. **Make Changes**
   - Edit files in `src/`
   - Changes hot-reload automatically

4. **Test**
   ```bash
   npm test
   ```

## Project Structure

### Backend
```
backend/
├── src/
│   ├── routes/        # API route definitions
│   ├── controllers/   # Business logic (TODO)
│   ├── models/        # Database models (TODO)
│   ├── middleware/    # Custom middleware (TODO)
│   ├── utils/         # Helper functions (TODO)
│   └── server.js      # Entry point
├── tests/             # Unit tests (TODO)
├── package.json       # Dependencies
└── Dockerfile         # Docker configuration
```

### Mobile App
```
mobile-app/
├── src/
│   ├── screens/       # Screen components
│   ├── components/    # Reusable components (TODO)
│   ├── navigation/    # Navigation setup
│   ├── services/      # API calls
│   ├── utils/         # Helper functions (TODO)
│   └── App.js         # Root component
├── android/           # Android native code
├── ios/               # iOS native code
└── package.json       # Dependencies
```

### AI Models
```
ai-models/
├── measurement_model/
│   ├── api.py         # Flask API
│   ├── model.py       # ML model
│   └── preprocessing.py (TODO)
├── tests/             # Unit tests (TODO)
└── requirements.txt   # Python dependencies
```

## Coding Standards

### JavaScript/React Native

- Use ES6+ syntax
- Use functional components with hooks
- Follow ESLint configuration
- Use meaningful variable names
- Add comments for complex logic

```javascript
// Good
const getUserMeasurements = async (userId) => {
  try {
    const response = await api.get(`/measurements/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching measurements:', error);
    throw error;
  }
};

// Bad
const gum = (u) => api.get(`/m/${u}`).then(r => r.data);
```

### Python

- Follow PEP 8 style guide
- Use type hints where appropriate
- Add docstrings to functions
- Use meaningful variable names

```python
# Good
def calculate_measurement(height: float, weight: float, body_part: str) -> float:
    """
    Calculate body measurement based on height and weight.
    
    Args:
        height: Height in centimeters
        weight: Weight in kilograms
        body_part: Type of measurement (chest, waist, etc.)
    
    Returns:
        Calculated measurement in centimeters
    """
    bmi = weight / ((height / 100) ** 2)
    return base_measurements[body_part] * (0.85 + 0.15 * (bmi / 22.0))

# Bad
def cm(h, w, b):
    return bm[b] * (0.85 + 0.15 * (w/((h/100)**2)/22))
```

## Testing

### Backend Tests

```bash
cd backend
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

### AI Model Tests

```bash
cd ai-models
pytest tests/

# With coverage
pytest --cov=measurement_model tests/
```

### Mobile App Tests

```bash
cd mobile-app
npm test

# Watch mode
npm test -- --watch
```

## Git Workflow

### Branch Naming

- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent fixes
- `docs/` - Documentation changes

Examples:
- `feature/add-payment-integration`
- `bugfix/fix-measurement-api`
- `docs/update-setup-guide`

### Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:
```
feat(backend): add user authentication endpoint

Implement JWT-based authentication with login and register endpoints.
Includes password hashing with bcrypt.

Closes #123

fix(mobile): resolve measurement screen crash

Fixed null pointer exception when photos array is empty.
Added proper null checks.

Fixes #456
```

### Pull Request Process

1. **Create PR**
   - Use descriptive title
   - Fill out PR template
   - Link related issues

2. **Code Review**
   - Address reviewer comments
   - Keep PR focused and small
   - Update documentation if needed

3. **Merge**
   - Squash commits if needed
   - Delete branch after merge

## Environment Variables

### Backend (.env)
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/tiraz
JWT_SECRET=change-in-production
AI_SERVICE_URL=http://localhost:8000
```

### AI Service
```env
PORT=8000
DEBUG=True
```

### Mobile App
```javascript
// src/config.js
export const API_BASE_URL = __DEV__ 
  ? 'http://localhost:5000/api/v1'
  : 'https://api.tiraz.com/api/v1';
```

## Debugging

### Backend
```bash
# Enable debug logging
DEBUG=* node src/server.js

# Use Node debugger
node --inspect src/server.js
```

### Mobile App
```bash
# Enable React Native debugger
# Shake device or Cmd+D (iOS) / Cmd+M (Android)
# Select "Debug"

# View console logs
npx react-native log-ios
npx react-native log-android
```

### AI Service
```python
# Enable Flask debug mode
export DEBUG=True
python measurement_model/api.py
```

## Common Issues

### Backend

**Issue**: Port already in use
```bash
# Solution
lsof -ti:5000 | xargs kill
```

**Issue**: MongoDB connection failed
```bash
# Solution
docker-compose ps  # Check if MongoDB is running
docker-compose restart mongodb
```

### Mobile App

**Issue**: Metro bundler cache issues
```bash
# Solution
npm start -- --reset-cache
```

**Issue**: Native modules not found
```bash
# Solution
cd ios && pod install && cd ..
npm run ios
```

## Performance Tips

1. **Backend**
   - Use database indexes
   - Implement caching (Redis)
   - Optimize queries
   - Use pagination

2. **Mobile App**
   - Optimize images
   - Use FlatList for long lists
   - Implement lazy loading
   - Minimize re-renders

3. **AI Service**
   - Cache model in memory
   - Use batch processing
   - Optimize image preprocessing
   - Consider GPU acceleration

## Resources

- [Express.js Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [Flask Best Practices](https://flask.palletsprojects.com/en/2.3.x/patterns/)
- [MongoDB Best Practices](https://docs.mongodb.com/manual/administration/production-notes/)

## Getting Help

1. Check existing documentation
2. Search GitHub issues
3. Ask in team chat
4. Create new issue with:
   - Problem description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details

---

Happy coding! 🚀
