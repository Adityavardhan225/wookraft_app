import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/get_item_info.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PromotionController extends ChangeNotifier {
  // Map to track promotional items
  Map<String, GetItemInfo> getItemInfoMap = {};


    // Add this new cache field
  final Map<String, List<GetItemInfo>> _getItemsCache = {};
  
  PromotionController() {
    print("🎁 Initializing PromotionController");
    _loadPromotionalData();
  }
  
  // Load promotional data from storage
  Future<void> _loadPromotionalData() async {
    print("🎁 Loading promotional data from storage");
    getItemInfoMap = await StorageService.getGetItemInfo();
    print("🎁 Loaded ${getItemInfoMap.length} promotional items $getItemInfoMap");
    notifyListeners();
  }
  
  // Save promotional data to storage
  Future<void> _savePromotionalData() async {
    print("🎁 Saving ${getItemInfoMap.length} promotional items to storage");
    await StorageService.saveGetItemInfo(getItemInfoMap);
  }

  
  // Add the new method here, between your existing methods
  
  // Method to fetch and cache get items
  Future<List<GetItemInfo>> getDiscountedItems(String buyItemName) async {
    print("🎁 Fetching discounted items for $buyItemName");
    
    // Return from cache if available
    String cacheKey = buyItemName;
    if (_getItemsCache.containsKey(cacheKey)) {
      print("🎁 Returning ${_getItemsCache[cacheKey]!.length} items from cache for $buyItemName");
      return _getItemsCache[cacheKey]!;
    }
    
    try {
      // Fetch from API
      print("🎁 Cache miss for $buyItemName, fetching from API");
      final discountData = await ApiService.getDiscountedItems(buyItemName);
      List<GetItemInfo> resultItems = [];
      
      if (discountData['details'] != null && 
          discountData['details'].isNotEmpty) {
        
        final details = discountData['details'];
        print("🎁 Found ${details.length} discounted items for $buyItemName");
        
        // Process each get item
        for (var detail in details) {
          if (detail == null) continue;
          
          final getItemName = detail['name'];
          final compositeKey = '${buyItemName}_$getItemName';
          
          // Create GetItemInfo object and add to results
          GetItemInfo itemInfo = GetItemInfo.fromJson(detail, buyItemName);
          resultItems.add(itemInfo);
          
          // Also update the main map
          getItemInfoMap[compositeKey] = itemInfo;
          print("🎁 Added get item: $getItemName for $buyItemName");
        }
        
        // Cache the results
        _getItemsCache[cacheKey] = resultItems;
        print("🎁 Cached ${resultItems.length} items for $buyItemName");
        
        // Save to persistent storage
        _savePromotionalData();
      } else {
        print("🎁 No discounted items found for $buyItemName");
        _getItemsCache[cacheKey] = []; // Cache empty results too
      }
      
      return resultItems;
    } catch (e) {
      print("🎁 Error fetching discounted items: $e");
      return [];
    }
  }

  // Add this utility method too
  Future<bool> hasGetItems(String buyItemName) async {
    final items = await getDiscountedItems(buyItemName);
    return items.isNotEmpty;
  }
  

  
  // Initialize Get Item information for a promotion
  Future<void> initializeGetItemInfo(List<dynamic> details, String buyItemName) async {
    print("🎁 Initializing get items for $buyItemName with ${details.length} details");
    
    for (var detail in details) {
      if (detail == null) continue;
      
      final getItemName = detail['name'];
      final compositeKey = '${buyItemName}_$getItemName';
       print("🎁 Adding new promo: Buy $buyItemName, Get $getItemName");
      // Only initialize if not already present
      if (!getItemInfoMap.containsKey(compositeKey)) {
        print("🎁 Adding new promo: Buy $buyItemName, Get $getItemName");
        getItemInfoMap[compositeKey] = GetItemInfo.fromJson(detail, buyItemName);
        print("🎁 Details: ${getItemInfoMap[compositeKey].toString()}");
      }
    }
    
    await _savePromotionalData();
    notifyListeners();
  }
  
  // Update quantities of promotional items based on buy item quantity
  void updateGetItemInfo(String buyItemName, int buyQuantity) {
    print("🎁 Updating get items for $buyItemName, quantity: $buyQuantity");
    bool updated = false;
    print("🎁 getItemInfoMap: $getItemInfoMap");
    
    getItemInfoMap.forEach((compositeKey, info) {
      print('info is $info');
      if (info.buyItemName == buyItemName) {

        print('processing item for $compositeKey');

        // Calculate how many "sets" of the promotion are available
        final sets = (buyQuantity / info.buyQuantity).floor();
        // Calculate the resulting number of "get" items
        final int result = sets * info.getQuantity;
        
        print("🎁 For $compositeKey: sets=$sets, result=$result, current=${info.currentQuantity}");
        
        // Only update if there's a change
    //     if (info.currentQuantity != result) {
    //       info.currentQuantity = result;
    //       updated = true;
    //       print("🎁 Updated quantity to $result");
    //     }
    //   }
    // });

      if (info.currentQuantity > result) {
        info.currentQuantity = result;
        updated = true;
        print("🎁 Reduced quantity to maximum allowed: $result");
      }
    }
  });
    
    if (updated) {
      _savePromotionalData();
      notifyListeners();
    }
  }
  
  // Update a specific promotional item's quantity
  void updateGetItemQuantity(String getItemName, String buyItemName, int quantity) {
    final compositeKey = '${buyItemName}_$getItemName';
    final info = getItemInfoMap[compositeKey];
    
    print("🎁 Manual update for $getItemName: setting to $quantity");
    
    if (info != null) {
      // Update this specific get item quantity
      info.currentQuantity = quantity;
      
      // // Reset other get item quantities for this buy item
      // getItemInfoMap.forEach((key, i) {
      //   if (key != compositeKey && i.buyItemName == buyItemName ) {
      //     print("🎁 Resetting quantity for $key to 0");
      //     i.currentQuantity = 0;
      //     print('🎁 Resetting quantity for $key to $i');
      //   }
      // });
      
      _savePromotionalData();
      notifyListeners();
    } else {
      print("🎁 ERROR: Could not find info for $compositeKey");
    }
  }
  
  // Calculate the maximum number of promotional items available
  int calculateMaxGetItems(String buyItemName, String getItemName, int baseQuantity) {
    final compositeKey = '${buyItemName}_$getItemName';
    final info = getItemInfoMap[compositeKey];
    
    if (info == null) {
      print("🎁 No promo info found for $compositeKey");
      return 0;
    }
    
    final sets = (baseQuantity / info.buyQuantity).floor();
    final result = sets * info.getQuantity;
    print("🎁 Max get items for $compositeKey: $result (sets=$sets)");
    return result;
  }
  
  // Reset all promotional item quantities
  void resetAllGetItems() {
    print("🎁 Resetting all get items");
    bool updated = false;
    
    getItemInfoMap.forEach((compositeKey, info) {
      if (info.currentQuantity > 0) {
        info.currentQuantity = 0;
        updated = true;
        print("🎁 Reset $compositeKey to 0");
      }
    });
    
    if (updated) {
      _savePromotionalData();
      notifyListeners();
    }
  }
  
  // Display confirmation dialog when reducing quantities affects promotions
  Future<bool> showQuantityChangeConfirmation(BuildContext context, 
      String buyItemName, int currentQty, int newQty) async {
      
    print("🎁 Showing confirmation dialog for $buyItemName: $currentQty → $newQty");
    
    List<String> affectedItems = [];
    getItemInfoMap.forEach((key, info) {
      if (info.buyItemName == buyItemName && info.currentQuantity > 0) {
        affectedItems.add(info.name);
        print("🎁 Affected item: ${info.name}");
      }
    });
    
    if (affectedItems.isEmpty) {
      print("🎁 No affected items, proceeding");
      return true;
    }
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Quantity Change'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reducing quantity will adjust your selected discounted items:'),
              const SizedBox(height: 8),
              ...affectedItems.map((name) => Text('• $name')),
              const SizedBox(height: 8),
              Text('from $currentQty to $newQty. Do you want to proceed?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                print("🎁 User cancelled quantity change");
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () {
                print("🎁 User confirmed quantity change");
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) {
      print("🎁 Dialog result: $value");
      return value ?? false;
    });
  }
  
  // Update quantities when buy item quantity changes, with confirmation
  Future<bool> updateGetQuantities(BuildContext context, String itemName, int buyQuantity) async {
    print("🎁 Updating quantities for $itemName to $buyQuantity");
    
    bool shouldProceed = true;
    bool needsUpdate = false;

    // Check each promotional item
    for (var entry in getItemInfoMap.entries) {
      final compositeKey = entry.key;
      final info = entry.value;

      if (info.buyItemName == itemName) {
        final sets = (buyQuantity / info.buyQuantity).floor();
        final int result = sets * info.getQuantity;
        
        print("🎁 $compositeKey: new quantity would be $result (current: ${info.currentQuantity})");

        if (result < info.currentQuantity) {
          print("🎁 Need confirmation for $compositeKey: ${info.currentQuantity} → $result");
          shouldProceed = await showQuantityChangeConfirmation(
              context, itemName, info.currentQuantity, result);

          if (shouldProceed) {
            info.currentQuantity = result;
            needsUpdate = true;
            print("🎁 Updated $compositeKey to $result");
          } else {
            print("🎁 User cancelled the update");
            return false;
          }
        }
      }
    }

    if (shouldProceed && needsUpdate) {
      _savePromotionalData();
      notifyListeners();
      print("🎁 Saved updates to storage");
    }

    return shouldProceed;
  }
  
  // Get Buy-X-Get-Y message for a specific promotion
  String getBuyXGetYAtZMessage(String itemName, int baseQuantity,
      String getItemName, List<dynamic> details) {
      
    final compositeKey = '${itemName}_$getItemName';
    final info = getItemInfoMap[compositeKey];
    
    if (info == null) {
      print("🎁 No info found for $compositeKey");
      return '';
    }

    final remainder = baseQuantity % info.buyQuantity;
    final remainingForNext =
        remainder == 0 ? info.buyQuantity : info.buyQuantity - remainder;
        
    print("🎁 Message data: remainder=$remainder, remainingForNext=$remainingForNext");

    if (baseQuantity < info.buyQuantity) {
      final message = 'Buy $remainingForNext more to get ${info.getQuantity} $getItemName at discounted price';
      print("🎁 Message: $message");
      return message;
    } else {
      final message = 'You can get up to ${info.currentQuantity} $getItemName at discounted price\nAdd $remainingForNext more to get additional ${info.getQuantity}';
      print("🎁 Message: $message");
      return message;
    }
  }
  
  // Build promotional messages widget
  Widget buildPromotionalMessages(String itemName) {
    print("🎁 Building promo messages for $itemName");
    List<Widget> messages = [];
    
    getItemInfoMap.forEach((key, info) {
      if (info.buyItemName == itemName && info.currentQuantity > 0) {
        final message = info.getPromotionalMessage(
          getItemInfoMap[key]!.currentQuantity
        );
        
        print("🎁 Adding message for $key: $message");
        
        messages.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.blue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
    });
    
    print("🎁 Total messages: ${messages.length}");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: messages,
    );
  }
}