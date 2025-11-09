// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class UserService extends ApiService {
  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/users/me'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'error': handleError(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final body = <String, dynamic>{};
      
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (email != null) body['email'] = email;
      
      final response = await http.put(
        Uri.parse('${ApiService.apiBaseUrl}/users/me'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'error': handleError(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Get user by ID (admin only)
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/users/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'error': handleError(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// List all users (admin only)
  Future<Map<String, dynamic>> listUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/users?page=$page&per_page=$perPage'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['items'] as List)
            .map((item) => User.fromJson(item))
            .toList();
        
        return {
          'success': true,
          'users': users,
          'total': data['total'],
        };
      } else {
        return {
          'success': false,
          'error': handleError(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
