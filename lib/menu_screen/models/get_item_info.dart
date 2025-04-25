import 'package:flutter/foundation.dart';

class GetItemInfo {
  final String name;
  final String buyItemName;
  final int buyQuantity;
  final int getQuantity;
  final String foodType;
  final double originalPrice;
  final double discountedPrice;
  final String description;
  final String? imageUrl;
  int currentQuantity;

  GetItemInfo({
    required this.name,
    required this.buyItemName,
    required this.buyQuantity,
    required this.getQuantity,
    required this.foodType,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
    this.imageUrl,
    this.currentQuantity = 0,
  }) {
    print("🔍 GetItemInfo: Created for $name with buyQuantity=$buyQuantity, getQuantity=$getQuantity");
    debugPrint("🔍 DEBUG: GetItemInfo created for $name");
  }

  factory GetItemInfo.fromJson(Map<String, dynamic> json, String buyItemName) {
    print("🔍 GetItemInfo.fromJson: Creating from $json");
    print("🔍 GetItemInfo.fromJson: buyItemName=$buyItemName");
    
    final name = json['name'] ?? '';
    final buyQty = json['buy_item_quantity'] ?? 1;
    final getQty = json['get_item_quantity'] ?? 1;
    final foodType = json['food_type'] ?? '';
    final originalPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final discountedPrice = (json['discounted_price'] as num?)?.toDouble() ?? 0.0;
    final currentQty = json['currentQuantity'] ?? 0;
    
    print("🔍 GetItemInfo.fromJson: name=$name, buyQty=$buyQty, getQty=$getQty, currentQty=$currentQty,, $discountedPrice, $originalPrice");
    
    return GetItemInfo(
      name: name,
      buyItemName: buyItemName,
      buyQuantity: buyQty,
      getQuantity: getQty,
      foodType: foodType,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      description: json['description'] ?? '',
      imageUrl: json['name_image'],
      currentQuantity: currentQty,
    );
  }

  factory GetItemInfo.fromMap(Map<String, dynamic> map) {
    print("🔍 GetItemInfo.fromMap: Creating from $map");
    
    return GetItemInfo(
      name: map['name'] ?? '',
      buyItemName: map['buyItemName'] ?? '',
      buyQuantity: map['buyQuantity'] ?? 1,
      getQuantity: map['getQuantity'] ?? 1,
      foodType: map['foodType'] ?? '',
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (map['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      currentQuantity: map['currentQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    print("🔍 GetItemInfo.toJson: Converting $name to JSON");
    
    final json = {
      'name': name,
      'buyItemName': buyItemName,
      'buyQuantity': buyQuantity,
      'getQuantity': getQuantity,
      'foodType': foodType,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'description': description,
      'imageUrl': imageUrl,
      'currentQuantity': currentQuantity,
    };
    
    print("🔍 GetItemInfo.toJson: Result=$json");
    return json;
  }
  
  // Helper methods
  String get compositeKey => '${buyItemName}_$name';
  
  // Update quantity based on the number of "buy" items
  void updateQuantityBasedOnBuyItem(int buyItemQuantity) {
    print("🔍 updateQuantityBasedOnBuyItem: buyItemQuantity=$buyItemQuantity, buyQuantity=$buyQuantity");
    
    final sets = (buyItemQuantity / buyQuantity).floor();
    final newQuantity = sets * getQuantity;
    print("🔍 updateQuantityBasedOnBuyItem: sets=$sets, oldQuantity=$currentQuantity, newQuantity=$newQuantity");
    
    currentQuantity = newQuantity;
  }
  
  // Get a promotional message to display to the user
  String getPromotionalMessage(int baseQuantity) {
    print("🔍 getPromotionalMessage: baseQuantity=$baseQuantity, buyQuantity=$buyQuantity, currentQuantity=$currentQuantity");
    
    final remainder = baseQuantity % buyQuantity;
    final remainingForNext = remainder == 0 ? buyQuantity : buyQuantity - remainder;

    print("🔍 getPromotionalMessage: remainder=$remainder, remainingForNext=$remainingForNext");

    String message;
    if (baseQuantity < buyQuantity) {
      message = 'Buy $remainingForNext more to get $getQuantity $name at discounted price';
    } else {
      message = 'You can get up to $currentQuantity $name at discounted price\nAdd $remainingForNext more to get additional $getQuantity';
    }
    
    print("🔍 getPromotionalMessage: message=$message");
    return message;
  }
  
  // Add test method to verify printing works
  static void testPrint() {
    print("🔍 STATIC TEST PRINT IN GET_ITEM_INFO");
    debugPrint("🔍 STATIC DEBUG PRINT IN GET_ITEM_INFO");
  }
  
  @override
  String toString() {
    return 'GetItemInfo{name: $name, buyItemName: $buyItemName, buyQuantity: $buyQuantity, getQuantity: $getQuantity, currentQuantity: $currentQuantity}';
  }
}