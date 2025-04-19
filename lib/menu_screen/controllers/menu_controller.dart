import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class MenuController extends ChangeNotifier {
  // Menu data
  List<dynamic> _menuItems = [];
  List<dynamic> _foodTypes = [];
  List<dynamic> _categories = [];
  List<String> get selectedFoodTypes => _selectedFoodTypes;
  // Filtered menu items
  List<dynamic> _filteredMenuItems = [];
  //   // Check if menu item has add-ons
// Cache maps to store results and avoid repeated API calls
final Map<String, bool> _addonCache = {};
final Map<String, bool> _sizesCache = {};
final Map<String, bool> _discountsCache = {};
  
  // Loading states
  bool _isLoading = false;
  String _errorMessage = '';
  
  // UI state
  final Map<String, bool> _isExpandedMap = {};
  List<String> _selectedFoodTypes = [];
  String _selectedCategory = '';
  String _searchTerm = '';
  bool _isCategoryModalVisible = false;

  // Getters
  List<dynamic> get menuItems => _filteredMenuItems;
  List<dynamic> get foodTypes => _foodTypes;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isCategoryModalVisible => _isCategoryModalVisible;
  Map<String, bool> get isExpandedMap => _isExpandedMap;

  // Initialize menu data
  Future<void> initializeMenu() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Load food types
      _foodTypes = await ApiService.getFoodTypes();
      
      // Load categories
      _categories = await ApiService.getCategories();
      
      // Load menu items
      await refreshMenuItems();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load menu data: $e';
      notifyListeners();
    }
  }
  
  // Refresh menu items with current filters
  Future<void> refreshMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _menuItems = await ApiService.getMenuItems(
        searchTerm: _searchTerm,
        foodTypes: _selectedFoodTypes,
        category: _selectedCategory,
      );
      
      _filteredMenuItems = List.from(_menuItems);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load menu items: $e';
      notifyListeners();
    }
  }
  
  // Search functionality
  void search(String term) {
    _searchTerm = term;
    _applyFilters();
  }
  
  // Toggle food type filter
  void toggleFoodType(String foodType) {
    if (_selectedFoodTypes.contains(foodType)) {
      _selectedFoodTypes.remove(foodType);
    } else {
      _selectedFoodTypes.add(foodType);
    }
    _applyFilters();
  }
  
  // Set category filter
  void setCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = ''; // Toggle off if already selected
    } else {
      _selectedCategory = category;
    }
    _isCategoryModalVisible = false;
    _applyFilters();
  }
  
  // Clear all filters
  void clearFilters() {
    _selectedFoodTypes = [];
    _selectedCategory = '';
    _searchTerm = '';
    _applyFilters();
  }
  
  // Toggle category modal visibility
  void toggleCategoryModal() {
    _isCategoryModalVisible = !_isCategoryModalVisible;
    notifyListeners();
  }
  
  // Toggle description expansion
  void toggleExpanded(String itemName) {
    _isExpandedMap[itemName] = !(_isExpandedMap[itemName] ?? false);
    notifyListeners();
  }
  
  // Apply all filters to menu items
  void _applyFilters() {
    if (_searchTerm.isEmpty && 
        _selectedFoodTypes.isEmpty && 
        _selectedCategory.isEmpty) {
      _filteredMenuItems = List.from(_menuItems);
    } else {
      _filteredMenuItems = _menuItems.where((item) {
        final name = item['name'].toString().toLowerCase();
        final foodType = item['food_type'].toString().toLowerCase();
        final category = item['category'].toString().toLowerCase();
        
        bool matchesSearch = _searchTerm.isEmpty || 
            name.contains(_searchTerm.toLowerCase());
        
        bool matchesFoodType = _selectedFoodTypes.isEmpty || 
            _selectedFoodTypes.contains(item['food_type']);
            
        bool matchesCategory = _selectedCategory.isEmpty || 
            category == _selectedCategory.toLowerCase();
            
        return matchesSearch && matchesFoodType && matchesCategory;
      }).toList();
    }
    
    notifyListeners();
  }
  
  // Find menu item by name
  dynamic findMenuItem(String name) {
    return _menuItems.firstWhere(
      (item) => item['name'] == name,
      orElse: () => null,
    );
  }
  


// Check if menu item has add-ons
Future<bool> hasAddons(String itemName) async {
  // Return from cache if available
  if (_addonCache.containsKey(itemName)) {
    return _addonCache[itemName]!;
  }
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/addons');
    
    final response = await http.get(
      uri, 
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hasAddon = data != null && data.isNotEmpty;
      _addonCache[itemName] = hasAddon;
      return hasAddon;
    }
    _addonCache[itemName] = false;
    return false;
  } catch (e) {
    print('Error checking addons: $e');
    return false;
  }
}

// Check if menu item has sizes
Future<bool> hasSizes(String itemName) async {
  // Return from cache if available
  if (_sizesCache.containsKey(itemName)) {
    return _sizesCache[itemName]!;
  }
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/sizes');
    
    final response = await http.get(
      uri, 
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hasSizes = data != null && data.isNotEmpty;
      _sizesCache[itemName] = hasSizes;
      return hasSizes;
    }
    _sizesCache[itemName] = false;
    return false;
  } catch (e) {
    print('Error checking sizes: $e');
    return false;
  }
}

// Check if menu item has discounts
Future<bool> hasDiscounts(String itemName) async {
  // Return from cache if available
  if (_discountsCache.containsKey(itemName)) {
    return _discountsCache[itemName]!;
  }
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/discounted_items');
    
    final response = await http.get(
      uri, 
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hasDiscounts = data != null && 
                          data['details'] != null && 
                          data['details'].isNotEmpty;
      _discountsCache[itemName] = hasDiscounts;
      print('Discounts for $itemName: $hasDiscounts');
      return hasDiscounts;
    }
    _discountsCache[itemName] = false;
    return false;
  } catch (e) {
    print('Error checking discounts: $e');
    return false;
  }
}

}