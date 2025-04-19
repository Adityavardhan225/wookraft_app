import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'promotion_controller.dart';

class CartController extends ChangeNotifier {
  // Cart data
  Map<String, int> itemQuantities = {};
  Map<String, String> itemCustomizations = {};
  Map<String, String> itemFoodTypes = {};
  Map<String, String> itemFoodCategories = {};
  Map<String, double> itemPrices = {};
  
  // Complex items with add-ons, sizes, etc.
  Map<String, List<Map<String, dynamic>>> itemOrderGroups = {};
  
  // Reference to the promotion controller for coordination
  final PromotionController _promotionController;
  
  CartController(this._promotionController) {
    _loadCartData();
  }
  
  // Load saved cart data from storage
  Future<void> _loadCartData() async {
    itemQuantities = await StorageService.getItemQuantities();
    itemCustomizations = await StorageService.getItemCustomizations();
    itemOrderGroups = await StorageService.getOrderGroups();

      itemFoodTypes = await StorageService.getItemFoodTypes();
  itemFoodCategories = await StorageService.getItemFoodCategories();
  itemPrices = await StorageService.getItemPrices();
    
    // After loading cart data, update the promotional item quantities
    _updateAllPromotionalItems();
    
    notifyListeners();
  }
  
  // Save cart data to storage
  Future<void> _saveCartData() async {
    await StorageService.saveItemQuantities(itemQuantities);
    print('saving item customizations $itemQuantities');
    await StorageService.saveItemCustomizations(itemCustomizations);
    await StorageService.saveOrderGroups(itemOrderGroups);

      await StorageService.saveItemFoodTypes(itemFoodTypes);
  await StorageService.saveItemFoodCategories(itemFoodCategories);
  await StorageService.saveItemPrices(itemPrices);

  }
  
  // Get total quantity for an item
  int getTotalQuantity(String itemName) {
    int total = 0;
    
    // Add quantity from simple items
    total += itemQuantities[itemName] ?? 0;
    print('123 total quantity for $itemName: $total');
    // Add quantities from item groups (customizations)
    // if (itemOrderGroups.containsKey(itemName)) {
    //   for (var group in itemOrderGroups[itemName]!) {
    //     if (!(group['isGetItem'] ?? false)) {
    //       total += (group['quantity'] as int? ?? 0);
    //     }
    //   }
    // }
    
    return total;
  }
  
  // Increment quantity for a simple item
  void incrementQuantity(String itemName) {
    final currentQty = itemQuantities[itemName] ?? 0;
    itemQuantities[itemName] = currentQty + 1;
    
    // Update promotional items
    _promotionController.updateGetItemInfo(itemName, currentQty + 1);
    
    _saveCartData();
    notifyListeners();
  }
  
  // Decrement quantity for a simple item
  Future<void> decrementQuantity(String itemName, BuildContext context) async {
    final currentQty = itemQuantities[itemName] ?? 0;
    if (currentQty <= 0) return;
    
    // Check if reducing quantity affects promotional items
    bool shouldProceed = await _promotionController.updateGetQuantities(context, itemName, currentQty - 1);
    if (!shouldProceed) return;
    
    if (currentQty - 1 <= 0) {
      itemQuantities.remove(itemName);
      itemCustomizations.remove(itemName);
    } else {
      itemQuantities[itemName] = currentQty - 1;
    }
    
    _saveCartData();
    notifyListeners();
  }

  bool hasExistingCustomizations(String itemName) {

      // Check if the item has any customization groups
  if (itemOrderGroups.containsKey(itemName) && itemOrderGroups[itemName]!.isNotEmpty) {
    // Check if there are any non-empty customization groups
    return itemOrderGroups[itemName]!.any((group) => 
        (group['quantity'] as int? ?? 0) > 0);
  }


  return itemOrderGroups.containsKey(itemName) && 
         itemOrderGroups[itemName] != null &&
         itemOrderGroups[itemName]!.isNotEmpty;
}
  
  // Set quantity for an item with confirmation if needed
  Future<void> setQuantity(String itemName, int newQuantity, BuildContext context) async {
    final currentQty = itemQuantities[itemName] ?? 0;
    
    // Don't proceed if quantity is unchanged
    if (currentQty == newQuantity) return;
    
    // For decrements, check promotional impacts
    if (newQuantity < currentQty) {
      bool shouldProceed = await _promotionController.updateGetQuantities(context, itemName, newQuantity);
      if (!shouldProceed) return;
    }
    
    if (newQuantity <= 0) {
      itemQuantities.remove(itemName);
      itemCustomizations.remove(itemName);
    } else {
      itemQuantities[itemName] = newQuantity;
    }
    
    // Update promotional items
    _promotionController.updateGetItemInfo(itemName, newQuantity);
    
    _saveCartData();
    notifyListeners();
  }
  
