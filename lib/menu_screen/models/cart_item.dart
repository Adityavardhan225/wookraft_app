class CartItem {
  final String itemName;
  int quantity;
  String customization;
  Map<String, bool> addonSelections;
  double addonsTotal;
  Map<String, Map<String, dynamic>>? selectedAddons;
  bool isGetItem;
  bool hasSize;
  String selectedSize;
  double sizePriceIncrement;
  double? totalUnitPrice;
  String? promotionalSource;  // For "get" items, references the "buy" item

  CartItem({
    required this.itemName,
    this.quantity = 1,
    this.customization = '',
    Map<String, bool>? addonSelections,
    this.addonsTotal = 0.0,
    this.selectedAddons,
    this.isGetItem = false,
    this.hasSize = false,
    this.selectedSize = '',
    this.sizePriceIncrement = 0.0,
    this.totalUnitPrice,
    this.promotionalSource,
  }) : addonSelections = addonSelections ?? {};

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemName: json['itemName'],
      quantity: json['quantity'] ?? 1,
      customization: json['customization'] ?? '',
      addonSelections: Map<String, bool>.from(json['addonSelections'] ?? {}),
      addonsTotal: (json['addonsTotal'] as num?)?.toDouble() ?? 0.0,
      selectedAddons: json['selectedAddons'] != null 
          ? Map<String, Map<String, dynamic>>.from(json['selectedAddons'])
          : null,
      isGetItem: json['isGetItem'] ?? false,
      hasSize: json['has_size'] ?? false,
      selectedSize: json['selectedSize'] ?? '',
      sizePriceIncrement: (json['sizePriceIncrement'] as num?)?.toDouble() ?? 0.0,
      totalUnitPrice: (json['totalUnitPrice'] as num?)?.toDouble(),
      promotionalSource: json['promotionalSource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'customization': customization,
      'addonSelections': addonSelections,
      'addonsTotal': addonsTotal,
      'selectedAddons': selectedAddons,
      'isGetItem': isGetItem,
      'has_size': hasSize,
      'selectedSize': selectedSize,
      'sizePriceIncrement': sizePriceIncrement,
      'totalUnitPrice': totalUnitPrice,
      'promotionalSource': promotionalSource,
    };
  }

  // Helper method to get addon details as readable text
  String get addonsText {
    if (selectedAddons == null || selectedAddons!.isEmpty) return '';
    
    return selectedAddons!.keys
        .map((key) => key)
        .join(', ');
  }

  // Helper method to create a unique identifier for this cart item
  // This is useful when an item may appear multiple times with different customizations
  String get uniqueId {
    if (isGetItem && promotionalSource != null) {
      return '${itemName}_$promotionalSource#promo';
    } else if (addonSelections.isNotEmpty || hasSize) {
      return '$itemName#${DateTime.now().millisecondsSinceEpoch}';
    }
    return itemName;
  }
  
  // Calculate total price for this cart item
  double calculateTotalPrice(double basePrice, double discountedPrice) {
    double itemBasePrice = isGetItem ? discountedPrice : basePrice;
    return (itemBasePrice + addonsTotal + sizePriceIncrement) * quantity;
  }
}