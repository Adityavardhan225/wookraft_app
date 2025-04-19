import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'order_details_screen.dart';
import 'config.dart';



class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  MenuScreenState createState() => MenuScreenState();
}

// import 'package:flutter/material.dart';

class GetItemsSection extends StatelessWidget {
  final List<dynamic> discountedItems;
  final String buyItemName;
  final int baseQuantity;
  final Map<String, GetItemInfo> getItemInfoMap;
  final Map<String, int> itemQuantities;
  final Function(String, int) onGetItemQuantityChanged;
  final Map<String, List<Map<String, dynamic>>> itemOrderGroups;
  final StateSetter setModalState;
  final int Function(String, int, List<dynamic>, String) calculateMaxGetItems;
  final String Function(String, int, String, List<dynamic>)
      getBuyXGetYAtZMessage;

  const GetItemsSection({
    Key? key,
    required this.discountedItems,
    required this.buyItemName,
    required this.baseQuantity,
    required this.getItemInfoMap,
    required this.itemQuantities,
    required this.onGetItemQuantityChanged,
    required this.itemOrderGroups,
    required this.setModalState,
    required this.calculateMaxGetItems,
    required this.getBuyXGetYAtZMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('9997773334 $discountedItems');
    // Get items that have quantities
    final getItemGroups = itemOrderGroups.entries
        // .where((entry) => (getItemInfoMap[entry.key]?.currentQuantity ?? 0) > 0)
        .where((entry) {
          final compositeKey = '${buyItemName}_${entry.key}';
          return (getItemInfoMap[compositeKey]?.currentQuantity ?? 0) > 0;
        })
        .expand(
            (entry) => entry.value.where((group) => group['isGetItem'] == true))
        .toList();

    print('999777333 $discountedItems');
    print('discountedItems.isNotEmpty ${discountedItems.isNotEmpty}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promotional Items Section
        if (getItemGroups.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text("Promotional Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...getItemGroups.map((group) => _buildPromotionalItem(group)),
        ],

        // Get Items Selection Section
        if (discountedItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text("Get Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Explicit ListView instead of spread operator
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discountedItems.length,
            itemBuilder: (context, index) {
              final detail = discountedItems[index];
              print('DEBUG: Building card for item: ${detail}');
              return _buildGetItemCard(detail);
            },
          ),
        ],
      ],
    );
  }

  String _getGetItemMessage(
      String itemName, Map<String, GetItemInfo> getItemInfoMap) {
    final compositeKey = nameToCompositeKeyMap[itemName];
    if (compositeKey == null) return '';

    final info = getItemInfoMap[compositeKey];
    if (info == null || info.currentQuantity == 0) return '';

    return 'You have purchased ${info.currentQuantity} quantity at ₹${info.discountedPrice} as you have selected ${info.buyItemName}';
  }

  // Helper methods for building cards
  Widget _buildPromotionalItem(Map<String, dynamic> group) {
    final getItemName = group['itemName'] as String;
    final info = getItemInfoMap[getItemName];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getItemName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text("Promotional Item"),
            const SizedBox(height: 4),
            Text(
              _getGetItemMessage(getItemName, getItemInfoMap),
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text("Quantity: ${info?.currentQuantity ?? 0}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }




Widget _buildGetItemCard(Map<String, dynamic> detail) {
  final getItemName = detail['name'];
  final compositeKey = '${buyItemName}_$getItemName';
  final info = getItemInfoMap[compositeKey];

  // Extract details
  final originalPrice = detail['price'] ?? 0.0;
  final discountedPrice = detail['discounted_price'] ?? originalPrice;
  final description = detail['description'] ?? '';
  final foodType = detail['food_type'] ?? '';

  if (info == null) return const SizedBox.shrink();

  final maxGetItems = calculateMaxGetItems(
      buyItemName, baseQuantity, discountedItems, getItemName);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Promotional Message when quantity > 0
      if (info.currentQuantity > 0)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Selected as Get Item',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You will get ${info.currentQuantity} ${getItemName} at ₹${discountedPrice} each with your ${buyItemName} purchase',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

      // Main Item Card
      Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name
              Text(
                getItemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Price and Food Type Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (discountedPrice < originalPrice) ...[
                        Text(
                          '₹$originalPrice',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$discountedPrice',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ] else
                        Text(
                          'Price: ₹$originalPrice',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                  if (foodType.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        foodType,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),

              // Description
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

             
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildQuantityControls(getItemName, info, maxGetItems),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  

  Widget _buildQuantityControls(
      String getItemName, GetItemInfo info, int maxGetItems) {
    print('999777666 $discountedItems');
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: info.currentQuantity > 0
              ? () =>
                  _handleQuantityChange(getItemName, info.currentQuantity - 1)
              : null,
        ),
        Text("${info.currentQuantity}", style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: Icon(Icons.add,
              color: info.currentQuantity < maxGetItems
                  ? Colors.blue
                  : Colors.grey),
          onPressed: info.currentQuantity < maxGetItems
              ? () =>
                  _handleQuantityChange(getItemName, info.currentQuantity + 1)
              : null,
        ),
      ],
    );
  }


  void _handleQuantityChange(String getItemName, int newQuantity) {
    setModalState(() {
      // Create composite key for current item
      final currentCompositeKey = '${buyItemName}_$getItemName';
      print('kkkkkk $currentCompositeKey');
      // Reset other get items first
      getItemInfoMap.forEach((compositeKey, info) {
        print('debug 00222 $compositeKey');
        print('debug 002223 $info.buyItemName, $buyItemName');
        if (info.buyItemName == buyItemName && compositeKey != currentCompositeKey) {
          info.currentQuantity = 0;
          itemQuantities[compositeKey] = 0;
          
          // Remove from order groups
          if (itemOrderGroups.containsKey(info.name)) {
            itemOrderGroups[info.name]!.removeWhere((g) => g['isGetItem'] == true);
          }
        }
      });

      // Update current get item
      onGetItemQuantityChanged(getItemName, newQuantity);
    });
  }
}


class GetItemInfo {
  final String name;
  final int buyQuantity;
  final int getQuantity;
  final String foodType;
  final double originalPrice;
  final double discountedPrice;
  final String description;
  final String? imageUrl;
  final String buyItemName;
  int currentQuantity;
  String get compositeKey => '${buyItemName}_$name';
  int menuQuantity=0;
  // Added field

  GetItemInfo({
    required this.name,
    required this.buyQuantity,
    required this.getQuantity,
    required this.foodType,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
    this.imageUrl,
    required this.buyItemName,
    this.currentQuantity = 0,
  });

  @override
  String toString() {
    return 'GetItemInfo(compositeKey: $compositeKey,name: $name, buyItemName: $buyItemName, buyQty: $buyQuantity, getQty: $getQuantity, currentQuantity: $currentQuantity)';
  }
}

Map<String, String> nameToCompositeKeyMap = {};
void _initializeGetItemInfo(List<dynamic> details, String itemName) {
  print('DEBUG1: Initializing GetItemInfo');
  print('DEBUG1: buyItemName=$itemName');
  print('DEBUG1: details=$details');

  for (var detail in details) {
    final name = detail['name'];
    final compositeKey = '${itemName}_$name';
    final buyQuantity = detail['buy_item_quantity'] as int? ?? 0;
    final getQuantity = detail['get_item_quantity'] as int? ?? 0;
    final foodType = detail['food_type'];
    final originalPrice = (detail['price'] as num).toDouble();
    final discountedPrice = (detail['discounted_price'] as num).toDouble();
    final description = detail['description'];
    final imageUrl = detail['image_url'];

    print('DEBUG: Processing compositeKey=$compositeKey');

    // Check if we have existing info for this composite key
    final existingInfo = getItemInfoMap[compositeKey];
    final currentQuantity = existingInfo?.currentQuantity ?? 0;

    print(
        'DEBUG: Existing info found=${existingInfo != null}, currentQuantity=$currentQuantity');

    // Create new GetItemInfo with either existing or new quantity
    getItemInfoMap[compositeKey] = GetItemInfo(
      name: name,
      buyQuantity: buyQuantity,
      getQuantity: getQuantity,
      foodType: foodType,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      description: description,
      imageUrl: imageUrl,
      buyItemName: itemName,
      currentQuantity: currentQuantity,
    );
    nameToCompositeKeyMap[name] = compositeKey;
  }

  print('DEBUG: Final getItemInfoMap:');
  getItemInfoMap.forEach((key, info) => print(
      '$key -> buyItem: ${info.buyItemName}, buyQty: ${info.buyQuantity}, getQty: ${info.getQuantity}, currentQty: ${info.currentQuantity}'));
}

Map<String, GetItemInfo> getItemInfoMap = {};

class MenuScreenState extends State<MenuScreen> {
  final GlobalKey<NavigatorState> menuScreenNavigatorKey = GlobalKey<NavigatorState>();
  final _searchController = TextEditingController();
  List<dynamic> menuItems = [];
  List<dynamic> foodTypes = [];
  List<dynamic> categories = [];
  // For items without addons; normal orders stored here.
  Map<String, int> itemQuantities = {};
  // For items with addons/customizations, each variant stored as a group.
  Map<String, List<Map<String, dynamic>>> itemOrderGroups = {};
  // Customizations entered manually.
  Map<String, String> itemCustomizations = {};
  Map<String, String> itemFoodTypes = {};
  Map<String, String> itemFoodCategories = {};
  Map<String, bool> isExpandedMap = {};
  Map<String, double> itemPrices = {};

  bool _isLoading = false;
  String _errorMessage = '';
  Set<String> selectedFoodTypes = {};
  String selectedCategory = '';
  bool _isCategoryModalVisible = false;
  Timer? _debounce;
  int _debugCount = 0;

  int _calculateMaxGetItems(String buyItemName, int currentQuantity,
      List<dynamic> details, String getItemName) {
    final compositeKey = '${buyItemName}_$getItemName';
    final detail = details.firstWhere((detail) => detail['name'] == getItemName,
        orElse: () => {'buy_quantity': 0, 'get_quantity': 0});

    final buyQuantity = detail['buy_item_quantity'] as int? ?? 0;
    final getQuantity = detail['get_item_quantity'] as int? ?? 0;

    if (buyQuantity == 0) return 0;

    final sets = (currentQuantity / buyQuantity).floor();
    return sets * getQuantity;
  }

  void _updateGetItemQuantity(
      String getItemName, String buyItemName, int quantity) {
    final compositeKey = '${buyItemName}_$getItemName';
    final info = getItemInfoMap[compositeKey];
    if (info == null) return;

    setState(() {
      info.currentQuantity = quantity;
      itemQuantities[compositeKey] = quantity;
    });
  }




  // Add helper method to check if item is a get item
bool _isGetItem(String itemName) {
  return getItemInfoMap.values.any((info) => 
    info.name == itemName && info.currentQuantity > 0);
}

  int _calculateMaxGetItemsforupdate(
      String buyItemName, int baseQuantity, int buyQty, int getQty) {
    print('DEBUG: Calculating max get items');

    if (buyQty == 0) return 0;

    // Calculate sets and max allowed quantity
    final sets = (baseQuantity / buyQty).floor();
    final maxAllowed = sets * getQty;

    print('DEBUG: sets=$sets, maxAllowed=$maxAllowed');
    return maxAllowed;
  }

  String _getGetItemMessage(
      String itemName, Map<String, GetItemInfo> getItemInfoMap) {
    // Find the info where this item is the 'name'
    final compositeKey = nameToCompositeKeyMap[itemName];
    if (compositeKey == null) return '';

    final info = getItemInfoMap[compositeKey];
    if (info == null || info.currentQuantity == 0) return '';

    return 'You have purchased ${info.currentQuantity} quantity at ₹${info.discountedPrice} as you have selected ${info.buyItemName}';
  }











void _updateGetItemInfo(String itemName, int baseQuantity) {
  print('DEBUG: Starting update for $itemName with quantity $baseQuantity');

  // First update the base item quantity
  if (menuItems.any((item) => item['name'] == itemName)) {
    itemQuantities[itemName] = baseQuantity;
    print('DEBUG: Updated base item $itemName quantity to $baseQuantity');
  }

  // Then handle get items
  final relevantGetItems = getItemInfoMap.entries
      .where((entry) => entry.value.buyItemName == itemName)
      .toList();
      
  print('DEBUG: Found ${relevantGetItems.length} get items for $itemName');

  for (var entry in relevantGetItems) {
    final compositeKey = entry.key;
    final info = entry.value;
    
    final maxGetItems = _calculateMaxGetItemsforupdate(
      itemName, 
      baseQuantity,
      info.buyQuantity,
      info.getQuantity
    );

    if (maxGetItems < info.currentQuantity) {
      final sets = (baseQuantity / info.buyQuantity).floor();
      final result = sets * info.getQuantity;
      
      info.currentQuantity = result;
      itemQuantities[compositeKey] = result;
      print('DEBUG: Updated get item ${info.name} quantity to $result');
    }
  }
  print('99999999999999999999999999999');
  _saveQuantities();
  setState(() {});
}

  void _updateAddonItem(String itemName, int quantity,
      Map<String, bool> addonSelections, List<dynamic> addons,
      [bool shouldNavigate = false]) {
    // Calculate addon totals
    double computedAddonsTotal = 0.0;
    for (var addon in addons) {
      final addonName = addon['addon_item_name'];
      if (addonSelections[addonName] ?? false) {
        computedAddonsTotal += (addon['addon_price'] as num).toDouble();
      }
    }

    setState(() {
      // Update quantities
      itemQuantities[itemName] = quantity;

      // Update or create order group
      itemOrderGroups.putIfAbsent(itemName, () => []);
      var existingGroup = itemOrderGroups[itemName]!
          .where((g) => !g.containsKey('isGetItem'))
          .toList();

      if (existingGroup.isEmpty) {
        itemOrderGroups[itemName]!.add({
          'quantity': quantity,
          'addonSelections': Map<String, bool>.from(addonSelections),
          'customization': itemCustomizations[itemName] ?? '',
          'addonsTotal': computedAddonsTotal,
        });
      } else {
        existingGroup.first['quantity'] = quantity;
        existingGroup.first['addonSelections'] =
            Map<String, bool>.from(addonSelections);
        existingGroup.first['customization'] =
            itemCustomizations[itemName] ?? '';
        existingGroup.first['addonsTotal'] = computedAddonsTotal;
      }
    });

    if (shouldNavigate) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveQuantities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('itemQuantities', jsonEncode(itemQuantities));
  }

  @override
  void initState() {
    super.initState();
    _getMenuItems();
    _getFoodTypes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _getMenuItems();
    });
  }

  Future<void> _getMenuItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final search = _searchController.text;

      final queryParameters = {
        if (search.isNotEmpty) 'search': search,
        if (selectedCategory.isNotEmpty) 'category': selectedCategory,
        if (selectedFoodTypes.isNotEmpty)
          'food_types': selectedFoodTypes.join(','),
      };

      final uri = Uri.parse('${Config.baseUrl}/menu/sort/menu/filter/sear')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          menuItems = data.map((item) {
            return {
              ...item,
              'price': (item['price'] as num).toDouble(),
              'discounted_price': item['discounted_price'] != null
                  ? (item['discounted_price'] as num).toDouble()
                  : null,
              'discount_rules': item['discount_rules'] != null &&
                      item['discount_rules'] is List &&
                      item['discount_rules'].isNotEmpty
                  ? item['discount_rules'][0]
                  : null,
            };
          }).toList();

          for (var item in menuItems) {
            final String itemName = item['name'];
            itemFoodTypes[itemName] = item['food_type'];
            itemFoodCategories[itemName] = item['category'];
            itemPrices[itemName] = item['price'];
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load menu items: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getFoodTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final uri = Uri.parse('${Config.baseUrl}/menu/food_types');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          foodTypes = jsonDecode(response.body);
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load food types';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final uri = Uri.parse('${Config.baseUrl}/menu/categories');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          categories = jsonDecode(response.body);
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load categories';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _filterByFoodType(String foodType) {
    setState(() {
      if (selectedFoodTypes.contains(foodType)) {
        selectedFoodTypes.remove(foodType);
      } else {
        selectedFoodTypes.add(foodType);
      }
    });
    _getMenuItems();
  }

  void _toggleCategoryModal() {
    setState(() {
      _isCategoryModalVisible = !_isCategoryModalVisible;
    });
    if (_isCategoryModalVisible) {
      _getCategories();
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = selectedCategory == category ? '' : category;
      _isCategoryModalVisible = false;
    });
    _getMenuItems();
  }





int _getTotalQuantity(String itemName) {
  int total = 0;
  print('debug 00000 $itemName');
  
  // Case 1: Item as a base/buy item - get from order groups
  if (itemOrderGroups.containsKey(itemName) && itemOrderGroups[itemName] != null) {
    print('debug 002 $itemName');
    print('debug 0005 ${itemOrderGroups[itemName]}');
    
    for (var group in itemOrderGroups[itemName]!) {
      // Only count groups that have the isGetItem key present
      if (group != null && group.containsKey('isGetItem')) {
        print('debug 001 $itemName, $group');
        
        // Safely access quantity with null check
        if (group.containsKey('quantity') && group['quantity'] != null) {
          try {
            int qty = group['quantity'] as int;
            print('debug 005 $qty, $total');
            total += qty;
            print('debug 002 $total');
          } catch (e) {
            print('Error converting quantity to int: $e');
            // If casting fails, try to handle it gracefully
            var rawQty = group['quantity'];
            if (rawQty is double) {
              total += rawQty.toInt();
            } else if (rawQty is String) {
              total += int.tryParse(rawQty) ?? 0;
            }
          }
        }
      }
    }
  }
  
  print('debug 0022 $itemName, $total');
  return total;
}
  Widget _buildPromotionalItem(Map<String, dynamic> group) {
    final getItemName = group['itemName'] as String;
    final info = getItemInfoMap[getItemName];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getItemName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text("Promotional Item"),
            const SizedBox(height: 4),
            Text(
              _getGetItemMessage(getItemName, getItemInfoMap),
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text("Quantity: ${info?.currentQuantity ?? 0}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAndUpdateGetItems(String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final uri =
        Uri.parse('${Config.baseUrl}/discount/item/$itemName/discounted_items');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final discountedItems = jsonData['details'] ?? [];

      // Initialize get items
      _initializeGetItemInfo(discountedItems, itemName);

      // Update quantities based on current base quantity
      _updateGetItemInfo(itemName, itemQuantities[itemName] ?? 0);

      // Debug print
      print('Updated getItemInfoMap: $getItemInfoMap');

      setState(() {}); // Trigger rebuild
    }
  }

  void _incrementQuantity(String itemName) {
    print('item namr 1234564567890 $itemName');
    setState(() {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + 1;
      print('checking buy_x_get_y 134 $itemName, $itemQuantities[itemName]');

      // Update get item quantities
      _updateGetItemInfo(itemName, itemQuantities[itemName]!);
      _fetchAndUpdateGetItems(itemName);
    });
  }

// Update _decrementQuantity to handle get item updates
  void _decrementQuantity(String itemName) async {
    if ((itemQuantities[itemName] ?? 0) > 0) {
      final currentQty = itemQuantities[itemName]!;
      final newQuantity = currentQty - 1;
      print(999991012);

      setState(() {
        itemQuantities[itemName] = newQuantity;

        // Update get items whenever buy item quantity changes
        _updateGetItemInfo(itemName, newQuantity);

        if (newQuantity == 0) {
          itemOrderGroups.remove(itemName);
          itemCustomizations.remove(itemName);
        }
      });
    }
  }

// Add this method to sync quantities
  void _syncQuantities(String itemName) {
    final baseQty = itemQuantities[itemName] ?? 0;
    _updateGetItemInfo(itemName, baseQty);
  }











Widget _buildPromotionalMessages(String itemName) {
  List<Widget> messages = [];

  getItemInfoMap.forEach((compositeKey, info) {
    if (info.name == itemName && info.currentQuantity > 0) {
      final buyItem = menuItems.firstWhere(
        (item) => item['name'] == info.buyItemName,
        orElse: () => {},
      );
      final bool hasAddons = buyItem['has_addons'] ?? false;

      messages.add(
        SizedBox(
          width: 160,
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.all(4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_offer,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Get Item',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                info.buyItemName,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                print('Debug: Edit button pressed for ${info.buyItemName}');
                                try {
                                  Navigator.of(context).pop();
                                  print('Debug: Successfully closed current modal');

                                  await showItemModal(
                                    context,
                                    info.buyItemName,
                                    hasAddons: hasAddons,
                                    hasDiscounts: true,
                                  );
                                  print('Debug: Opened new modal for ${info.buyItemName}');
                                } catch (e) {
                                  print('Debug: Navigation error - $e');
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Divider(height: 1, color: Colors.blue),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${info.currentQuantity}',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${info.discountedPrice} each',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PROMO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  });

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(children: messages),
  );
}


// 1. Modify the _handleQuantityClick method to determine which modal to show
void _handleQuantityClick(
    BuildContext context, 
    String itemName, 
    bool hasAddons,
    bool hasDiscounts
) {
  // Check if this item already has customizations
  final hasExistingCustomizations = 
    itemOrderGroups.containsKey(itemName) && 
    (itemOrderGroups[itemName]?.isNotEmpty ?? false);
    
  // Determine which modal to show based on existing customizations
  if (hasExistingCustomizations) {
    // Item already has customizations - show management modal
    _showCustomizationManagementModal(context, itemName, hasAddons, hasDiscounts);
  } else {
    // First-time customization - show standard modal
    showItemModal(context, itemName, hasAddons: hasAddons, hasDiscounts: hasDiscounts);
  }
}

// 2. Create a new customization management modal for subsequent interactions



Future<void> _showCustomizationManagementModal(
    BuildContext context, 
    String itemName,
    bool hasAddons,
    bool hasDiscounts
) async {
  // Get the item details
  final item = menuItems.firstWhere(
    (elem) => elem['name'] == itemName,
    orElse: () => {},
  );
  
  // Check if item has sizes
  final bool hasSizes = item['sizes'] != null && (item['sizes'] as List).isNotEmpty;
  
  // Store indices of valid groups to maintain correct references
  List<int> validGroupIndices = [];
  List<Map<String, dynamic>> validGroups = [];
  
  if (itemOrderGroups.containsKey(itemName)) {
    for (int i = 0; i < itemOrderGroups[itemName]!.length; i++) {
      final g = itemOrderGroups[itemName]![i];
      
      // Skip get items
      if (g['isGetItem'] == true) continue;
      print('debug 999772890 ${g['selectedAddons']}');
      if (g['selectedAddons']== null) continue;
     if (g['selectedAddons'] is Map && (g['selectedAddons'] as Map).isEmpty) continue;
    
      // Check for selected add-ons
      final addonSelections = g['addonSelections'] as Map<String, bool>?;
      final hasSelectedAddons = addonSelections != null && 
          addonSelections.entries.any((e) => e.value == true);
      
      // Check for customization text
      final hasCustomizationText = g['customization']?.isNotEmpty == true;
      
      // Check for size selection
      final hasSize = g['selectedSize']?.isNotEmpty == true && g['has_size'] == true;
      
      if (hasSelectedAddons || hasCustomizationText || hasSize || !hasAddons) {
        validGroups.add(g);
        print('debug 9997728903 ${g['selectedAddons']} , jhukj$g,kjhk $i');
        validGroupIndices.add(i);
      }
    }
  }
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Manage $itemName Customizations',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Promotional messages if applicable
                if (getItemInfoMap.entries.any((e) => e.value.name == itemName)) ...[
                  _buildPromotionalMessages(itemName),
                  const SizedBox(height: 16),
                ],
                
                // Current customizations
                if (validGroups.isNotEmpty) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Customizations:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        // Scrollable list of customizations
                        Expanded(
                          child: ListView.builder(
                            itemCount: validGroups.length,
                            itemBuilder: (context, index) {
                              // Use original index for correct referencing
                              final originalIndex = validGroupIndices[index];
                              print('debug 99977289 ${validGroups[index]} , kkkk ${itemOrderGroups[itemName]}');
                              return _buildRegularItemCard(
                                index,
                                validGroups[index],
                                itemName,
                                setModalState,
                                itemOrderGroups[itemName]!,
                                originalIndex,  // Pass original index for correct updating
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else const Expanded(
                  child: Center(
                    child: Text('No customizations found'),
                  ),
                ),
                
                // Buttons at the bottom
                Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total item count display
                        Text(
                          'Total Quantity: ${_getTotalQuantity(itemName)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // Add new customization button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showItemModal(context, itemName, hasAddons: hasAddons, hasDiscounts: hasDiscounts);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add New'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Make sure your _buildRegularItemCard function looks like this:
Widget _buildRegularItemCard(
    int displayIndex,
    Map<String, dynamic> group,
    String itemName,
    StateSetter setModalState,
    List<Map<String, dynamic>> groups,
    [int? originalIndex]
) {
  final addons = group['addonSelections'] as Map<String, bool>;
  final selectedAddons =
      addons.entries.where((e) => e.value).map((e) => e.key).join(', ');
  
  // Get size information if available
  final bool hasSize = group['has_size'] ?? false;
  final String size = hasSize ? (group['selectedSize'] ?? '') : '';
  final double sizeIncrement = hasSize ? (group['sizePriceIncrement'] ?? 0.0) : 0.0;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order ${displayIndex + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          
          // Display size if available
          if (hasSize && size.isNotEmpty) 
            Text(
              "Size: $size" + (sizeIncrement > 0 ? " (+₹${sizeIncrement.toStringAsFixed(2)})" : ""),
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          
          // Display customization note if available
          if (group['customization']?.isNotEmpty ?? false)
            Text("Note: ${group['customization']}"),
          
          // Display add-ons if available
          if (selectedAddons.isNotEmpty) 
            Text("Add-ons: $selectedAddons"),
          
          const SizedBox(height: 8),
          
          // Quantity controls and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final qty = group['quantity'] as int;
                      if (qty > 1) {
                        setModalState(() {
                          group['quantity'] = qty - 1;
                        });
                      } else {
                        setModalState(() {
                          // Use original index if provided
                          if (originalIndex != null) {
                            itemOrderGroups[itemName]!.removeAt(originalIndex);
                          } else {
                            groups.removeAt(displayIndex);
                          }
                        });
                      }
                      setState(() {
                        // Update total quantity
                        int totalQty = 0;
                        itemOrderGroups[itemName]?.forEach((g) {
                          if (!(g['isGetItem'] ?? false)) {
                            totalQty += g['quantity'] as int;
                          }
                        });
                        itemQuantities[itemName] = totalQty;
                      });
                    },
                  ),
                  Text(
                    "${group['quantity']}",
                    style: const TextStyle(fontSize: 16)
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setModalState(() {
                        group['quantity'] = (group['quantity'] as int) + 1;
                      });
                      setState(() {
                        // No need to update groups - the direct reference to group is updated
                        
                        // Update total quantity
                        int totalQty = 0;
                        itemOrderGroups[itemName]?.forEach((g) {
                          if (!(g['isGetItem'] ?? false)) {
                            totalQty += g['quantity'] as int;
                          }
                        });
                        itemQuantities[itemName] = totalQty;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editCustomization(itemName, originalIndex ?? displayIndex, group);
                },
                child: const Text("Edit"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


Future<void> showItemModal(BuildContext context, String itemName, {bool hasAddons = false, bool hasDiscounts = false}) async {
  // 1. Get total quantity including get items
  final totalQuantity = _getTotalQuantity(itemName);
  Map<String, int> currentGetItemQuantities = {};

  // Store current get item quantities
  getItemInfoMap.forEach((compositeKey, info) {
    if (info.buyItemName == itemName) {
      currentGetItemQuantities[compositeKey] = info.currentQuantity;
    }
  });

  // 2. Get data
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  List<dynamic> addons = [];
  List<dynamic> discountedItems = [];
  
  // Get the item from menuItems
  final item = menuItems.firstWhere(
    (elem) => elem['name'] == itemName,
    orElse: () => {},
  );
  
  // Check if item has sizes
  final bool hasSizes = item['sizes'] != null && (item['sizes'] as List).isNotEmpty;
  String selectedSize = '';
  double sizePriceIncrement = 0.0;
  
  // Initialize selected size to default
  if (hasSizes) {
    final sizes = item['sizes'] as List;
    // Find the default size
    final defaultSize = sizes.firstWhere(
      (size) => size['is_default'] == true,
      orElse: () => sizes.first,
    );
    selectedSize = defaultSize['name'];
    sizePriceIncrement = (defaultSize['price_increment'] as num).toDouble();
  }

  if (hasAddons) {
    final addonUri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/addons');
    final addonResponse = await http.get(
      addonUri, 
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    if (addonResponse.statusCode == 200) {
      addons = jsonDecode(addonResponse.body);
    }
  }

  if (hasDiscounts) {
    final discountUri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/discounted_items');
    final discountResponse = await http.get(
      discountUri,
      headers: {'Authorization': 'Bearer $accessToken'}
    );
    if (discountResponse.statusCode == 200) {
      final jsonData = jsonDecode(discountResponse.body);
      discountedItems = jsonData['details'] ?? [];
      _initializeGetItemInfo(discountedItems, itemName);
      
      // Restore quantities
      currentGetItemQuantities.forEach((compositeKey, quantity) {
        final info = getItemInfoMap[compositeKey];
        if (info != null) {
          info.currentQuantity = quantity; 
        }
      });
    }
  }

  // Calculate existing quantity
  int existingTotalQuantity = 0;
  if (itemOrderGroups.containsKey(itemName)) {
    itemOrderGroups[itemName]!.forEach((group) {
      if (!(group['isGetItem'] ?? false)) {
        existingTotalQuantity += (group['quantity'] as int);
      }
    });
  }
  
  // Handle simple items without customization
  if (addons.isEmpty && discountedItems.isEmpty && !hasSizes) {
    _incrementQuantity(itemName);
    return;
  }

  // 3. Initialize state - Find existing customization to update
  int baseQuantity = _getTotalQuantity(itemName);
  // Make sure it's at least 1 to avoid zero-quantity issues
  baseQuantity = baseQuantity > 0 ? baseQuantity : 1;
  
  // int addonQuantity = (hasAddons || hasSizes) ? 0 : baseQuantity;
  int addonQuantity=0;
  Map<String, bool> localAddonSelections = {};
  Map<String, int> tempGetItemQuantities = Map.from(currentGetItemQuantities);
  String customizationText = '';
  
  // Initialize addon selections (all false)
  for (var addon in addons) {
    final addonName = addon['addon_item_name'];
    if (addonName != null) {
      localAddonSelections[addonName] = false;
    }
  }
  
  // Find the MOST RECENT non-get item group to update (using LIFO approach)
  int existingGroupIndex = -1;
  if (itemOrderGroups.containsKey(itemName)) {
    // Loop from the end of the list (most recent) to the beginning
    for (int i = itemOrderGroups[itemName]!.length - 1; i >= 0; i--) {
      final group = itemOrderGroups[itemName]![i];
      if (group['isGetItem'] == true) continue;
      
      // Found the most recently added non-get item group to update
      existingGroupIndex = i;
      
      // Pre-fill with existing customization details
      if (group['addonSelections'] != null) {
        try {
          final addonSelectionsMap = group['addonSelections'] as Map<dynamic, dynamic>;
          addonSelectionsMap.forEach((key, value) {
            if (key != null) {
              localAddonSelections[key.toString()] = value == true;
            }
          });
        } catch (e) {
          print('Error processing addon selections: $e');
        }
      }
      
      if (group['customization'] != null) {
        customizationText = group['customization'].toString();
      }
      
      if (hasSizes && group['selectedSize'] != null) {
        selectedSize = group['selectedSize'];
        sizePriceIncrement = (group['sizePriceIncrement'] as num?)?.toDouble() ?? 0.0;
      }
      
      // if (group['quantity'] != null) {
      //   try {
      //     addonQuantity = group['quantity'] as int;
      //     // baseQuantity = addonQuantity;
      //   } catch (e) {
      //     print('Error getting quantity: $e');
      //   }
      // }
     
      
      break;  // Just use the most recent one we find
    }
  }

  TextEditingController customizationController = TextEditingController(text: customizationText);

  // Custom updateQuantities function that updates both item quantities and customizations
  void _updateQuantitiesWithGetItems(String itemName, int menuQuantity, StateSetter setModalState, int addonQuantity) {
    // Update menu quantity
    itemQuantities[itemName] = menuQuantity;
    
    // Only prepare customization data for items with add-ons or sizes
    if (hasAddons || hasSizes) {
      // Calculate add-on totals and gather details
      double computedAddonsTotal = 0.0;
      Map<String, Map<String, dynamic>> selectedAddonsDetails = {};
      
      for (var addon in addons) {
        final addonName = addon['addon_item_name'];
        if (addonName != null && (localAddonSelections[addonName] == true)) {
          computedAddonsTotal += (addon['addon_price'] as num).toDouble();
          
          // Store selected add-on details
          selectedAddonsDetails[addonName] = {
            'name': addonName,
            'price': addon['addon_price'],
            'description': addon['addon_description'] ?? '',
          };
        }
      }
      
      // Get size price increment
      double sizePriceIncrement = 0.0;
      if (hasSizes) {
        final sizes = item['sizes'] as List;
        final selectedSizeObj = sizes.firstWhere(
          (size) => size['name'] == selectedSize,
          orElse: () => {'price_increment': 0},
        );
        sizePriceIncrement = (selectedSizeObj['price_increment'] as num).toDouble();
      }
      
      // Calculate total price for one unit
      final basePrice = (item['discounted_price'] ?? item['price']) as num;
      final totalItemPrice = basePrice + computedAddonsTotal + sizePriceIncrement;
      
      // Prepare the customization data
      Map<String, dynamic> customizationData = {
        'quantity': addonQuantity,
        'addonSelections': Map<String, bool>.from(localAddonSelections),
        'customization': customizationController.text,
        'addonsTotal': computedAddonsTotal,
        'selectedAddons': selectedAddonsDetails,
        'isGetItem': false,
        'has_size': hasSizes,
        'totalUnitPrice': totalItemPrice,
        'selectedSize': hasSizes ? selectedSize : '',
        'sizePriceIncrement': hasSizes ? sizePriceIncrement : 0.0,
      };
      
      // Ensure itemOrderGroups has an entry for this item
      if (!itemOrderGroups.containsKey(itemName)) {
        itemOrderGroups[itemName] = [];
      }
      
      // LIFO: Find the most recent non-get item group to update
      int groupIndex = existingGroupIndex;
      
      // If we didn't find one earlier, check again using LIFO approach
      if (groupIndex == -1) {
        print('debug erro for group');
        for (int i = itemOrderGroups[itemName]!.length - 1; i >= 0; i--) {
          if (!(itemOrderGroups[itemName]![i]['isGetItem'] ?? false)) {
            groupIndex = i;
            print('debug erro for group $groupIndex');
            break;
          }
        }
      }
      
      if (groupIndex >= 0 && groupIndex < itemOrderGroups[itemName]!.length) {
        // Update existing group
        itemOrderGroups[itemName]![groupIndex] = customizationData;
        print('debug erro for group 122 $groupIndex');
        
      } else if (addonQuantity > 0) {
        // Only add a new entry if none exists and quantity > 0
        print('debug erro for group 123 $groupIndex');
        itemOrderGroups[itemName]!.add(customizationData);
        // Update our index reference for future updates
        existingGroupIndex = itemOrderGroups[itemName]!.length - 1;
          print('Debug: Added new customization data for $itemName, quantity: $addonQuantity');
      }
       
    }
        
    // Calculate and update get items based on menu quantity
    if (hasDiscounts || hasAddons || hasSizes) {
      _updateGetItemInfo(itemName, menuQuantity);
      _updateOrderGroup(itemName, addonQuantity, menuQuantity);
    }

      setState(() {
    itemQuantities[itemName] = menuQuantity;
  });
  }

  // 4. Show modal
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          // Calculate prices
          final basePrice = (item['discounted_price'] ?? item['price']) as num;
          
          double addonsTotal = 0.0;
          double sizeIncrement = 0.0;
          
          // Calculate add-on price total
          for (var addon in addons) {
            final addonName = addon['addon_item_name'];
            if (addonName != null && (localAddonSelections[addonName] == true)) {
              addonsTotal += (addon['addon_price'] as num).toDouble();
            }
          }
          
          // Calculate size price increment
          if (hasSizes) {
            final sizes = item['sizes'] as List;
            final selectedSizeObj = sizes.firstWhere(
              (size) => size['name'] == selectedSize,
              orElse: () => {'price_increment': 0},
            );
            sizeIncrement = (selectedSizeObj['price_increment'] as num).toDouble();
          }
          
          // Calculate total price per unit
          final totalPrice = basePrice + addonsTotal + sizeIncrement;

          // Build modal UI
          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header text
                Text(
                  existingGroupIndex >= 0
                    ? 'Update $itemName'
                    : hasAddons && hasDiscounts 
                      ? 'Add New Customization for $itemName'
                      : hasAddons 
                        ? 'Add $itemName with Add-ons'
                        : 'Add $itemName',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Promotional messages (if applicable)
                if (getItemInfoMap.entries.any((e) => e.value.buyItemName == itemName)) ...[
                  _buildPromotionalMessages(itemName),
                  const SizedBox(height: 16),
                ],
                
                // Customization note field
                if (hasAddons) ...[
                  const Text('Customization:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: customizationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter special instructions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                  
                const SizedBox(height: 12),
                
                // Size selection
                if (hasSizes) ...[
                  const Text(
                    'Select Size:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (item['sizes'] as List).map<Widget>((size) {
                      final sizeName = size['name'];
                      final priceIncrement = size['price_increment'] as num;
                      final isSelected = selectedSize == sizeName;
                      
                      return ChoiceChip(
                        label: Text(
                          priceIncrement > 0 
                            ? '$sizeName (+₹$priceIncrement)'
                            : sizeName
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            setModalState(() {
                              selectedSize = sizeName;
                            });
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Quantity selector
                Row(
                  children: [
                    const Text('Quantity: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: baseQuantity > 1
                        ? () {
                            setModalState(() {
                              baseQuantity--;
                              addonQuantity--;
                              // Update quantities which will modify the first item in the group
                              _updateQuantitiesWithGetItems(itemName, baseQuantity, setModalState, addonQuantity);
                            });
                                    setState(() {
          itemQuantities[itemName] = baseQuantity;
        });
                          }
                        : null,
                    ),
                    // Container(
                    //   width: 40,
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     '$baseQuantity', 
                    //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    //   ),
                    // ),
                    Container(
  width: 40,
  alignment: Alignment.center,
  child: Text(
    '${(hasAddons || hasSizes)  ? addonQuantity : baseQuantity}',  // Show different quantity based on presence of add-ons
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
  ),
),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setModalState(() {
                          baseQuantity++;
                          addonQuantity++;
                          // Update quantities which will modify the first item in the group
                          _updateQuantitiesWithGetItems(itemName, baseQuantity, setModalState, addonQuantity);
                        });
                                setState(() {
          itemQuantities[itemName] = baseQuantity;
        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                
                // Price display
                if (hasAddons || hasSizes)
                  Text(
                    'Price (1 unit): ₹${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                
                const SizedBox(height: 12),
                
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add-ons section
                        if (hasAddons) ...[
                          const Text('Add-ons:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: addons.length,
                            itemBuilder: (context, index) {
                              final addon = addons[index];
                              final addonName = addon['addon_item_name'];
                              final addonPrice = addon['addon_price'];
                              final addonDescription = addon['addon_description'];
                              return CheckboxListTile(
                                title: Text(
                                  '$addonName (₹$addonPrice)',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: addonDescription != null
                                  ? Text(addonDescription, style: const TextStyle(fontSize: 12))
                                  : null,
                                value: localAddonSelections[addonName] ?? false,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (addonName != null) {
                                      localAddonSelections[addonName] = value ?? false;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                          const Divider(),
                        ],

                        // Get items section
                        if (hasDiscounts)
                          GetItemsSection(
                            discountedItems: discountedItems,
                            buyItemName: itemName,
                            baseQuantity: baseQuantity,
                            getItemInfoMap: getItemInfoMap,
                            itemQuantities: itemQuantities,
                            onGetItemQuantityChanged: (getItemName, quantity) {
                              final compositeKey = '${itemName}_$getItemName';
                              tempGetItemQuantities[compositeKey] = quantity;
                              
                              getItemInfoMap.forEach((key, info) {
                                if (key != compositeKey && info.buyItemName == itemName) {
                                  info.currentQuantity = 0;
                                  tempGetItemQuantities[key] = 0;
                                }
                              });
                              
                              _updateGetItemQuantity(getItemName, itemName, quantity);
                            },
                            itemOrderGroups: itemOrderGroups,
                            setModalState: setModalState,
                            calculateMaxGetItems: _calculateMaxGetItems,
                            getBuyXGetYAtZMessage: _getBuyXGetYAtZMessage,
                          ),
                      ],
                    ),
                  ),
                ),

                // Add to order button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        // Handle items with add-ons or sizes
                        if (hasAddons || hasSizes) {
                          // Calculate add-on total price
                          double computedAddonsTotal = 0.0;
                          Map<String, Map<String, dynamic>> selectedAddonsDetails = {};
                          
                          for (var addon in addons) {
                            final addonName = addon['addon_item_name'];
                            if (addonName != null && (localAddonSelections[addonName] == true)) {
                              computedAddonsTotal += (addon['addon_price'] as num).toDouble();
                              
                              // Store selected add-on details
                              selectedAddonsDetails[addonName] = {
                                'name': addonName,
                                'price': addon['addon_price'],
                                'description': addon['addon_description'] ?? '',
                              };
                            }
                          }
                          
                          // Calculate size price increment
                          double sizePriceIncrement = 0.0;
                          if (hasSizes) {
                            final sizes = item['sizes'] as List;
                            final selectedSizeObj = sizes.firstWhere(
                              (size) => size['name'] == selectedSize,
                              orElse: () => {'price_increment': 0},
                            );
                            sizePriceIncrement = (selectedSizeObj['price_increment'] as num).toDouble();
                          }
                          
                          // Ensure item has an entry in itemOrderGroups
                          if (!itemOrderGroups.containsKey(itemName)) {
                            itemOrderGroups[itemName] = [];
                          }
                          
                          // Prepare the complete customization data
                          Map<String, dynamic> customizationData = {
                            'quantity': addonQuantity,
                            'addonSelections': Map<String, bool>.from(localAddonSelections),
                            'customization': customizationController.text,
                            'addonsTotal': computedAddonsTotal,
                            'selectedAddons': selectedAddonsDetails,
                            'isGetItem': false,
                            'has_size': hasSizes,
                            'selectedSize': hasSizes ? selectedSize : '',
                            'sizePriceIncrement': hasSizes ? sizePriceIncrement : 0.0,
                          };
                          
                          // Find the most recent non-get item group to update using LIFO
                          int groupIndex = existingGroupIndex;
                          
                          if (groupIndex == -1) {
                            for (int i = itemOrderGroups[itemName]!.length - 1; i >= 0; i--) {
                              if (!(itemOrderGroups[itemName]![i]['isGetItem'] ?? false)) {
                                groupIndex = i;
                                break;
                              }
                            }
                          }
                          
                          if (groupIndex >= 0 && groupIndex < itemOrderGroups[itemName]!.length) {
                            // Update the existing group with the complete data
                            itemOrderGroups[itemName]![groupIndex] = customizationData;
                          } else {
                            // Add a new group only if none exists
                            itemOrderGroups[itemName]!.add(customizationData);
                          }
                        }

                        // Handle discounted items
                        if (hasDiscounts) {
                          if (!itemOrderGroups.containsKey(itemName)) {
                            itemOrderGroups[itemName] = [];
                          }

                          // Check if there's already a base entry for this item
                          var baseGroups = itemOrderGroups[itemName]!
                              .where((g) => !(g['isGetItem'] ?? false))
                              .toList();

                          // Only add a base group if none exists AND there are no customizations
                          if (baseGroups.isEmpty && !(hasAddons || hasSizes)) {
                            itemOrderGroups[itemName]!.add({
                              'quantity': addonQuantity,
                              'addonSelections': <String, bool>{},
                              'customization': '',
                              'selectedSize': selectedSize,
                              'sizePriceIncrement': hasSizes ? sizeIncrement : 0.0,
                              'has_size': hasSizes,
                              'isGetItem': false,
                            });
                          }

                          // Update get-item quantities
                          tempGetItemQuantities.forEach((compositeKey, quantity) {
                            itemQuantities[compositeKey] = quantity;
                            final info = getItemInfoMap[compositeKey];
                            if (info != null) {
                              info.currentQuantity = quantity;
                            }
                          });
                        }

                        // Calculate and update the total quantity for this item
                        try {
                          int totalQty = 0;

                          itemQuantities[itemName] = baseQuantity;
                        } catch (e) {
                          print('Error in quantity calculation: $e');
                          // Fallback value
                          // itemQuantities[itemName] = addonQuantity > 0 ? addonQuantity : 1;
                          
                          print('debug 9997789 Using fallback quantity: ${itemQuantities[itemName]}');
                        }
                      });
                      
                      // Close the modal
                      Navigator.pop(context);
                    },
                    child: Text(
                      existingGroupIndex >= 0 ? 'Update Order' : 'Add to Order',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}





void _handleAddItem(BuildContext context, dynamic item) {
  final Map<String, dynamic> itemData = Map<String, dynamic>.from(item as Map);
  final String itemName = itemData['name'];
  final hasAddons = itemData.containsKey('addon') && itemData['addon'] != null;
  final bool hasSizes = itemData['sizes'] != null && (itemData['sizes'] as List).isNotEmpty;

  final bool hasDiscounts = itemData['discount_rules'] != null &&
        (itemData['discount_rules']['type'] == 'percentage' ||
            itemData['discount_rules']['type'] == 'value' ||
            itemData['discount_rules']['type'] == 'buy_x_get_y');
  
  // Check if this item already has customizations
  final hasExistingCustomizations = 
    itemOrderGroups.containsKey(itemName) && 
    (itemOrderGroups[itemName]?.isNotEmpty ?? false);

   final bool needsCustomizationManagement = hasAddons || hasSizes;
  
  if (hasAddons || hasDiscounts || hasSizes) {
    // Item requires customization
    if (hasExistingCustomizations && needsCustomizationManagement) {
      // Item already has customizations - show management modal
      _showCustomizationManagementModal(context, itemName, hasAddons, hasDiscounts);
    } else {
      // First-time customization - show standard modal
      showItemModal(
        context,
        itemName, 
        hasAddons: hasAddons,
        hasDiscounts: hasDiscounts
      );
    }
  } else {
    // Simple item without customization options
    _incrementQuantity(itemName);
  }
}



 

void _updateOrderGroup(String itemName, int quantity, int menuQuantity) {
  if (!itemOrderGroups.containsKey(itemName)) {
    itemOrderGroups[itemName] = [];
  }
  print('debug999778234 ee ${itemOrderGroups[itemName]}');
  print('debug99977823 $quantity, kk$menuQuantity');
  // Find existing non-get item groups
  var baseGroup = itemOrderGroups[itemName]!
      .where((g) => !g.containsKey('isGetItem'))
      .toList();
  print('debug 9997782 ${itemOrderGroups[itemName]}, jjjj ${baseGroup}');
  if (baseGroup.isEmpty) {
    // Check if there are any non-empty addon selections before adding
    bool hasAddons = true;
    
    // If your addon selections are available here, check them
    // For now, we'll proceed with adding only if get items are present
    if (getItemInfoMap.entries.any((e) => e.value.buyItemName == itemName)) {
      hasAddons = true;
    }
    
    // Only add if we have addons or get items
    if (hasAddons) {
      itemOrderGroups[itemName]!.add({
        'quantity': quantity,
        'addonSelections': <String, bool>{},
        'customization': '',
      });
    }
    print('debug 9997783 ${itemOrderGroups[itemName]}, jjjj ${baseGroup}, lll${itemOrderGroups[itemName]}');
  } else {
    baseGroup.first['quantity'] = menuQuantity;
    print('debug 9997784 ${itemOrderGroups[itemName]}, jjjj ${baseGroup}');
  }
}
  

  void _resetAllGetItems() {
    getItemInfoMap.forEach((compositekey, info) {
      info.currentQuantity = 0;
      itemQuantities[compositekey] = 0;
    });
  }



  void _updateMenuItemQuantity(
      String itemName, int quantity, detail, String name) {
    setState(() {
      itemQuantities[itemName] = quantity;
      print('details 1234488 quantity, $quantity');
      print('details 1234488, $detail');
      _initializeGetItemInfo(detail, name);
      print('`trererreere');
      _updateGetItemInfo(itemName, quantity);
    });
  }






Future<void> _editCustomization(
    String itemName, int groupIndex, Map<String, dynamic> group) async {
  // Get the item details
  final item = menuItems.firstWhere(
    (elem) => elem['name'] == itemName,
    orElse: () => {},
  );
  
  // Check if item has sizes
  final bool hasSizes = item['sizes'] != null && (item['sizes'] as List).isNotEmpty;
  
  // Get add-on data
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  final uri = Uri.parse('${Config.baseUrl}/discount/item/$itemName/addons');
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  List<dynamic> addons = [];
  if (response.statusCode == 200) {
    addons = jsonDecode(response.body);
  }
  
  // Initialize local state for editing
  int localQuantity = group['quantity'] as int;
  Map<String, bool> localAddonSelections = {};
  for (var addon in addons) {
    final addonName = addon['addon_item_name'];
    localAddonSelections[addonName] =
        group['addonSelections'][addonName] ?? false;
  }
  
  // Get current size information if available
  String selectedSize = '';
  if (hasSizes) {
    selectedSize = group['selectedSize'] ?? '';
    if (selectedSize.isEmpty) {
      // Set default size if none selected
      final sizes = item['sizes'] as List;
      final defaultSize = sizes.firstWhere(
        (size) => size['is_default'] == true,
        orElse: () => sizes.first,
      );
      selectedSize = defaultSize['name'];
    }
  }
  
  TextEditingController customizationController =
      TextEditingController(text: group['customization'] ?? '');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(builder: (context, setModalState) {
        // Calculate add-ons total price
        double addonsTotal = 0;
        for (var addon in addons) {
          final addonName = addon['addon_item_name'];
          if (localAddonSelections[addonName] ?? false) {
            addonsTotal += (addon['addon_price'] as num).toDouble();
          }
        }
        
        // Calculate size price increment
        double sizeIncrement = 0.0;
        if (hasSizes) {
          final sizes = item['sizes'] as List;
          final selectedSizeObj = sizes.firstWhere(
            (size) => size['name'] == selectedSize,
            orElse: () => {'price_increment': 0},
          );
          sizeIncrement = (selectedSizeObj['price_increment'] as num).toDouble();
        }
        
        final basePrice = (item['discounted_price'] ?? item['price']) as num;
        final totalPrice = basePrice + addonsTotal + sizeIncrement;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Customization for $itemName',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Customization text field
              TextField(
                controller: customizationController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Size selection if applicable
              if (hasSizes) ...[
                const Text(
                  'Select Size:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (item['sizes'] as List).map<Widget>((size) {
                    final sizeName = size['name'];
                    final priceIncrement = size['price_increment'] as num;
                    final isSelected = selectedSize == sizeName;
                    
                    return ChoiceChip(
                      label: Text(
                        priceIncrement > 0 
                          ? '$sizeName (+₹$priceIncrement)'
                          : sizeName
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          setModalState(() {
                            selectedSize = sizeName;
                          });
                        }
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.blue[100],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Quantity selector
              Row(
                children: [
                  const Text('Quantity: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (localQuantity > 1) {
                        setModalState(() {
                          localQuantity--;
                        });
                      }
                    },
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$localQuantity',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setModalState(() {
                        localQuantity++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Price display
              Text(
                'Price (1 unit): ₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              
              // Add-ons section
              const Text(
                'Add-ons:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Scrollable add-ons list
              Expanded(
                child: addons.isEmpty 
                  ? const Center(child: Text('No add-ons available'))
                  : ListView.builder(
                      itemCount: addons.length,
                      itemBuilder: (context, index) {
                        final addon = addons[index];
                        final addonName = addon['addon_item_name'];
                        final addonPrice = addon['addon_price'];
                        return CheckboxListTile(
                          title: Text(
                            '$addonName (₹$addonPrice)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: addon['addon_description'] != null
                              ? Text(addon['addon_description'],
                                  style: const TextStyle(fontSize: 12))
                              : null,
                          value: localAddonSelections[addonName],
                          onChanged: (bool? selected) {
                            setModalState(() {
                              localAddonSelections[addonName] = selected ?? false;
                            });
                          },
                        );
                      },
                    ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        // Calculate updated add-ons total
                        double newAddonsTotal = 0.0;
                        for (var addon in addons) {
                          final addonName = addon['addon_item_name'];
                          if (localAddonSelections[addonName] ?? false) {
                            newAddonsTotal += (addon['addon_price'] as num).toDouble();
                          }
                        }
                        
                        // Calculate size information
                        double newSizeIncrement = 0.0;
                        if (hasSizes) {
                          final sizes = item['sizes'] as List;
                          final selectedSizeObj = sizes.firstWhere(
                            (size) => size['name'] == selectedSize,
                            orElse: () => {'price_increment': 0},
                          );
                          newSizeIncrement = (selectedSizeObj['price_increment'] as num).toDouble();
                        }
                        
                        // Update the item in itemOrderGroups
                        setState(() {
                          // Get the quantity difference
                          final int qtyDiff = localQuantity - (group['quantity'] as int);
                          
                          // Update the group properties
                          itemOrderGroups[itemName]![groupIndex]['quantity'] = localQuantity;
                          itemOrderGroups[itemName]![groupIndex]['addonSelections'] = 
                              Map<String, bool>.from(localAddonSelections);
                          itemOrderGroups[itemName]![groupIndex]['customization'] = 
                              customizationController.text;
                          itemOrderGroups[itemName]![groupIndex]['addonsTotal'] = newAddonsTotal;
                          
                          // Update size information if applicable
                          if (hasSizes) {
                            itemOrderGroups[itemName]![groupIndex]['selectedSize'] = selectedSize;
                            itemOrderGroups[itemName]![groupIndex]['sizePriceIncrement'] = newSizeIncrement;
                          }
                          
                          // Update total item quantity
                          int totalQty = 0;
                          itemOrderGroups[itemName]?.forEach((g) {
                            if (!(g['isGetItem'] ?? false)) {
                              totalQty += g['quantity'] as int;
                            }
                          });
                          // itemQuantities[itemName] = totalQty;
                        });
                        
                        Navigator.pop(context);
                        // Re-open the customization management modal to show updated information
                        _showCustomizationManagementModal(
                          context, 
                          itemName, 
                          addons.isNotEmpty, 
                          false // We don't need to refresh discounts
                        );
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    },
  );
}



  Future<bool> _showQuantityChangeConfirmation(BuildContext context,
      String buyItemName, int currentQty, int newQty) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        List<String> affectedItems = [];
        getItemInfoMap.forEach((key, info) {
          if (info.buyItemName == buyItemName && info.currentQuantity > 0) {
            affectedItems.add(info.name);
          }
        });

        return AlertDialog(
          title: const Text('Confirm Quantity Change'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Reducing quantity will adjust your selected discounted items:'),
              const SizedBox(height: 8),
              ...affectedItems.map((name) => Text('• $name')),
              const SizedBox(height: 8),
              Text('from $currentQty to $newQty. Do you want to proceed?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<bool> _updateGetQuantities(String itemName, int buyQuantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldProceed = true;

    // Use for-in loop instead of forEach for async operations
    for (var entry in getItemInfoMap.entries) {
      final compositeKey = entry.key;
      final info = entry.value;

      if (info.buyItemName == itemName) {
        final sets = (buyQuantity / info.buyQuantity).floor();
        final int result = sets * info.getQuantity;

        if (result < info.currentQuantity) {
          shouldProceed = await _showQuantityChangeConfirmation(
              context, itemName, info.currentQuantity, result);

          if (shouldProceed) {
            info.currentQuantity = result;
            itemQuantities[compositeKey] = info.currentQuantity;
          } else {
            return false;
          }
        }
      }
    }

    if (shouldProceed) {
      await prefs.setString('itemQuantities', jsonEncode(itemQuantities));
    }

    return shouldProceed;
  }

  void _customizeItem(String itemName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final customizationController = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customizationController,
                decoration: const InputDecoration(
                  labelText: 'Customization',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    itemCustomizations[itemName] = customizationController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToOrderDetails() async {
    // Build base price maps from menuItems.
    Map<String, double> basePrices = {};
    Map<String, double> baseDiscountedPrices = {};
    print('debug sending to navigation 999 $menuItems');
    for (var item in menuItems) {
      print('debug sending to navigation 1000 $item');
      String name = item['name'] as String;
      double price = (item['price'] as num).toDouble();
      double discountPrice =
          (item['discounted_price'] ?? item['price'] as num).toDouble();
      basePrices[name] = price;
      baseDiscountedPrices[name] = discountPrice;
    }

    // New maps for flattened orders.
    Map<String, int> newItemQuantities = {};
    Map<String, String> newItemCustomizations = {};
    Map<String, String> newItemFoodTypes = {};
    Map<String, String> newItemFoodCategories = {};
    Map<String, double> newItemPrices = {};
    Map<String, double> newItemDiscountedPrices = {};
    Map<String, String> newItemPromotionSources = {}; 
    
    Set<String> itemsWithCustomizations = {};
itemOrderGroups.keys.forEach((itemName) {
  if (itemOrderGroups[itemName]!.any((group) => !group.containsKey('isGetItem'))) {
      print('debug sending to navigation 1003 ${itemOrderGroups[itemName]}  $itemName ');
    itemsWithCustomizations.add(itemName);
  }
});

    // Add non-addon items.
    for (var entry in itemQuantities.entries) {
      print('debug sending to navigation 1004 $entry, kjhgjkh $itemQuantities');
      final itemName = entry.key;
        // Skip the base item if it has customizations
  if (itemsWithCustomizations.contains(itemName)) {
    continue;
  }
  print('debug sending to navigation 1002 ${basePrices[itemName]} ');
  if (basePrices[itemName] == null) {
    print('debug sending to navigation 1001 $itemName');
    continue;
  }
  print('debug sending to navigation roijfodd $itemName');
      newItemQuantities[itemName] = entry.value;
      newItemCustomizations[itemName] = itemCustomizations[itemName] ?? '';
      newItemFoodTypes[itemName] = itemFoodTypes[itemName] ?? '';
      newItemFoodCategories[itemName] = itemFoodCategories[itemName] ?? '';
      newItemPrices[itemName] = basePrices[itemName] ?? 0.0;
      newItemDiscountedPrices[itemName] = baseDiscountedPrices[itemName] ?? 0.0;
    }

    // Flatten addon orders: send each customization separately.
    itemOrderGroups.forEach((itemName, groups) {
      int index = 1;
      print('debug sending to navigation $groups');
      for (var group in groups) {
            // Skip groups that don't have the isGetItem key
            print('debug sending to navigation checking$group');
    if (!group.containsKey('isGetItem')) {
      continue; // Skip this group
    }
        String key = "$itemName#$index";
        int qty = group['quantity'] as int;
        print('debug sending to navigation 22 $groups');
        newItemQuantities[key] = qty;
        newItemCustomizations[key] = group['customization'] ?? '';
        newItemFoodTypes[key] = itemFoodTypes[itemName] ?? '';
        newItemFoodCategories[key] = itemFoodCategories[itemName] ?? '';
        double addonTotal = group['addonsTotal'] ?? 0.0;
        newItemPrices[key] = (basePrices[itemName] ?? 0.0) + addonTotal;
        newItemDiscountedPrices[key] =
            (baseDiscountedPrices[itemName] ?? 0.0) + addonTotal;
        index++;
      }
    });

    Map<String, double> newAddonPrices = {};

    // For regular orders (without addons), the addon price is zero.
    newItemPrices.forEach((key, value) {
      if (!key.contains('#')) {
        newAddonPrices[key] = 0.0;
      }
    });

    // For addon orders, compute per-unit addon cost.
    itemOrderGroups.forEach((itemName, groups) {
      int index = 1;
      for (var group in groups) {
            // Skip groups that don't have the isGetItem key
    if (!group.containsKey('isGetItem')) {
      continue; // Skip this group
    }
    
        String key = "$itemName#$index";
        int qty = group['quantity'] as int;
        double addonTotal = group['addonsTotal'] ?? 0.0;
        double addonPerUnit = qty > 0 ? addonTotal / qty : 0.0;
        newAddonPrices[key] = addonPerUnit;
        index++;
      }
    });

        // ADD THIS NEW SECTION: Include get items from getItemInfoMap
    getItemInfoMap.forEach((compositeKey, info) {
      // Only include items with quantity > 0
      if (info.currentQuantity > 0) {
        String key = "${info.name}#promo";
        
        newItemQuantities[key] = info.currentQuantity;
        newItemCustomizations[key] = "Promotional item from buy ${info.buyQuantity} get ${info.getQuantity} offer on ${info.buyItemName}";
        newItemFoodTypes[key] = info.foodType;
        newItemFoodCategories[key] = ""; // You may need to set this if available
        
        // Use the discounted price for get items
        newItemPrices[key] = info.originalPrice;
        newItemDiscountedPrices[key] = info.discountedPrice;
        newAddonPrices[key] = 0.0; // No addons for promotional items

            // Store the buy item name for this promotional item
    newItemPromotionSources[key] = info.buyItemName;

        
      }
    });

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          itemQuantities: newItemQuantities,
          // Add the new map to the constructor parameters
          promotionSources: newItemPromotionSources,
          itemCustomizations: newItemCustomizations,
          itemFoodTypes: newItemFoodTypes,
          itemFoodCategories: newItemFoodCategories,
          menuItems: menuItems,
          itemPrices: newItemPrices,
          itemDiscountedPrices: newItemDiscountedPrices,
          itemOrderGroups: {}, // added required parameter
          addonPrices: newAddonPrices,
          
        ),
      ),
    );

    if (result != null) {
      setState(() {
        itemQuantities = result['itemQuantities'];
        itemCustomizations = result['itemCustomizations'];
      });
    }
  }

  String _getBuyXGetYMessage(dynamic item) {
    if (item['discount_rules'] != null &&
        item['discount_rules']['type'] == 'buy_x_get_y') {
      final buyQuantity = item['discount_rules']['buy_quantity'];
      final getQuantity = item['discount_rules']['get_quantity'];
      final freeQuantity = getQuantity - buyQuantity;
      return 'Buy $buyQuantity Get $freeQuantity Free';
    }
    return '';
  }

  String _getBuyXGetYAtZMessage(String itemName, int baseQuantity,
      String getItemName, List<dynamic> details) {
    // _initializeGetItemInfo(details,itemName);
    // _updateGetItemInfo(itemName, baseQuantity);

    final info = getItemInfoMap[getItemName];
    if (info == null) return '';

    final remainder = baseQuantity % info.buyQuantity;
    final remainingForNext =
        remainder == 0 ? info.buyQuantity : info.buyQuantity - remainder;

    if (baseQuantity < info.buyQuantity) {
      return 'Buy $remainingForNext more to get ${info.getQuantity} $getItemName at discounted price';
    } else {
      return 'You can get up to ${info.currentQuantity} $getItemName at discounted price\nAdd $remainingForNext more to get additional ${info.getQuantity}';
    }
  }

  @override


Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Menu Items'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
            await prefs.remove('token_type');
            await prefs.remove('role');
            await prefs.remove('permissions');
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    ),
    body: Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodTypes.length,
                itemBuilder: (context, index) {
                  final foodType = foodTypes[index];
                  return GestureDetector(
                    onTap: () => _filterByFoodType(foodType['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selectedFoodTypes.contains(foodType['name'])
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          foodType['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final itemName = item['name'];
                    final totalGetQuantity = _getTotalQuantity(itemName);
                    final foodType = item['food_type'];
                    final category = item['category'];
                    final description = item['description'];
                    final price = item['price'];
                    final discountedPrice = item['discounted_price'] ?? price;
                    final isExpanded = isExpandedMap[itemName] ?? false;
                    final buyXGetYMessage = _getBuyXGetYMessage(item);
                    List<String> blueMessage = [];
                    print('item 123, $item');
                    print('menuitem1234567 $itemName');
                    print('itemName 123, $totalGetQuantity');

                    getItemInfoMap.forEach((key, info) {
                      print(
                          'itemName 566 456,$itemName, key 456,$key, info.currentQuantity 456,${info.currentQuantity}, ${info.name}');
                      if (info.currentQuantity > 0 && itemName == info.name) {
                        print(
                            'info.currentQuantity 566,${info.currentQuantity}');
                        print('info.key 566 ,$key');
                        blueMessage.add(
                            'You have purchased ${info.currentQuantity} quantity at ₹${info.discountedPrice} as you have selected ${info.name} in ${info.buyItemName}');
                      } else {
                        print(
                            'info.currentQuantity 215 566,${info.currentQuantity}');
                        print('itemName 215 ,$itemName');
                        print('Key 215 ,$key');
                      }
                    });

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (discountedPrice < price) ...[
                                  Text(
                                    'Price: ₹$price',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹$discountedPrice',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else
                                  Text('Price: ₹$price'),
                                if (buyXGetYMessage.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    buyXGetYMessage,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (blueMessage.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: blueMessage.map((message) {
                                  final info = getItemInfoMap.values.firstWhere(
                                      (info) =>
                                          'You have purchased ${info.currentQuantity} quantity at ₹${info.discountedPrice} as you have selected ${info.name} in ${info.buyItemName}' ==
                                          message);
                                  return GestureDetector(
                                    onTap: () => showItemModal(
                                      context,
                                      info.buyItemName,
                                      hasAddons: true,
                                      hasDiscounts: true,
                                    ),
                                    child: Text(
                                      message,
                                      style: const TextStyle(color: Colors.blue),
                                    ),
                                  );
                                }).toList(),
                              ),
                            Row(
                              children: [
                                Text('Food Type: $foodType'),
                                const SizedBox(width: 10),
                                Text('Category: $category'),
                              ],
                            ),
                            if (description != null && description.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isExpanded
                                        ? description
                                        : description.length > 50
                                            ? '${description.substring(0, 50)}...'
                                            : description,
                                  ),
                                  if (description.length > 50)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isExpandedMap[itemName] =
                                              !isExpanded;
                                        });
                                      },
                                      child: Text(
                                        isExpanded ? 'less' : 'more',
                                        style: const TextStyle(
                                            color: Colors.blue),
                                      ),
                                    ),
                                ],
                              ),
                            if (itemCustomizations.containsKey(itemName))
                              Text(
                                  'Customization: ${itemCustomizations[itemName]}'),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: totalGetQuantity == 0
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              _handleAddItem(context, item),
                                          child: const Text('Add'),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () =>
                                                  _handleAddItem(context, item),
                                            ),
                                            Text('$totalGetQuantity'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () =>
                                                  _handleAddItem(context, item),
                                            ),
                                          ],
                                        ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _customizeItem(itemName),
                                  child: const Text('Customize'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        if (_isCategoryModalVisible)
          Positioned(
            bottom: 10,
            left: 30,
            right: 30,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category['name']),
                          onTap: () => _filterByCategory(category['name']),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
      ],
    ),
    floatingActionButton: Stack(
      children: [
        if (menuItems.any((item) => _getTotalQuantity(item['name']) > 0))
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: _navigateToOrderDetails,
              child: const Text('Order'),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: _toggleCategoryModal,
            child: const Icon(Icons.book),
          ),
        ),
      ],
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
}