  // Add customization for an item
  void addCustomization(String itemName, String customization) {
    itemCustomizations[itemName] = customization;
    _saveCartData();
    notifyListeners();
  }
  
  // Add a customized item to the order groups
  void addCustomizedItem({
    required String itemName, 
    required int quantity,
    required Map<String, bool> addonSelections,
    required String customization,
    required double addonsTotal,
    Map<String, Map<String, dynamic>>? selectedAddons,
    bool hasSize = false,
    String selectedSize = '',
    double sizePriceIncrement = 0.0,
      bool skipPromotionUpdate = false, 
        Map<String, int>? getItems,
  }) {
    // Ensure there's an entry for this item
    if (!itemOrderGroups.containsKey(itemName)) {
      itemOrderGroups[itemName] = [];
    }
    
    // Create customization data
    Map<String, dynamic> customizationData = {
      'quantity': quantity,
      'addonSelections': Map<String, bool>.from(addonSelections),
      'customization': customization,
      'addonsTotal': addonsTotal,
      'selectedAddons': selectedAddons ?? {},
      'isGetItem': false,
      'has_size': hasSize,
      'selectedSize': selectedSize,
      'sizePriceIncrement': sizePriceIncrement,
      'getItems': getItems ?? {},
    };
    print('quantity for customization $quantity');
    
    // Add to order groups
    itemOrderGroups[itemName]!.add(customizationData);
    
    // Update total quantity in itemQuantities for consistency
    _syncQuantities(itemName, skipPromotionUpdate);
    
    _saveCartData();
    notifyListeners();
  }
  




  // Add this method to CartController
Future<void> refreshAllStoreData() async {
  // Clear cart data
  itemQuantities.clear();
  itemCustomizations.clear();
  itemOrderGroups.clear();
    itemFoodTypes.clear();
  itemFoodCategories.clear();
  itemPrices.clear();
  
  // Clear promotional data
  _promotionController.resetAllGetItems();
  
  // Clear all stored data in local storage
  await StorageService.clearAllData();
  
  print('All store data has been refreshed');
  _saveCartData();
  notifyListeners();
}





  // Update an existing customized item
  void updateCustomizedItem({
    required String itemName,
    required int groupIndex,
    required int quantity,
    required Map<String, bool> addonSelections,
    required String customization,
    required double addonsTotal,
    Map<String, Map<String, dynamic>>? selectedAddons,
    bool hasSize = false,
    String selectedSize = '',
    double sizePriceIncrement = 0.0,
    bool skipPromotionUpdate = false, 
     Map<String, int>? getItems, 
  }) {
    // Ensure the item and group exist
    if (!itemOrderGroups.containsKey(itemName) || 
        groupIndex >= itemOrderGroups[itemName]!.length) {
      return;
    }
    
    // Update customization data
    itemOrderGroups[itemName]![groupIndex] = {
      'quantity': quantity,
      'addonSelections': Map<String, bool>.from(addonSelections),
      'customization': customization,
      'addonsTotal': addonsTotal,
      'selectedAddons': selectedAddons ?? {},
      'isGetItem': false,
      'has_size': hasSize,
      'selectedSize': selectedSize,
      'sizePriceIncrement': sizePriceIncrement,
      'getItems': getItems ?? {}, 
    };
    
    // Update total quantity in itemQuantities for consistency
    _syncQuantities(itemName);
    
    _saveCartData();
    notifyListeners();
  }
  
  // Remove a customized item
  // void removeCustomizedItem(String itemName, int groupIndex) {
  //   if (!itemOrderGroups.containsKey(itemName) ||
  //       groupIndex >= itemOrderGroups[itemName]!.length) {
  //     return;
  //   }
    
  //   itemOrderGroups[itemName]!.removeAt(groupIndex);
    
  //   // If no more customizations, remove the item entry
  //   if (itemOrderGroups[itemName]!.isEmpty) {
  //     itemOrderGroups.remove(itemName);
  //   }
    
  //   // Update total quantity
  //   _syncQuantities(itemName);
    
