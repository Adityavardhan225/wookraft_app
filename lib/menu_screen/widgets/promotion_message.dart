import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/promotion_controller.dart';

class PromotionMessages extends StatelessWidget {
  final String itemName;
  
  const PromotionMessages({
    super.key,
    required this.itemName,
  });
  
  @override
  Widget build(BuildContext context) {
    final promotionController = Provider.of<PromotionController>(context);
    List<Widget> messages = [];
    
    // Find all promotional messages related to this item (as a "get" item)
    promotionController.getItemInfoMap.forEach((key, info) {
      if (info.name == itemName && info.currentQuantity > 0) {
        messages.add(
          GestureDetector(
            onTap: () {
              // Navigate to the related "buy" item
              Navigator.pushNamed(
                context,
                '/item_detail',
                arguments: {'itemName': info.buyItemName},
              );
            },
            child: Text(
              'You have purchased ${info.currentQuantity} quantity at ₹${info.discountedPrice} as you have selected ${info.name} in ${info.buyItemName}',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        );
      }
    });
    
    // Find all promotional messages related to this item (as a "buy" item)
    promotionController.getItemInfoMap.forEach((key, info) {
      if (info.buyItemName == itemName) {
        final message = info.getPromotionalMessage(info.buyItemName == itemName ? 
            (Provider.of<PromotionController>(context).getItemInfoMap[key]?.currentQuantity ?? 0) : 0);
        
        if (message.isNotEmpty) {
          messages.add(
            Text(
              message,
              style: const TextStyle(
                color: Colors.blue,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
      }
    });
    
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages,
      ),
    );
  }
}

class PromotionalItemBanner extends StatelessWidget {
  final String itemName;
  final String buyItemName;
  
  const PromotionalItemBanner({
    super.key,
    required this.itemName,
    required this.buyItemName,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Promotional item from $buyItemName offer',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}