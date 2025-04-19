
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'websocket_service.dart';
import 'http_client.dart';
import 'config.dart';
import 'menu_screen.dart';
// Add this import at the top of the file with your other imports
import 'table_screen/screens/table_selection_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, int> itemQuantities;
  final Map<String, String> itemCustomizations;
  final Map<String, String> itemFoodTypes;
  final Map<String, String> itemFoodCategories;
  final Map<String, double> itemPrices;
  final Map<String, double> itemDiscountedPrices;
  final List<dynamic> menuItems;
  final Map<String, List<Map<String, dynamic>>> itemOrderGroups;
  final Map<String, double> addonPrices;
  final Map<String, String> promotionSources; // Add this line
  
  

  const OrderDetailsScreen({
    super.key,
    required this.itemQuantities,
    required this.itemCustomizations,
    required this.itemFoodTypes,
    required this.itemFoodCategories,
    required this.itemPrices,
    required this.itemDiscountedPrices,
    required this.menuItems,
    required this.itemOrderGroups,
    required this.addonPrices,
    this.promotionSources = const {}, // Add with default empty map
  });
  
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, int> itemQuantities = {};
  Map<String, String> itemCustomizations = {};
  Map<String, String> itemFoodTypes = {};
  Map<String, String> itemFoodCategories = {};
  Map<String, double> itemPrices = {};
  Map<String, double> itemDiscountedPrices = {};
  String overallCustomization = '';
  final _tableNoController = TextEditingController();
  late WebSocketService webSocketService;
  List<dynamic> menuItems = [];
  
















