import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu_screen/models/get_item_info.dart';

class StorageService {
  /// Saves a map to SharedPreferences
  static Future<void> saveMap<T>(String key, Map<String, T> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(map));
  }

  /// Retrieves a map from SharedPreferences
  static Future<Map<String, dynamic>> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(key);
    if (value == null || value.isEmpty) return {};
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding $key: $e');
      return {};
    }
  }

  // Add this method to StorageService
static Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Clear specific keys used by the app
  await prefs.remove('item_quantities');
  await prefs.remove('item_customizations');
  await prefs.remove('order_groups');
  await prefs.remove('promotional_items');
    await prefs.remove('itemFoodTypes');
  await prefs.remove('itemFoodCategories');
  await prefs.remove('itemPrices');
  
  print('All local storage data cleared');
}
  
  /// Saves item quantities to persistent storage
  static Future<void> saveItemQuantities(Map<String, int> quantities) async {
    await saveMap('itemQuantities', quantities);
  }
  
  /// Retrieves item quantities from persistent storage
  static Future<Map<String, int>> getItemQuantities() async {
    final map = await getMap('itemQuantities');
    // Convert from dynamic to int
    return map.map((key, value) => MapEntry(key, int.parse(value.toString())));
  }
  
  /// Saves item customizations to persistent storage
  static Future<void> saveItemCustomizations(Map<String, String> customizations) async {
    await saveMap('itemCustomizations', customizations);
  }
  
  /// Retrieves item customizations from persistent storage
  static Future<Map<String, String>> getItemCustomizations() async {
    final map = await getMap('itemCustomizations');
    return map.map((key, value) => MapEntry(key, value.toString()));
  }
  
  /// Saves the full order group structure
  static Future<void> saveOrderGroups(Map<String, List<Map<String, dynamic>>> groups) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the complex structure to JSON string
    final jsonString = jsonEncode(groups);
    await prefs.setString('itemOrderGroups', jsonString);
  }
  
  /// Retrieves the full order group structure
  static Future<Map<String, List<Map<String, dynamic>>>> getOrderGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('itemOrderGroups');
    
    if (jsonString == null || jsonString.isEmpty) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      // Convert the dynamic map to the expected type
      return decoded.map((key, value) {
        final List<Map<String, dynamic>> typedList = (value as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        return MapEntry(key, typedList);
      });
    } catch (e) {
      print('Error retrieving order groups: $e');
      return {};
    }
  }
  
  /// Saves promotional item information/// Saves promotional item information
static Future<void> saveGetItemInfo(Map<String, GetItemInfo> getItemInfoMap) async {
  final prefs = await SharedPreferences.getInstance();
  
  try {
    // Convert GetItemInfo objects to JSON
    final Map<String, dynamic> jsonMap = {};
    getItemInfoMap.forEach((key, info) {
      jsonMap[key] = info.toJson();
    });
    
    // Create the JSON string
    final jsonString = jsonEncode(jsonMap);
    print('Saving getItemInfoMap with ${jsonMap.length} entries (${jsonString.length} characters, $jsonString)');
    
    await prefs.setString('getItemInfoMap', jsonString);
  } catch (e) {
    print('Error saving getItemInfoMap: $e');
  }
}

/// Add these methods after the getItemCustomizations method (around line 60)

/// Saves item food types to persistent storage
static Future<void> saveItemFoodTypes(Map<String, String> foodTypes) async {
  await saveMap('itemFoodTypes', foodTypes);
}

/// Retrieves item food types from persistent storage
static Future<Map<String, String>> getItemFoodTypes() async {
  final map = await getMap('itemFoodTypes');
  return map.map((key, value) => MapEntry(key, value.toString()));
}

/// Saves item food categories to persistent storage
static Future<void> saveItemFoodCategories(Map<String, String> categories) async {
  await saveMap('itemFoodCategories', categories);
}

/// Retrieves item food categories from persistent storage
static Future<Map<String, String>> getItemFoodCategories() async {
  final map = await getMap('itemFoodCategories');
  return map.map((key, value) => MapEntry(key, value.toString()));
}

/// Saves item prices to persistent storage
static Future<void> saveItemPrices(Map<String, double> prices) async {
  final prefs = await SharedPreferences.getInstance();
  // Convert to a map of strings for storage
  final stringMap = prices.map((key, value) => MapEntry(key, value.toString()));
  await prefs.setString('itemPrices', jsonEncode(stringMap));
}

/// Retrieves item prices from persistent storage
static Future<Map<String, double>> getItemPrices() async {
  final map = await getMap('itemPrices');
  // Convert from strings to doubles
  return map.map((key, value) => MapEntry(key, double.parse(value.toString())));
}

/// Retrieves promotional item information
static Future<Map<String, GetItemInfo>> getGetItemInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonString = prefs.getString('getItemInfoMap');
  
  print('Retrieved from storage: ${jsonString?.length ?? 0} characters');
  
  if (jsonString == null || jsonString.isEmpty) return {};
  
  try {
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    print('Decoded ${decoded.length} items from storage');
    
    // Convert JSON back to GetItemInfo objects
    final Map<String, GetItemInfo> result = {};
    decoded.forEach((key, value) {
      try {
        result[key] = GetItemInfo.fromMap(value);
        print('Loaded item: $key');
      } catch (e) {
        print('Error creating GetItemInfo for $key: $e');
      }
    });
    
    return result;
  } catch (e) {
    print('Error retrieving getItemInfoMap: $e');
    return {};
  }
}

  /// Clears all user session data
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_type');
    await prefs.remove('role');
    await prefs.remove('permissions');
  }
  
  /// Clears all cart/order data
  static Future<void> clearCartData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('itemQuantities');
    await prefs.remove('itemCustomizations');
    await prefs.remove('itemOrderGroups');
    await prefs.remove('getItemInfoMap');
    await prefs.remove('itemFoodTypes');
  await prefs.remove('itemFoodCategories');
  await prefs.remove('itemPrices');
  }
  
  /// Checks if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }
}