  //   _saveCartData();
  //   notifyListeners();
  // }




// void removeCustomizedItem(String itemName, int groupIndex) {
//   if (!itemOrderGroups.containsKey(itemName) ||
//       groupIndex >= itemOrderGroups[itemName]!.length) {
//     return;
//   }
  
//   print("🛒 Removing customization for $itemName at index $groupIndex");
  
//   // Remove the customization first to update total quantities
//   itemOrderGroups[itemName]!.removeAt(groupIndex);
  
//   // If no more customizations, remove the item completely
//   if (itemOrderGroups[itemName]!.isEmpty) {
//     itemOrderGroups.remove(itemName);
//     itemQuantities.remove(itemName);
//     itemCustomizations.remove(itemName);
    
//     // Reset all promotions for this item since quantity is zero
//     final promotionController = PromotionController();
//     promotionController.updateGetItemInfo(itemName, 0);
//     print("🛒 Removed item $itemName completely (no customizations left)");
//   } else {
//     // Update total quantity and recalculate it
//     _syncQuantities(itemName, true); // Skip interim promotion update
    
//     // Get new total quantity after removal
//     int newTotalQuantity = getTotalQuantity(itemName);
//     print("🛒 New total quantity for $itemName: $newTotalQuantity");
    
//     // Update all get items for this buy item to their maximum allowed values
//     final promotionController = PromotionController();
    
//     // Use updateGetItemInfo to update all get items based on the new quantity
//     promotionController.updateGetItemInfo(itemName, newTotalQuantity);
//     print("🛒 Updated all get items based on new quantity: $newTotalQuantity");
//   }
  
//   _saveCartData();
//   notifyListeners();
// }
  






// void removeCustomizedItem(String itemName, int groupIndex) {
//   if (!itemOrderGroups.containsKey(itemName) ||
//       groupIndex >= itemOrderGroups[itemName]!.length) {
//     return;
//   }
  
//   print("🛒 Processing removal for $itemName at index $groupIndex");
  
//   // Calculate what the new quantity will be AFTER removal
//   int currentQuantity = getTotalQuantity(itemName);
//   int removedQuantity = itemOrderGroups[itemName]![groupIndex]['quantity'] as int? ?? 0;
//   int newTotalQuantity = currentQuantity - removedQuantity;
//   print("🛒 After removal, quantity will change from $currentQuantity to $newTotalQuantity $itemOrderGroups fg");
  
//   // Now remove the customization
//   itemOrderGroups[itemName]!.removeAt(groupIndex);
  
//   // If this was the last customization or new quantity is zero
//   if (itemOrderGroups[itemName]!.isEmpty || newTotalQuantity <= 0) {
//     itemOrderGroups.remove(itemName);
//     itemQuantities.remove(itemName);
//     itemCustomizations.remove(itemName);
//   } else {
//     // Update quantities
//     _syncQuantities(itemName, true); // Skip promotion update
//   }
  
//   _saveCartData();
//   notifyListeners();
// }


void removeCustomizedItem(String itemName, int groupIndex) {
  if (!itemOrderGroups.containsKey(itemName) ||
      groupIndex >= itemOrderGroups[itemName]!.length) {
    return;
  }
  
  print("🛒 Processing removal for $itemName at index $groupIndex");
  
  // Calculate what the new quantity will be AFTER removal
  int currentQuantity = getTotalQuantity(itemName);
  int removedQuantity = itemOrderGroups[itemName]![groupIndex]['quantity'] as int? ?? 0;
  int newTotalQuantity = currentQuantity - removedQuantity;
  print("🛒 After removal, quantity will change from $currentQuantity to $newTotalQuantity");
  
  // FIRST: Update promotion controller BEFORE removing anything
  if (newTotalQuantity <= 0) {
    // If the item will be completely removed, set all get item quantities to zero
    _promotionController.updateGetItemInfo(itemName, 0);
    print("🛒 Reset all get items for item $itemName that will be removed");
  } else {
    // Update get item quantities based on what the new total quantity will be
    _promotionController.updateGetItemInfo(itemName, newTotalQuantity);
    print("🛒 Updated get items for $itemName with future quantity: $newTotalQuantity");
  }
  
  // SECOND: Now remove the customization
  itemOrderGroups[itemName]!.removeAt(groupIndex);
  
  // THIRD: Clean up if needed
  if (itemOrderGroups[itemName]!.isEmpty || newTotalQuantity <= 0) {
    itemOrderGroups.remove(itemName);
    itemQuantities.remove(itemName);
    itemCustomizations.remove(itemName);
  } else {
    // Update quantities
    _syncQuantities(itemName, true); // Skip promotion update since we already did it
  }
  
  _saveCartData();
  notifyListeners();
}




