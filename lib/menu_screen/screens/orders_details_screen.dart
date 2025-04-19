import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/promotion_controller.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/promotion_message.dart';
import '../../table_screen/screens/table_selection_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isSubmitting = false;
  String _errorMessage = '';

    // Add controllers for table number and overall customization
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _overallCustomizationController = TextEditingController();
  
  @override
  void dispose() {
    _tableNumberController.dispose();
    _overallCustomizationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Consumer2<CartController, PromotionController>(
        builder: (context, cartController, promotionController, child) {
          if (cartController.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Regular items
                    ..._buildRegularItems(cartController, context),

                    // Customized items
                    ..._buildCustomizedItems(cartController, context),

                    // Promotional items
                    ..._buildPromotionalItems(promotionController, context),

                    const Divider(thickness: 2),

                    // Order summary removed

                    _buildOrderInfoFields(),

const SizedBox(height: 16),



                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              // Checkout button
              _buildCheckoutButton(cartController, promotionController),
            ],
          );
        },
      ),
    );
  }





Widget _buildOrderInfoFields() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Order Information',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      
      // Table Number Row with TextField and Select Button
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _tableNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Table Number *',
                hintText: 'Enter table number',
                border: OutlineInputBorder(),
                isDense: true,
              ),
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
                  _tableNumberController.text = selectedTable.tableNumber.toString();
                });
              }
            },
            child: Text('Select'),
          ),
        ],
      ),
      
      const SizedBox(height: 12),
      
      // Overall Customization Field (optional)
      TextField(
        controller: _overallCustomizationController,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Overall Notes',
          hintText: 'Any notes for the entire order',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    ],
  );
}



  // Add this method to your class
// Widget _buildOrderInfoFields() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Order Information',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 12),
      
//       // Table Number Field (required)
//       TextField(
//         controller: _tableNumberController,
//         keyboardType: TextInputType.number,
//         decoration: const InputDecoration(
//           labelText: 'Table Number *',
//           hintText: 'Enter table number',
//           border: OutlineInputBorder(),
//           isDense: true,
//         ),
//       ),
//       const SizedBox(height: 12),
      
