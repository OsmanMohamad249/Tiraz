// lib/utils/constants.dart
/// App-wide constants
class Constants {
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleCustomer = 'customer';
  static const String roleDesigner = 'designer';
  static const String roleTailor = 'tailor';
  
  // App Configuration
  static const String appName = 'Qeyafa';
  static const String appVersion = '0.1.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 72;
  
  // Timeouts (in seconds)
  static const int apiTimeout = 30;
  static const int uploadTimeout = 60;
}
