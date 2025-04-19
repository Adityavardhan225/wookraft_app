
class MenuItem {
  final String name;
  final double price;
  final double? discountedPrice;
  final String? description;
  final String foodType;
  final String category;
  final dynamic addon;
  final List<dynamic>? sizes;
  final Map<String, dynamic>? discountRules;
  final String? imageUrl;

  MenuItem({
    required this.name,
    required this.price,
    this.discountedPrice,
    this.description,
    required this.foodType,
    required this.category,
    this.addon,
    this.sizes,
    this.discountRules,
    this.imageUrl,
  });
  

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    print('json data $json');
    return MenuItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null 
          ? (json['discounted_price'] as num).toDouble() 
          : null,
      description: json['description'],
      foodType: json['food_type'] ?? '',
      category: json['category'] ?? '',
      addon: json['addon'],
      sizes: json['sizes'] as List<dynamic>?,
      discountRules: json['discount_rules'] as Map<String, dynamic>?,
      imageUrl: json['image_url'],
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'discounted_price': discountedPrice,
    'description': description,
    'food_type': foodType,
    'category': category,
    'addon': addon,
    'sizes': sizes,
    'discount_rules': discountRules,
    'image_url': imageUrl,
  };

  // Helper getters
  bool get hasAddons => addon != null;
  bool get hasSizes => sizes != null && sizes!.isNotEmpty;
  
  bool get hasDiscounts => discountRules != null && 
      (discountRules!['type'] == 'percentage' ||
       discountRules!['type'] == 'value' ||
       discountRules!['type'] == 'buy_x_get_y');
  
  bool get needsCustomization => hasAddons || hasSizes || hasDiscounts;
  
  double get effectivePrice => discountedPrice ?? price;

  String getBuyXGetYMessage() {
    if (discountRules != null && discountRules!['type'] == 'buy_x_get_y') {
      final buyQuantity = discountRules!['buy_quantity'];
      final getQuantity = discountRules!['get_quantity'];
      final freeQuantity = getQuantity - buyQuantity;
      return 'Buy $buyQuantity Get $freeQuantity Free';
    }
    return '';
  }
}