  // Add this method to your CartController class
void adjustItemQuantity(String itemName, int groupIndex, int newQuantity) {
  // If the new quantity is zero, remove the customization entirely
  if (newQuantity <= 0) {
    removeCustomization(itemName, groupIndex);
    return;
  }
  
  // Otherwise, update the quantity
  if (itemOrderGroups.containsKey(itemName) && 
      groupIndex < itemOrderGroups[itemName]!.length) {
    itemOrderGroups[itemName]![groupIndex]['quantity'] = newQuantity;
    _syncQuantities(itemName);
    _saveCartData();
    notifyListeners();
  }
}

// Add this method to remove a specific customization
// void removeCustomization(String itemName, int groupIndex) {
//   if (itemOrderGroups.containsKey(itemName) && 
//       groupIndex < itemOrderGroups[itemName]!.length) {
    
//     // Get the customization before removing it
//     final customization = itemOrderGroups[itemName]![groupIndex];
    
//     // Remove this customization from the group
//     itemOrderGroups[itemName]!.removeAt(groupIndex);
    
//     // If there are no more customizations for this item, remove the entry
//     if (itemOrderGroups[itemName]!.isEmpty) {
//       itemOrderGroups.remove(itemName);
//     }
    
//     // Update the promotion controller to adjust get item quantities
//     if (customization['getItems'] != null && customization['getItems'] is Map) {
//       final getItems = customization['getItems'] as Map;
//       getItems.forEach((getItemName, quantity) {
//         if (quantity > 0) {
//           // Reset these get items in the promotion controller
//           final promotionController = PromotionController();
//           promotionController.updateGetItemQuantity(getItemName.toString(), itemName, 0);
//         }
//       });
//     }
    
//     _syncQuantities(itemName);
//     _saveCartData();
//     notifyListeners();
//   }
// }



// void removeCustomization(String itemName, int groupIndex) {
//   // Check if the item and group exist
//   if (!itemOrderGroups.containsKey(itemName) || 
//       groupIndex >= itemOrderGroups[itemName]!.length) {
//     return;
//   }
  
//   // Save the customization for promotion cleanup
//   final customization = itemOrderGroups[itemName]![groupIndex];
  
//   // Remove this customization from the group
//   itemOrderGroups[itemName]!.removeAt(groupIndex);
  
//   // If there are no more customizations for this item, remove the item completely
//   if (itemOrderGroups[itemName]!.isEmpty) {
//     itemOrderGroups.remove(itemName);
    
//     // Also clear any stored customization text if present
//     itemCustomizations.remove(itemName);
    
//     // Clear item quantity as well
//     itemQuantities.remove(itemName);
//   }
  
//   // Update promotion controller for any get items in this customization
//   if (customization['getItems'] != null && customization['getItems'] is Map) {
//     final getItems = customization['getItems'] as Map;
//     getItems.forEach((getItemName, quantity) {
//       if (quantity > 0) {
//         final promotionController = PromotionController();
//         promotionController.updateGetItemQuantity(getItemName.toString(), itemName, 0);
//       }
//     });
//   }
  
//   _syncQuantities(itemName);
//   _saveCartData();
//   notifyListeners();
// }




void removeCustomization(String itemName, int groupIndex) {
  // Check if the item and group exist
  if (!itemOrderGroups.containsKey(itemName) || 
      groupIndex >= itemOrderGroups[itemName]!.length) {
    return;
  }
  
  // Store the quantity being removed for later adjustment
  final removedQuantity = itemOrderGroups[itemName]![groupIndex]['quantity'] as int? ?? 0;
  
  // Save the customization for promotion cleanup
  final customization = itemOrderGroups[itemName]![groupIndex];
  
  // Remove this customization from the group
  itemOrderGroups[itemName]!.removeAt(groupIndex);
  
  // If there are no more customizations for this item, remove the item completely
  if (itemOrderGroups[itemName]!.isEmpty) {
    itemOrderGroups.remove(itemName);
    
    // Also remove from itemQuantities if this was the last customization
    if (itemQuantities.containsKey(itemName)) {
      itemQuantities.remove(itemName);
    }
    
    // Remove any stored customization text
    itemCustomizations.remove(itemName);
    
    // Explicitly update promotion controller with zero quantity for the removed item
    final promotionController = PromotionController();
    promotionController.updateGetItemInfo(itemName, 0);
  } else {
    // Otherwise, update the total quantity to reflect the removed customization
    if (itemQuantities.containsKey(itemName)) {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) - removedQuantity;
      
      // Remove the item completely if quantity becomes zero or negative
      if (itemQuantities[itemName]! <= 0) {
        itemQuantities.remove(itemName);
        itemCustomizations.remove(itemName);
        itemOrderGroups.remove(itemName);
        
        // Explicitly update promotion controller with zero quantity
        final promotionController = PromotionController();
        promotionController.updateGetItemInfo(itemName, 0);
      } else {
        // Only sync quantities if the item still exists
        _syncQuantities(itemName);
      }
    }
  }
  
