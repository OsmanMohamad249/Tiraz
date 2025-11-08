# Tiraz Mobile App

React Native mobile application for the Tiraz AI Tailoring Platform (MVP).

## Features (MVP Scope)

- **AI Measurement**: Upload 4 photos for AI-powered body measurements
- **Design Studio**: Interactive design tool for Men's Thobes and Shirts
- **Virtual Try-On**: 3D visualization of custom garments
- **User Accounts**: Authentication and profile management
- **Order History**: Track current and past orders

## Tech Stack

- React Native 0.73
- React Navigation for routing
- Axios for API communication
- TypeScript for type safety

## Prerequisites

- Node.js >= 18
- React Native CLI
- Xcode (for iOS development)
- Android Studio (for Android development)

## Installation

```bash
# Install dependencies
npm install

# iOS specific (macOS only)
cd ios && pod install && cd ..
```

## Running the App

```bash
# Start Metro bundler
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios
```

## Project Structure

```
src/
├── screens/          # App screens
├── components/       # Reusable components
├── navigation/       # Navigation configuration
├── services/         # API and business logic
├── utils/            # Utility functions
└── assets/           # Images, fonts, etc.
```

## Development

This is the MVP boilerplate. Key screens to implement:

1. **HomeScreen** - Main dashboard
2. **MeasurementScreen** - AI photo upload flow
3. **DesignStudioScreen** - Garment customization
4. **VirtualTryOnScreen** - 3D preview
5. **OrdersScreen** - Order tracking

## API Integration

The app connects to the backend API. Configure the API base URL in `src/services/api.js`:

```javascript
const API_BASE_URL = process.env.API_URL || 'http://localhost:5000';
```

## Testing

```bash
npm test
```

## License

MIT
