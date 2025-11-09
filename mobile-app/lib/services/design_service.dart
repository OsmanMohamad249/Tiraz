// lib/services/design_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/design.dart';
import 'api_service.dart';

class DesignService extends ApiService {
  /// Get all designs
  Future<Map<String, dynamic>> getDesigns({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/designs?page=$page&per_page=$perPage'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final designs = (data['items'] as List)
            .map((item) => Design.fromJson(item))
            .toList();
        
        return {
          'success': true,
          'designs': designs,
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
  
  /// Get design by ID
  Future<Map<String, dynamic>> getDesignById(String designId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.apiBaseUrl}/designs/$designId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'design': Design.fromJson(data),
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
  
  /// Create new design
  Future<Map<String, dynamic>> createDesign({
    required String title,
    required String description,
    required String styleType,
    required double price,
    required String imageUrl,
    required String categoryId,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.apiBaseUrl}/designs'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'style_type': styleType,
          'price': price,
          'image_url': imageUrl,
          'category_id': categoryId,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'design': Design.fromJson(data),
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
  
  /// Update design
  Future<Map<String, dynamic>> updateDesign({
    required String designId,
    String? title,
    String? description,
    String? styleType,
    double? price,
    String? imageUrl,
    String? categoryId,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final body = <String, dynamic>{};
      
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (styleType != null) body['style_type'] = styleType;
      if (price != null) body['price'] = price;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (categoryId != null) body['category_id'] = categoryId;
      
      final response = await http.put(
        Uri.parse('${ApiService.apiBaseUrl}/designs/$designId'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'design': Design.fromJson(data),
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
  
  /// Delete design
  Future<Map<String, dynamic>> deleteDesign(String designId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiService.apiBaseUrl}/designs/$designId'),
        headers: headers,
      );
      
      if (response.statusCode == 204) {
        return {
          'success': true,
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