// Modify _calculateBuyXGetYPrice and _getBuyXGetYMessage to always apply the promo
// even for addon/customization orders by extracting the base item name.
double _calculateBuyXGetYPrice(String itemName, int quantity, [double addonTotal = 0.0]) {
  // Extract the base item name if itemName contains an addon customization suffix (e.g., "Burger#1").
  String baseItemName = itemName.split('#').first;
  final rawItem = widget.menuItems.firstWhere(
    (item) => item['name'] == baseItemName,
    orElse: () => <String, dynamic>{},
  );
  final item = Map<String, dynamic>.from(rawItem);

  // Get the base price from the map or fallback to the menu data.
  final basePriceFromMap = itemPrices[baseItemName] ?? 0.0;
  final basePrice = basePriceFromMap > 0.0
      ? basePriceFromMap
      : (item['price'] != null ? (item['price'] as num).toDouble() : 0.0);

  print('Base item: $baseItemName, basePrice: $basePrice, addonTotal per unit: $addonTotal');
  
  if (item.isNotEmpty &&
      item['discount_rules'] != null &&
      item['discount_rules']['type'] == 'buy_x_get_y') {
      
    final buyQuantity = item['discount_rules']['buy_quantity'] as int;
    final getQuantity = item['discount_rules']['get_quantity'] as int;
    
    // Calculate how many items are paid based on the promo, applying discount only on base price.
    final fullSets = (quantity ~/ getQuantity) * buyQuantity;
    final remainder = quantity % getQuantity;
    final remainderPaid = remainder < buyQuantity ? remainder : buyQuantity;
    final paidItems = fullSets + remainderPaid;
    
    // The discount only applies to the base price; addons are always paid.
    final discountedBaseCost = basePrice * paidItems;
    final addonCost = addonTotal * quantity;
    
    print('Quantity: $quantity, Paid base items: $paidItems');
    return discountedBaseCost + addonCost;
  }
  print("addonTotal: $addonTotal");
  // If no discount, return the full cost (base price + addon per unit) * quantity.
  return (basePrice + addonTotal) * quantity;
}
String _getBuyXGetYMessage(String itemName, int quantity) {
  // Use base item name so that promo applies for each customization.
  String baseItemName = itemName.split('#').first;
  final rawItem = widget.menuItems.firstWhere(
    (item) => item['name'] == baseItemName,
    orElse: () => <String, dynamic>{},
  );
  print("rawItem: $baseItemName");
  final item = Map<String, dynamic>.from(rawItem);
  if (item.isNotEmpty &&
      item['discount_rules'] != null &&
      item['discount_rules']['type'] == 'buy_x_get_y') {
    print('Item Name for buy x get y: $baseItemName');
    final buyQuantity = item['discount_rules']['buy_quantity'] as int;
    final getQuantity = item['discount_rules']['get_quantity'] as int;
    final remainder = quantity % getQuantity;
    if (remainder > 0 && remainder < buyQuantity) {
      return 'Buy ${buyQuantity - remainder} more of $baseItemName and get ${getQuantity - buyQuantity} free!';
    } else if (remainder >= buyQuantity && remainder < getQuantity) {
      return 'Add ${getQuantity - remainder} more of $baseItemName for free!';
    } else if (remainder == 0) {
      return 'Buy $buyQuantity get ${getQuantity - buyQuantity} $baseItemName free!';
    }
  }
  return '';
}


  @override
  void initState() {
    super.initState();
    itemQuantities = Map.from(widget.itemQuantities);
    itemCustomizations = Map.from(widget.itemCustomizations);
    itemFoodTypes = Map.from(widget.itemFoodTypes);
    itemFoodCategories = Map.from(widget.itemFoodCategories);
    itemPrices = Map.from(widget.itemPrices);
    itemDiscountedPrices = Map.from(widget.itemDiscountedPrices);
    _initializeWebSocket();
    _fetchMenuItems();
  }

  Future<void> _initializeWebSocket() async {
    final employeeId = await HttpClient.getEmployeeId();
    final token = await HttpClient.getToken();
    if (token != null) {
      webSocketService = WebSocketService(
        url: '${Config.wsUrl}/waiter/$employeeId',
        token: token,
      );
      webSocketService.connect();
    } else {
      print('Token not found');
    }
  }

  Future<void> _fetchMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final uri = Uri.parse('${Config.baseUrl}/menu/items');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          menuItems = jsonDecode(response.body);
          for (var item in menuItems) {
            final itemName = item['name'];
            itemFoodTypes[itemName] = item['food_type'];
            itemFoodCategories[itemName] = item['category'];
            itemPrices[itemName] = (item['price'] as num).toDouble();
            itemDiscountedPrices[itemName] = (item['discounted_price'] ?? item['price'] as num).toDouble();
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          print('Failed to load menu items: ${response.statusCode}');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        print('An error occurred: $e');
      });
    }
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }

  void _incrementQuantity(String itemName) {
    setState(() {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String itemName) {
    setState(() {
      if (itemQuantities[itemName] != null && itemQuantities[itemName]! > 0) {
        itemQuantities[itemName] = itemQuantities[itemName]! - 1;
        if (itemQuantities[itemName] == 0) {
          itemQuantities.remove(itemName);
          itemCustomizations.remove(itemName);
          itemFoodTypes.remove(itemName);
          itemFoodCategories.remove(itemName);
          itemPrices.remove(itemName);
          itemDiscountedPrices.remove(itemName);
        }
      }
    });
  }

  // For addon group quantity changes
  void _incrementGroupQuantity(String itemName, Map<String, dynamic> group) {
    setState(() {
      group['quantity'] = (group['quantity'] as int) + 1;
    });
  }

  void _decrementGroupQuantity(String itemName, Map<String, dynamic> group) {
    setState(() {
      if ((group['quantity'] as int) > 1) {
        group['quantity'] = (group['quantity'] as int) - 1;
      }
    });
  }

  void _customizeItem(String itemName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final customizationController = TextEditingController(text: itemCustomizations[itemName]);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customizationController,
                decoration: InputDecoration(
                  labelText: 'Customization',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    itemCustomizations[itemName] = customizationController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }




Future<void> _placeOrder() async {
  if (_tableNoController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table No is required')),
    );
    return;
  }
  final tableNumber = int.parse(_tableNoController.text);
  final token = await HttpClient.getToken();
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token not found')),
    );
    return;
  }
  
  // Build orderItems including both regular and addon orders
  final orderItems = [
    // Regular orders (non-addon)
    ...itemQuantities.entries.where((entry) {
      return !widget.itemOrderGroups.containsKey(entry.key);
    }).map((entry) {
      final itemName = entry.key;
      final quantity = entry.value;
      final customization = itemCustomizations[itemName] ?? '';
      final foodType = itemFoodTypes[itemName] ?? '';
      final foodCategory = itemFoodCategories[itemName] ?? '';
      final price = itemPrices[itemName] ?? 0.0;
      final discountedPrice = itemDiscountedPrices[itemName] ?? price;
      // Also grab discount_rules from menuItems for consistency
      final discountRules = widget.menuItems.firstWhere(
        (item) => item['name'] == itemName,
        orElse: () => <String, dynamic>{},
      )['discount_rules'];
      return {
        'name': itemName,
        'quantity': quantity,
        'customization': customization,
        'food_type': foodType,
        'food_category': foodCategory,
        'price': price,
        if (discountedPrice < price) 'discounted_price': discountedPrice,
        'discount_rules': discountRules,
      };
    }),
    // Addon/customization orders
    ...widget.itemOrderGroups.entries.expand((entry) {
      final itemName = entry.key;
      
      // Retrieve discount_rules from menuItems for the current item.
      final discountRules = widget.menuItems.firstWhere(
        (item) => item['name'] == itemName,
        orElse: () => <String, dynamic>{},
      )['discount_rules'];
      return entry.value.map((group) {
        final groupQuantity = group['quantity'] as int;
        final customization = group['customization'] ?? '';
        final addonsTotal = group['addons_total'] is double
            ? group['addons_total'] as double
            : 0.0;
        final foodType = itemFoodTypes[itemName] ?? '';
        final foodCategory = itemFoodCategories[itemName] ?? '';
        final basePrice = itemPrices[itemName] ?? 0.0;
        final discountedBase = itemDiscountedPrices[itemName] ?? basePrice;
        final effectivePrice = basePrice + addonsTotal;
        final effectiveDiscountPrice = discountedBase + addonsTotal;
        return {
          'name': itemName,
          'quantity': groupQuantity,
          'customization': customization,
          'addonSelections': group['addonSelections'],
          'food_type': foodType,
          'food_category': foodCategory,
          'price': effectivePrice,
          if (effectiveDiscountPrice < effectivePrice)
            'discounted_price': effectiveDiscountPrice,
          'discount_rules': discountRules,
        };
      });
    }),
  ];

  final orderData = {
    'item_quantities': itemQuantities,
    'item_customizations': itemCustomizations,
    'item_food_types': itemFoodTypes,
    'item_food_categories': itemFoodCategories,
    'item_prices': itemPrices,
    'item_discounted_prices': itemDiscountedPrices,
    'items': orderItems,
  };

  final queryParams = {
    'token': token,
    'table_number': tableNumber.toString(),
    'overall_customization': overallCustomization,
  };

  final uri =
      Uri.parse('${Config.baseUrl}/ordersystem/place_order').replace(queryParameters: queryParams);

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully')),
      );
      webSocketService.sendMessage(jsonEncode(orderData));
      Navigator.pop(context, {
        'itemQuantities': itemQuantities,
        'itemCustomizations': itemCustomizations,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order')),
      );
    }
  } catch (e) {
    print('Error placing order: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error placing order: $e')),
    );
  }
}


















  @override
  Widget build(BuildContext context) {

    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'itemQuantities': itemQuantities,
          'itemCustomizations': itemCustomizations,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Regular orders display with quantity controls and promotional message
                    ...itemQuantities.entries.where((entry) {
                      return !widget.itemOrderGroups.containsKey(entry.key);
                    }).map((entry) {
                      final itemName = entry.key;
                      final quantity = entry.value;
                      final customization = itemCustomizations[itemName] ?? '';
                      final foodType = itemFoodTypes[itemName] ?? 'Unknown';
                      final category = itemFoodCategories[itemName] ?? 'Unknown';
                      final price = itemPrices[itemName] ?? 0.0;
                      final discountedPrice = itemDiscountedPrices[itemName] ?? price;
                      final totalPrice = price * quantity;
                      double addonPerUnit = widget.addonPrices.containsKey(itemName)
                                  ? widget.addonPrices[itemName]!
                                   : 0.0;
                      return Hero(
                        tag: 'order-card-$itemName-regular',
                        child: Card(
                          key: ValueKey('$itemName-regular'),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Item: $itemName'),
                                Text('Customization: $customization'),
                                Row(
                                  children: [
                                    Text('Food Type: $foodType'),
                                    SizedBox(width: 10),
                                    Text('Category: $category'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () => _decrementQuantity(itemName),
                                        ),
                                        Text('$quantity'),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () => _incrementQuantity(itemName),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _customizeItem(itemName),
                                      child: Text('Customize'),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (discountedPrice < price) ...[
                                      Text(
                                        'Price: ₹$totalPrice',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '₹${(discountedPrice * quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else if (_calculateBuyXGetYPrice(itemName, quantity, addonPerUnit) > 0) ...[
                                      Text(
                                        'Price: ₹$totalPrice',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '₹${_calculateBuyXGetYPrice(itemName, quantity, addonPerUnit).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else
                                      Text('Price: ₹$totalPrice'),
                                  ],
                                ),
                                if (_getBuyXGetYMessage(itemName, quantity).isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(top: 8),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _getBuyXGetYMessage(itemName, quantity),
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    // Addon/customization orders display with quantity controls
                    ...widget.itemOrderGroups.entries.expand((entry) {
                      final itemName = entry.key;
                      return entry.value.map((group) {
                        final groupQuantity = group['quantity'] as int;
                        final customization = group['customization'] ?? '';
                        final addonsTotal = group['addons_total'] is double ? group['addons_total'] as double : 0.0;
                        final foodType = itemFoodTypes[itemName] ?? 'Unknown';
                        final category = itemFoodCategories[itemName] ?? 'Unknown';
                        final basePrice = itemPrices[itemName] ?? 0.0;
                        final discountedBase = itemDiscountedPrices[itemName] ?? basePrice;
                        final effectivePrice = basePrice + addonsTotal;
                        final effectiveDiscountPrice = discountedBase + addonsTotal;
                        final totalPrice = effectivePrice * groupQuantity;
                        return Hero(
                          tag: 'order-card-$itemName-addon-${group.hashCode}',
                          child: Card(
                            key: ValueKey('$itemName-addon-${group.hashCode}'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item: $itemName'),
                                  Text('Customization: $customization'),
                                  Text('Addon Selections: ${group['addonSelections'].toString()}'),
                                  Row(
                                    children: [
                                      Text('Food Type: $foodType'),
                                      SizedBox(width: 10),
                                      Text('Category: $category'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () => _decrementGroupQuantity(itemName, group),
                                          ),
                                          Text('${group['quantity']}'),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () => _incrementGroupQuantity(itemName, group),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (effectiveDiscountPrice < effectivePrice) ...[
                                        Text(
                                          'Price: ₹$totalPrice',
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '₹${(effectiveDiscountPrice * group['quantity']).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else
                                        Text('Price: ₹$totalPrice'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  ],
                ),
              ),
              

// Around line 655 in your code
Row(
  children: [
    Expanded(
      child: TextField(
        controller: _tableNoController,
        decoration: InputDecoration(
          labelText: 'Table No',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    ),
    SizedBox(width: 8),
    ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();
          final uniqueHeroTag = 'order_details_${DateTime.now().millisecondsSinceEpoch}';
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableSelectionScreen(
              selectedDate: now,
              partySize: 1,
              selectionMode: true,
              initialSelectedTableIds: const [],
              heroTagPrefix: uniqueHeroTag,
            ),
          ),
        );
        
        if (result != null && result is List && result.isNotEmpty) {
          final selectedTable = result[0];
          setState(() {
            _tableNoController.text = selectedTable.tableNumber.toString();
          });
        }
      },
      child: Text('Select'),
    ),
  ],
),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Overall Customization',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    overallCustomization = value;
                  });
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _placeOrder,
                child: Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}