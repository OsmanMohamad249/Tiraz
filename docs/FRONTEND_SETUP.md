# Frontend Infrastructure Setup - Complete

## Overview
This document provides a comprehensive guide to the frontend infrastructure for Qeyafa, which consists of two main applications:
1. **Flutter Mobile App** - For customers and designers
2. **Next.js Admin Portal** - For administrators and management

## Project Structure
```
Qeyafa/
├── backend/                # FastAPI backend (Python)
├── mobile-app/            # Flutter mobile app (Dart)
├── admin-portal/          # Next.js admin portal (TypeScript)
└── docs/                  # Documentation
```

## 1. Flutter Mobile App 📱

### Location
`/mobile-app/`

### Tech Stack
- Flutter SDK (>=2.19.0 <3.0.0)
- Dart
- State Management: Riverpod
- Secure Storage: flutter_secure_storage
- HTTP Client: http package

### Key Features
✅ User authentication (login/register)
✅ JWT token management with secure storage
✅ Design browsing and viewing
✅ User profile management
✅ Role-based UI (customer/designer/admin/tailor)
✅ API service layer for backend integration
✅ Reusable UI components

### Getting Started
```bash
cd mobile-app
flutter pub get
flutter run
```

### API Configuration
Update the base URL in:
- `lib/services/api_service.dart`
- `lib/utils/app_config.dart`

Default: `http://10.0.2.2:8000` (Android emulator)

For detailed documentation, see: [mobile-app/README.md](./mobile-app/README.md)

---

## 2. Next.js Admin Portal 🌐

### Location
`/admin-portal/`

### Tech Stack
- Next.js 14 (App Router)
- TypeScript 5
- Tailwind CSS 3
- State Management: Zustand
- HTTP Client: Axios

### Key Features
✅ Admin authentication with JWT
✅ Role-based access control (admin only)
✅ Admin dashboard
✅ API service layer with interceptors
✅ TypeScript type definitions
✅ Zustand state management
✅ Responsive UI with Tailwind CSS

### Getting Started
```bash
cd admin-portal
npm install
cp .env.example .env.local
npm run dev
```

Access at: http://localhost:3000

### Environment Variables
Create `.env.local`:
```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

For detailed documentation, see: [admin-portal/README.md](./admin-portal/README.md)

---

## Backend Integration

Both frontends connect to the FastAPI backend running on `http://localhost:8000`.

### API Endpoints
- **Base URL**: `http://localhost:8000/api/v1`
- **Authentication**: JWT Bearer tokens
- **Available Endpoints**:
  - `/auth/login` - User login
  - `/auth/register` - User registration
  - `/users/me` - Get current user
  - `/users/{id}` - User operations
  - `/designs` - Design CRUD operations
  - `/categories` - Category operations

### Authentication Flow
1. User logs in with email/password
2. Backend validates and returns JWT token
3. Token stored securely (flutter_secure_storage or localStorage)
4. Token attached to all subsequent API requests
5. Token validated by backend for protected routes

---

## Shared Data Models

### User Model
```typescript
interface User {
  id: string;
  email: string;
  first_name?: string;
  last_name?: string;
  is_active: boolean;
  role: 'customer' | 'designer' | 'admin' | 'tailor';
  created_at: string;
}
```

### Design Model
```typescript
interface Design {
  id: string;
  title: string;
  description: string;
  style_type: string;
  price: number;
  image_url: string;
  designer_id: string;
  category_id: string;
  created_at: string;
}
```

### Category Model
```typescript
interface Category {
  id: string;
  name: string;
  description: string;
  image_url?: string;
  created_at: string;
}
```

---

## Development Workflow

### Running All Services

1. **Start Backend** (Terminal 1):
```bash
cd backend
docker-compose up
# or
python main.py
```

2. **Start Flutter App** (Terminal 2):
```bash
cd mobile-app
flutter run
```

3. **Start Admin Portal** (Terminal 3):
```bash
cd admin-portal
npm run dev
```

### Service URLs
- Backend API: http://localhost:8000
- Admin Portal: http://localhost:3000
- Flutter App: Runs on connected device/emulator

---

## Testing

### Flutter Mobile App
```bash
cd mobile-app
flutter test
```

### Next.js Admin Portal
```bash
cd admin-portal
npm run lint
npm run build
```

### Backend API
```bash
cd backend
pytest
```

---

## Security Considerations

### Mobile App
- JWT tokens stored in `flutter_secure_storage`
- Automatic token injection in API requests
- Secure HTTPS connections in production

### Admin Portal
- JWT tokens in localStorage (consider httpOnly cookies for production)
- Role verification (admin only)
- CSRF protection for sensitive operations
- HTTPS required in production

### Backend
- JWT token authentication
- Role-based access control (RBAC)
- Password hashing with bcrypt
- Rate limiting on sensitive endpoints

---

## Deployment

### Mobile App
- **Android**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`

### Admin Portal
- **Vercel**: `vercel deploy`
- **Docker**: Dockerfile included
- **Static Export**: `npm run build && npm run export`

### Backend
- **Docker**: `docker-compose up -d`
- **Production**: Configure environment variables for production

---

## Troubleshooting

### Common Issues

**Mobile App:**
- Connection refused: Check backend URL and ensure backend is running
- Build errors: Run `flutter clean && flutter pub get`
- Token expired: Implement token refresh mechanism

**Admin Portal:**
- API errors: Verify `NEXT_PUBLIC_API_BASE_URL` in `.env.local`
- Build failures: Clear `.next` cache
- CORS errors: Configure CORS in FastAPI backend

**Backend:**
- Database connection: Check PostgreSQL is running
- Migration errors: Run `alembic upgrade head`
- Authentication errors: Verify JWT secret configuration

---

## Next Steps

### Mobile App Enhancements
- [ ] Implement design detail view
- [ ] Add design creation/editing for designers
- [ ] Implement admin screens in mobile app
- [ ] Add measurement capture with camera
- [ ] Implement order management
- [ ] Add push notifications

### Admin Portal Enhancements
- [ ] User management dashboard
- [ ] Design approval/moderation interface
- [ ] Analytics and reporting
- [ ] Category management CRUD
- [ ] System settings and configuration
- [ ] Audit logs and activity tracking

### Backend Enhancements
- [ ] Complete Design Studio API
- [ ] Implement order management
- [ ] Add payment integration
- [ ] File upload for designs
- [ ] Real-time notifications
- [ ] Admin dashboard APIs

---

## Contributing

1. Create a feature branch from `main`
2. Make your changes in the appropriate directory
3. Test your changes locally
4. Create a pull request with clear description
5. Ensure all CI checks pass

---

## Support

For questions or issues:
- Check the README in each subdirectory
- Review the backend API documentation
- Check existing issues in the repository
- Contact the development team

---

## License
MIT License

---

**Last Updated**: 2025-11-09
**Version**: 0.1.0