  // Update promotion controller for any get items in this customization
  if (customization['getItems'] != null && customization['getItems'] is Map) {
    final getItems = customization['getItems'] as Map;
    getItems.forEach((getItemName, quantity) {
      if (quantity > 0) {
        final promotionController = PromotionController();
        promotionController.updateGetItemQuantity(getItemName.toString(), itemName, 0);
      }
    });
  }
  
  _saveCartData();
  notifyListeners();
  
  print("🛒 Removed customization for $itemName at index $groupIndex, remaining: ${itemOrderGroups[itemName]?.length ?? 0}");
}


  
  // Clear the entire cart
  void clearCart() {
    itemQuantities.clear();
    itemCustomizations.clear();
    itemOrderGroups.clear();
      itemFoodTypes.clear();
  itemFoodCategories.clear();
  itemPrices.clear();
    
    _promotionController.resetAllGetItems();
    
    _saveCartData();
    notifyListeners();
  }
  
  // Sync quantities between itemQuantities and itemOrderGroups
  // void _syncQuantities(String itemName, [bool skipPromotionUpdate = false]) {
  //   if (!itemOrderGroups.containsKey(itemName)) {
  //     return;
  //   }
    
  //   int totalQuantity = 0;
  //   for (var group in itemOrderGroups[itemName]!) {
  //     if (!(group['isGetItem'] ?? false)) {
  //       totalQuantity += (group['quantity'] as int? ?? 0);
  //     }
  //   }
  //   print('total quantity for $itemName is $totalQuantity');
    
  //   if (totalQuantity > 0) {
  //     itemQuantities[itemName] = totalQuantity;
  //   if (!skipPromotionUpdate) {
  //     _promotionController.updateGetItemInfo(itemName, totalQuantity);
  //   }
  // } else {
  //   itemQuantities.remove(itemName);
  // }
  // }




  // Update _syncQuantities to ensure it properly handles removal cases
void _syncQuantities(String itemName, [bool skipPromotionUpdate = false]) {
  // If the item has no customization groups, nothing to sync
  if (!itemOrderGroups.containsKey(itemName) || itemOrderGroups[itemName]!.isEmpty) {
    return;
  }

  // Calculate total quantity from all customization groups
  int total = 0;
  for (var group in itemOrderGroups[itemName]!) {
    total += group['quantity'] as int? ?? 0;
  }

  // Update the main quantity count
  if (total > 0) {
    itemQuantities[itemName] = total;
  } else {
    // If total is zero, remove the item completely
    itemQuantities.remove(itemName);
    itemCustomizations.remove(itemName);
    itemOrderGroups.remove(itemName);
  }

  // Update promotional items if needed
  if (!skipPromotionUpdate) {
    final promotionController = PromotionController();
    promotionController.updateGetItemInfo(itemName, total);
  }
}
  
  // Update all promotional items based on current quantities
  void _updateAllPromotionalItems() {
    itemQuantities.forEach((itemName, quantity) {
      _promotionController.updateGetItemInfo(itemName, quantity);
    });
  }


  String getItemFoodType(String itemName) {
  return itemFoodTypes[itemName] ?? 'Veg'; // Default to Veg if not found
}

String getItemCategory(String itemName) {
  return itemFoodCategories[itemName] ?? 'Main'; // Default to Main if not found
}

double getItemPrice(String itemName) {
  return itemPrices[itemName] ?? 0.0; // Default to 0.0 if not found
}
  
  // Check if the cart is empty
  bool get isEmpty => 
      itemQuantities.isEmpty && 
      itemOrderGroups.isEmpty &&
      _promotionController.getItemInfoMap.values.every((info) => info.currentQuantity <= 0);
  
  // Get total number of items in cart
  int get totalItemCount {
    int count = 0;
    
    // Count regular items
    itemQuantities.forEach((key, value) {
      count += value;
    });
    
    // Count promotional items
    _promotionController.getItemInfoMap.forEach((key, info) {
      if (info.currentQuantity > 0) {
        count += info.currentQuantity;
      }
    });
    
    return count;
  }
}



// Add this method to your CartController class