//       // Overall Customization Field (optional)
//       TextField(
//         controller: _overallCustomizationController,
//         maxLines: 2,
//         decoration: const InputDecoration(
//           labelText: 'Overall Notes',
//           hintText: 'Any notes for the entire order',
//           border: OutlineInputBorder(),
//           isDense: true,
//         ),
//       ),
//     ],
//   );
// }

  List<Widget> _buildRegularItems(
      CartController cartController, BuildContext context) {
    List<Widget> widgets = [];

    // First add a header if there are regular items
    if (cartController.itemQuantities.isNotEmpty) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Your Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Now add each item
    cartController.itemQuantities.forEach((itemName, quantity) {
      // Skip items with customization groups
      if (cartController.itemOrderGroups.containsKey(itemName)) {
        return;
      }

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(itemName),
            subtitle: cartController.itemCustomizations.containsKey(itemName)
                ? Text(
                    'Customization: ${cartController.itemCustomizations[itemName]}')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      cartController.decrementQuantity(itemName, context),
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => cartController.incrementQuantity(itemName),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await cartController.setQuantity(itemName, 0, context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });

    return widgets;
  }

  

  List<Widget> _buildCustomizedItems(
      CartController cartController, BuildContext context) {
    List<Widget> widgets = [];

    // First add a header if there are customized items
    if (cartController.itemOrderGroups.isNotEmpty) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Customized Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Now add each customized item
    cartController.itemOrderGroups.forEach((itemName, groups) {
      for (int i = 0; i < groups.length; i++) {
        final group = groups[i];
        if (group['isGetItem'] == true) continue; // Skip promotional items

        final int quantity = group['quantity'] as int? ?? 0;
        final String customization = group['customization'] as String? ?? '';
        final Map<String, dynamic>? selectedAddons =
            group['selectedAddons'] as Map<String, dynamic>?;

        // Build add-ons text
        String addonsText = '';
        if (selectedAddons != null && selectedAddons.isNotEmpty) {
          addonsText = selectedAddons.keys.join(', ');
        }

        // Build size text
        String sizeText = '';
        if (group['has_size'] == true && group['selectedSize'] != null) {
          sizeText = 'Size: ${group['selectedSize']}';
        }

        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('$itemName ${i + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customization.isNotEmpty) Text('Notes: $customization'),
                  if (addonsText.isNotEmpty) Text('Add-ons: $addonsText'),
                  if (sizeText.isNotEmpty) Text(sizeText),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        final updatedGroup = Map<String, dynamic>.from(group);
                        updatedGroup['quantity'] = quantity - 1;
                        cartController.updateCustomizedItem(
                          itemName: itemName,
                          groupIndex: i,
                          quantity: quantity - 1,
                          addonSelections: Map<String, bool>.from(
                              group['addonSelections'] ?? {}),
                          customization: customization,
                          addonsTotal: group['addonsTotal'] ?? 0.0,
                          selectedAddons: selectedAddons != null
                              ? Map<String, Map<String, dynamic>>.from(
                                  selectedAddons)
                              : null,
                          hasSize: group['has_size'] ?? false,
                          selectedSize: group['selectedSize'] ?? '',
                          sizePriceIncrement:
                              group['sizePriceIncrement'] ?? 0.0,
                        );
                      } 
                      else if (quantity == 1) {
                        // If quantity would reach zero, remove the item completely
                        cartController.removeCustomizedItem(itemName, i);
                      }
                    },
                  ),
                  Text('$quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final updatedGroup = Map<String, dynamic>.from(group);
                      updatedGroup['quantity'] = quantity + 1;
                      cartController.updateCustomizedItem(
                        itemName: itemName,
                        groupIndex: i,
                        quantity: quantity + 1,
                        addonSelections: Map<String, bool>.from(
                            group['addonSelections'] ?? {}),
                        customization: customization,
                        addonsTotal: group['addonsTotal'] ?? 0.0,
                        selectedAddons: selectedAddons != null
                            ? Map<String, Map<String, dynamic>>.from(
                                selectedAddons)
                            : null,
                        hasSize: group['has_size'] ?? false,
                        selectedSize: group['selectedSize'] ?? '',
                        sizePriceIncrement: group['sizePriceIncrement'] ?? 0.0,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        cartController.removeCustomizedItem(itemName, i),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
        );
      }
    });

    return widgets;
  }



  List<Widget> _buildPromotionalItems(
      PromotionController promotionController, BuildContext context) {
    List<Widget> widgets = [];
    bool hasPromotionalItems = false;

    // Check if there are any promotional items
    promotionController.getItemInfoMap.forEach((key, info) {
      if (info.currentQuantity > 0) {
        hasPromotionalItems = true;
      }
    });

    // Add header if there are promotional items
    if (hasPromotionalItems) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Promotional Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Add each promotional item
    promotionController.getItemInfoMap.forEach((key, info) {
      if (info.currentQuantity > 0) {
        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.blue),
              title: Text(info.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From promotion on ${info.buyItemName}',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  Text(
                    'Discounted price: ₹${info.discountedPrice}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Text(
                '${info.currentQuantity}x',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
    });

    return widgets;
  }

  Widget _buildCheckoutButton(
      CartController cartController, PromotionController promotionController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _isSubmitting
            ? null
            : () => _submitOrder(cartController, promotionController),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Place Order',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }



void _submitOrder(CartController cartController,
    PromotionController promotionController) async {
  // Validate table number
  if (_tableNumberController.text.trim().isEmpty) {
    setState(() {
      _errorMessage = 'Please enter a table number';
    });
    return;
  }
  
  // Try to parse table number
  int? tableNumber;
  try {
    tableNumber = int.parse(_tableNumberController.text.trim());
  } catch (e) {
    setState(() {
      _errorMessage = 'Please enter a valid table number';
    });
    return;
  }

  setState(() {
    _isSubmitting = true;
    _errorMessage = '';
  });
    try {
    // Build order data in the format expected by the API
    final Map<String, dynamic> orderData = {
      'table_number': tableNumber,
      'overall_customization': _overallCustomizationController.text.trim(),

      // Required body parameters
      'item_quantities': _buildItemQuantities(cartController),
      'item_food_types': _buildItemFoodTypes(cartController),
      'item_food_categories': _buildItemFoodCategories(cartController),
      'item_prices': _buildItemPrices(cartController),
      
      // Customization details formatted as expected by backend
      'item_customization_details': _buildItemCustomizationDetails(cartController),
      
      // Promotions
      'promotions': _buildPromotions(promotionController),
    };

    // Submit the order
    final result = await ApiService.submitOrder(orderData);

    // Clear cart on successful order
    cartController.clearCart();
    promotionController.resetAllGetItems();

    // Show success and navigate back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
    } catch (e) {
    setState(() {
      _errorMessage = 'Error: $e';
    });
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}

  
// Helper methods to build the order data in the required format

Map<String, int> _buildItemQuantities(CartController cartController) {
  Map<String, int> quantities = {};
  
  // Add regular items
  quantities.addAll(cartController.itemQuantities);
  
  // Add customized items
  cartController.itemOrderGroups.forEach((itemName, groups) {
    int totalQuantity = 0;
    for (var group in groups) {
      if (group['isGetItem'] == true) continue;
      totalQuantity += group['quantity'] as int? ?? 0;
    }
    quantities[itemName] = totalQuantity;
  });
  
  return quantities;
}





// Map<String, String> _buildItemCustomizations(CartController cartController) {
//   Map<String, String> customizations = {};
  
//   // Add regular item customizations
//   customizations.addAll(cartController.itemCustomizations);
  
//   // Add customized items - for these, we'll combine customizations with a separator
//   cartController.itemOrderGroups.forEach((itemName, groups) {
//     List<String> allCustomizations = [];
//     for (var group in groups) {
//       if (group['isGetItem'] == true) continue;
//       String customization = group['customization'] as String? ?? '';
//       if (customization.isNotEmpty) {
//         allCustomizations.add(customization);
//       }
//     }
    
//     if (allCustomizations.isNotEmpty) {
//       customizations[itemName] = allCustomizations.join('; ');
//     }
//   });
  
//   return customizations;
// }

// Method that includes item name in each customization detail

// New helper method to build detailed customization information
// 
// Map<String, String> _buildItemFoodTypes(CartController cartController) {
//   // In a real app, you would get this from your menu data
//   // For this example, we'll use placeholder values
//   Map<String, String> foodTypes = {};
  
//   cartController.itemQuantities.keys.forEach((itemName) {
//     foodTypes[itemName] = "Veg"; // Default to Veg for example
//   });
  
//   cartController.itemOrderGroups.keys.forEach((itemName) {
//     foodTypes[itemName] = "Veg"; // Default to Veg for example
//   });
  
//   return foodTypes;
// }

Map<String, String> _buildItemFoodTypes(CartController cartController) {
  Map<String, String> foodTypes = {};
  
  for (var itemName in cartController.itemQuantities.keys) {
    foodTypes[itemName] = cartController.getItemFoodType(itemName);
  }
  
  for (var itemName in cartController.itemOrderGroups.keys) {
    foodTypes[itemName] = cartController.getItemFoodType(itemName);
  }
  
  return foodTypes;
}




Map<String, List<Map<String, dynamic>>> _buildItemCustomizationDetails(CartController cartController) {
  Map<String, List<Map<String, dynamic>>> details = {};
  
  // Process customized items
  cartController.itemOrderGroups.forEach((itemName, groups) {
    List<Map<String, dynamic>> itemCustomizations = [];
    
    for (var group in groups) {
      if (group['isGetItem'] == true) continue;
      
      int quantity = group['quantity'] as int? ?? 0;
      if (quantity <= 0) continue;
      
      // Create customization object according to backend structure
      Map<String, dynamic> customization = {
        "quantity": quantity,
        "customization": group['customization'] ?? ""
      };
      
      // Add size if available
      if (group['has_size'] == true && group['selectedSize'] != null) {
        customization["size"] = {
          "size_name": group['selectedSize'],
          "price": group['sizePriceIncrement'] ?? 0.0
        };
      }
      // Add addons as a list
      List<Map<String, dynamic>> addons = [];
      Map<String, dynamic>? selectedAddons = group['selectedAddons'] as Map<String, dynamic>?;
      if (selectedAddons != null && selectedAddons.isNotEmpty) {
        selectedAddons.forEach((addonName, addonInfo) {
          addons.add({
            "addon_name": addonName,
            "quantity": quantity,
            "price": (addonInfo is Map) ? (addonInfo['price'] ?? 0.0) : 0.0
          });
        });
      }
      customization["addons"] = addons;
      
      // Add this customization to the item's list
      itemCustomizations.add(customization);
    }
    
    // Only add items with customizations
    if (itemCustomizations.isNotEmpty) {
      details[itemName] = itemCustomizations;
    }
  });
  
  return details;
}



// Map<String, String> _buildItemFoodCategories(CartController cartController) {
//   // In a real app, you would get this from your menu data
//   // For this example, we'll use placeholder values
//   Map<String, String> categories = {};
  
//   cartController.itemQuantities.keys.forEach((itemName) {
//     categories[itemName] = "Main"; // Default to Main for example
//   });
  
//   cartController.itemOrderGroups.keys.forEach((itemName) {
//     categories[itemName] = "Main"; // Default to Main for example
//   });
  
//   return categories;
// }

// Update the _buildItemFoodCategories method to use the stored values (around line 595)
Map<String, String> _buildItemFoodCategories(CartController cartController) {
  Map<String, String> categories = {};
  
  for (var itemName in cartController.itemQuantities.keys) {
    categories[itemName] = cartController.getItemCategory(itemName);
  }
  
  for (var itemName in cartController.itemOrderGroups.keys) {
    categories[itemName] = cartController.getItemCategory(itemName);
  }
  
  return categories;
}


// Map<String, double> _buildItemPrices(CartController cartController) {
//   // In a real app, you would get this from your menu data
//   // For this example, we'll use placeholder values
//   Map<String, double> prices = {};
  
//   cartController.itemQuantities.keys.forEach((itemName) {
//     prices[itemName] = 100.0; // Default price for example
//   });
  
//   cartController.itemOrderGroups.keys.forEach((itemName) {
//     prices[itemName] = 100.0; // Default price for example
//   });
  
//   return prices;
// }


// Update the _buildItemPrices method to use the stored values (around line 607)
Map<String, double> _buildItemPrices(CartController cartController) {
  Map<String, double> prices = {};
  
  for (var itemName in cartController.itemQuantities.keys) {
    prices[itemName] = cartController.getItemPrice(itemName);
  }
  
  for (var itemName in cartController.itemOrderGroups.keys) {
    prices[itemName] = cartController.getItemPrice(itemName);
  }
  
  return prices;
}



// Add this helper method to build the item sizes map

Map<String, double> _buildItemDiscountedPrices(CartController cartController) {
  // In a real app, you would get this from your menu data
  // For this example, we'll use placeholder values for items with discounts
  Map<String, double> discountedPrices = {};
  
  // You would populate this with actual discounted prices
  // For now, we'll leave it empty as it's optional
  
  return discountedPrices;
}

Map<String, Map<String, dynamic>> _buildItemSizes(CartController cartController) {
  Map<String, Map<String, dynamic>> sizes = {};
  
  // Add sizes for customized items
  cartController.itemOrderGroups.forEach((itemName, groups) {
    // For multiple groups of the same item, use the first non-empty size
    // (Backend doesn't support multiple sizes for the same item name)
    
    for (var group in groups) {
      if (group['isGetItem'] == true) continue;
      
      if (group['has_size'] == true && 
          group['selectedSize'] != null && 
          group['selectedSize'].toString().isNotEmpty) {
        
        // Get size name and price increment
        String sizeName = group['selectedSize'] as String? ?? '';
        double sizePriceIncrement = group['sizePriceIncrement'] as double? ?? 0.0;
        
        if (sizeName.isNotEmpty && !sizes.containsKey(itemName)) {
          // Store as dictionary with size_name and price
          sizes[itemName] = {
            "size_name": sizeName,
            "price": sizePriceIncrement
          };
        }
      }
    }
  });
  
  return sizes;
}

Map<String, List<Map<String, dynamic>>> _buildItemAddons(CartController cartController) {
  Map<String, List<Map<String, dynamic>>> addons = {};
  
  // Process customized items to extract addon information
  cartController.itemOrderGroups.forEach((itemName, groups) {
    List<Map<String, dynamic>> itemAddons = [];
    
    for (var group in groups) {
      if (group['isGetItem'] == true) continue;
      
      final Map<String, dynamic>? selectedAddons = 
          group['selectedAddons'] as Map<String, dynamic>?;
      
      if (selectedAddons != null && selectedAddons.isNotEmpty) {
        selectedAddons.forEach((addonName, addonInfo) {
          // The addon info structure might vary based on your implementation
          // Adapting to the expected format
          itemAddons.add({
            "addon_item_name": addonName,
            "quantity": 1, // Default to 1 if quantity not specified
          });
        });
      }
    }
    
    if (itemAddons.isNotEmpty) {
      addons[itemName] = itemAddons;
    }
  });
  
  return addons;
}

List<Map<String, dynamic>> _buildPromotions(PromotionController promotionController) {
  List<Map<String, dynamic>> promotions = [];
  
  // Extract promotion information from the promotion controller
  promotionController.getItemInfoMap.forEach((key, info) {
    if (info.currentQuantity > 0) {
      promotions.add({
        "buy_item_name": info.buyItemName,
        "get_item_name": info.name,
        "buy_quantity": info.buyQuantity,
        "get_quantity": info.currentQuantity,
        "discounted_price": info.discountedPrice
      });
    }
  });
  
  return promotions;
}

  List<Map<String, dynamic>> _buildOrderItems(
      CartController cartController, PromotionController promotionController) {
    List<Map<String, dynamic>> items = [];

    // Regular items
    cartController.itemQuantities.forEach((itemName, quantity) {
      // Skip items with customization groups
      if (cartController.itemOrderGroups.containsKey(itemName)) return;

      items.add({
        'name': itemName,
        'quantity': quantity,
        'customization': cartController.itemCustomizations[itemName] ?? '',
        'is_promotional': false,
      });
    });

    // Customized items
    cartController.itemOrderGroups.forEach((itemName, groups) {
      for (var group in groups) {
        if (group['isGetItem'] == true) continue;

        items.add({
          'name': itemName,
          'quantity': group['quantity'] as int? ?? 0,
          'customization': group['customization'] as String? ?? '',
          'add_ons': group['selectedAddons'] ?? {},
          'size': group['selectedSize'] ?? '',
          'is_promotional': false,
        });
      }
    });

    // Promotional items
    promotionController.getItemInfoMap.forEach((key, info) {
      if (info.currentQuantity > 0) {
        items.add({
          'name': info.name,
          'quantity': info.currentQuantity,
          'original_price': info.originalPrice,
          'discounted_price': info.discountedPrice,
          'promotional_source': info.buyItemName,
          'is_promotional': true,
        });
      }
    });

    return items;
  }
}
