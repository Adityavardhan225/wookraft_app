import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/promotion_controller.dart';
import 'promotion_message.dart';

class ItemCard extends StatelessWidget {
  final dynamic item;
  final Function(BuildContext, dynamic) onAddItem;
  final Function(String) onCustomize;
  final Function(String) onToggleExpanded;
  final bool isExpanded;
  
  const ItemCard({
    super.key,
    required this.item,
    required this.onAddItem,
    required this.onCustomize,
    required this.onToggleExpanded,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final promotionController = Provider.of<PromotionController>(context);
    
    final String itemName = item['name'];
    final String foodType = item['food_type'];
    final String category = item['category'];
    final String? description = item['description'];
    final double price = item['price'].toDouble();
    
    bool hasDiscount = item['has_discount'] ?? false;
    double discountedPrice = (item['discounted_price'] ?? price).toDouble();
    
    final int totalQuantity = cartController.getTotalQuantity(itemName);
    print('total quantity for $itemName: $totalQuantity');
    final buyXGetYMessage = _getBuyXGetYMessage();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name
            Text(
              itemName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Price section
            Row(
              children: [
                if (discountedPrice < price) ...[
                  Text(
                    '₹$price',
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
                  Text('₹$price'),
                
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
            
            const SizedBox(height: 4),
            
            // Food type and category
            Row(
              children: [
                Text('Food Type: $foodType'),
                const SizedBox(width: 10),
                Text('Category: $category'),
              ],
            ),
            
            // Description with expand/collapse
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 4),
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
                      onTap: () => onToggleExpanded(itemName),
                      child: Text(
                        isExpanded ? 'less' : 'more',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ],
            
            // Promotional messages
            PromotionMessages(itemName: itemName),
            
            // Customization display if any
            if (cartController.itemCustomizations.containsKey(itemName)) ...[
              const SizedBox(height: 4),
              Text(
                'Customization: ${cartController.itemCustomizations[itemName]}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Quantity controls and customize button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: totalQuantity == 0
                    ? ElevatedButton(
                        onPressed: () => onAddItem(context, item),
                        child: const Text('Add'),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => onAddItem(context, item),
                          ),
                          Text('$totalQuantity'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => onAddItem(context, item),
                          ),
                        ],
                      ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onCustomize(itemName),
                  child: const Text('Customize'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Extract the Buy X Get Y message from the item
  String _getBuyXGetYMessage() {
    if (item['discount_rules'] != null && 
        item['discount_rules'] is List && 
        item['discount_rules'].isNotEmpty && 
        item['discount_rules'][0]['type'] == 'buy_x_get_y') {
          
      final buyQuantity = item['discount_rules'][0]['buy_quantity'];
      final getQuantity = item['discount_rules'][0]['get_quantity'];
      final freeQuantity = getQuantity - buyQuantity;
      return 'Buy $buyQuantity Get $freeQuantity Free';
    }
    return '';
  }
}