import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class ApiService {
  /// Gets the stored access token
  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  /// Fetches all food types from the API
  static Future<List<dynamic>> getFoodTypes() async {
    final accessToken = await getAccessToken();
    final uri = Uri.parse('${Config.baseUrl}/menu/food_types');
    
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load food types: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error when fetching food types: $e');
      return [];
    }
  }

  /// Fetches all menu categories from the API
  static Future<List<dynamic>> getCategories() async {
    final accessToken = await getAccessToken();
    final uri = Uri.parse('${Config.baseUrl}/menu/categories');
    
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error when fetching categories: $e');
      return [];
    }
  }

  /// Fetches menu items with optional filtering
  static Future<List<dynamic>> getMenuItems({
    String searchTerm = '',
    List<String> foodTypes = const [],
    String category = '',
  }) async {
    final accessToken = await getAccessToken();
    
    // Build query parameters
    final queryParams = <String, String>{};
    if (searchTerm.isNotEmpty) {
      queryParams['search'] = searchTerm;
    }
    if (foodTypes.isNotEmpty) {
      queryParams['food_types'] = foodTypes.join(',');
    }
    if (category.isNotEmpty) {
      queryParams['category'] = category;
    }
    
    final uri = Uri.parse('${Config.baseUrl}/menu/sort/menu/filter/sear').replace(
      queryParameters: queryParams,
    );
    
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load menu items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error when fetching menu items: $e');
      return [];
    }
  }

  /// Fetches add-ons for a specific menu item
  static Future<List<dynamic>> getAddons(String itemName) async {
    try {
      final accessToken = await getAccessToken();
      
      // Debug output for URL construction
      print("Building URL for add-ons: ${Config.baseUrl}/discount/item/$itemName/addons");
      
      final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/addons');
      
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("Add-ons response received: ${result.length} items");
        return result;
      } else {
        print('Failed to load add-ons: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching add-ons: $e');
      return [];
    }
  }

  // /// Fetches sizes for a specific menu item
  // static Future<List<dynamic>> getSizes(String itemName) async {
  //   try {
  //     final accessToken = await getAccessToken();
  //     final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/sizes');
      
  //     final response = await http.get(
  //       uri,
  //       headers: {'Authorization': 'Bearer $accessToken'},
  //     );
      
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print('Failed to load sizes: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching sizes: $e');
  //     return [];
  //   }
  // }

  /// Fetches discounted items for a specific menu item (for buy-one-get-one promotions)
  static Future<Map<String, dynamic>> getDiscountedItems(String itemName) async {
    try {
      final accessToken = await getAccessToken();
      final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/discounted_items');
      
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load discounted items: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching discounted items: $e');
      return {};
    }
  }

  /// Authenticates user and stores access token
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('${Config.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Store the access token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseData['access_token']);
        
        return responseData;
      } else {
        print('Login failed: ${response.statusCode}');
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error during login: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Submits a new order to the API
  static Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> orderData) async {
    final accessToken = await getAccessToken();
    
    final token = accessToken;
      final queryParams = {
    'token': token,
  };
  final uri = Uri.parse('${Config.baseUrl}/ordersystem/place_order').replace(queryParameters: queryParams);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Order submission failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Order submission failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error during order submission: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetches active orders
  static Future<List<dynamic>> getActiveOrders() async {
    final accessToken = await getAccessToken();
    final uri = Uri.parse('${Config.baseUrl}/order/active');
    
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load active orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error when fetching active orders: $e');
      return [];
    }
  }

  /// Updates order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    final accessToken = await getAccessToken();
    final uri = Uri.parse('${Config.baseUrl}/order/$orderId/status');
    
    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Network error when updating order status: $e');
      return false;
    }
  }
  
  /// Logs out user and clears token
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('access_token');
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}