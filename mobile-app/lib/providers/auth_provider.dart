// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

// Auth service provider
final authServiceProvider = Provider((ref) => AuthService());

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

// Auth state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? error;
  
  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  
  AuthStateNotifier(this.authService) : super(AuthState());
  
  // Check authentication status
  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await authService.isLoggedIn();
    
    if (isLoggedIn) {
      final result = await authService.getCurrentUser();
      if (result['success']) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: User.fromJson(result['data']),
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await authService.login(
      email: email,
      password: password,
    );
    
    if (result['success']) {
      // Fetch user info
      final userResult = await authService.getCurrentUser();
      if (userResult['success']) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: User.fromJson(userResult['data']),
        );
        return true;
      }
    }
    
    state = state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      error: result['error'],
    );
    return false;
  }
  
  // Register
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    
    state = state.copyWith(isLoading: false);
    
    if (result['success']) {
      return true;
    } else {
      state = state.copyWith(error: result['error']);
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await authService.logout();
    state = AuthState();
  }
}
