// lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'api_service.dart';

class CategoryService extends ApiService {
  /// Get all categories
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/categories'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final categories = (data as List)
            .map((item) => Category.fromJson(item))
            .toList();
        
        return {
          'success': true,
          'categories': categories,
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
  
  /// Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/categories/$categoryId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'category': Category.fromJson(data),
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
