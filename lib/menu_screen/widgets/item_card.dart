// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/cart_controller.dart';
// import '../controllers/promotion_controller.dart';
// import 'promotion_message.dart';

// class ItemCard extends StatelessWidget {
//   final dynamic item;
//   final Function(BuildContext, dynamic) onAddItem;
//   final Function(String) onCustomize;
//   final Function(String) onToggleExpanded;
//   final bool isExpanded;
  
//   const ItemCard({
//     super.key,
//     required this.item,
//     required this.onAddItem,
//     required this.onCustomize,
//     required this.onToggleExpanded,
//     required this.isExpanded,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cartController = Provider.of<CartController>(context);
//     final promotionController = Provider.of<PromotionController>(context);
    
//     final String itemName = item['name'];
//     final String foodType = item['food_type'];
//     final String category = item['category'];
//     final String? description = item['description'];
//     final double price = item['price'].toDouble();
    
//     bool hasDiscount = item['has_discount'] ?? false;
//     double discountedPrice = (item['discounted_price'] ?? price).toDouble();
    
//     final int totalQuantity = cartController.getTotalQuantity(itemName);
//     print('total quantity for $itemName: $totalQuantity');
//     final buyXGetYMessage = _getBuyXGetYMessage();
    
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Item name
//             Text(
//               itemName,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             // Price section
//             Row(
//               children: [
//                 if (discountedPrice < price) ...[
//                   Text(
//                     '₹$price',
//                     style: const TextStyle(
//                       decoration: TextDecoration.lineThrough,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '₹$discountedPrice',
//                     style: const TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ] else
//                   Text('₹$price'),
                
//                 if (buyXGetYMessage.isNotEmpty) ...[
//                   const SizedBox(width: 8),
//                   Text(
//                     buyXGetYMessage,
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
            
//             const SizedBox(height: 4),
            
//             // Food type and category
//             Row(
//               children: [
//                 Text('Food Type: $foodType'),
//                 const SizedBox(width: 10),
//                 Text('Category: $category'),
//               ],
//             ),
            
//             // Description with expand/collapse
//             if (description != null && description.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isExpanded
//                       ? description
//                       : description.length > 50
//                         ? '${description.substring(0, 50)}...'
//                         : description,
//                   ),
//                   if (description.length > 50)
//                     InkWell(
//                       onTap: () => onToggleExpanded(itemName),
//                       child: Text(
//                         isExpanded ? 'less' : 'more',
//                         style: const TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
            
//             // Promotional messages
//             PromotionMessages(itemName: itemName),
            
//             // Customization display if any
//             if (cartController.itemCustomizations.containsKey(itemName)) ...[
//               const SizedBox(height: 4),
//               Text(
//                 'Customization: ${cartController.itemCustomizations[itemName]}',
//                 style: const TextStyle(fontStyle: FontStyle.italic),
//               ),
//             ],
            
//             const SizedBox(height: 12),
            
//             // Quantity controls and customize button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: totalQuantity == 0
//                     ? ElevatedButton(
//                         onPressed: () => onAddItem(context, item),
//                         child: const Text('Add'),
//                       )
//                     : Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.remove),
//                             onPressed: () => onAddItem(context, item),
//                           ),
//                           Text('$totalQuantity'),
//                           IconButton(
//                             icon: const Icon(Icons.add),
//                             onPressed: () => onAddItem(context, item),
//                           ),
//                         ],
//                       ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () => onCustomize(itemName),
//                   child: const Text('Customize'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Extract the Buy X Get Y message from the item
//   String _getBuyXGetYMessage() {
//     if (item['discount_rules'] != null && 
//         item['discount_rules'] is List && 
//         item['discount_rules'].isNotEmpty && 
//         item['discount_rules'][0]['type'] == 'buy_x_get_y') {
          
//       final buyQuantity = item['discount_rules'][0]['buy_quantity'];
//       final getQuantity = item['discount_rules'][0]['get_quantity'];
//       final freeQuantity = getQuantity - buyQuantity;
//       return 'Buy $buyQuantity Get $freeQuantity Free';
//     }
//     return '';
//   }
// }






























// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/cart_controller.dart';
// import '../controllers/promotion_controller.dart';
// import 'promotion_message.dart';

// class ItemCard extends StatelessWidget {
//   final dynamic item;
//   final Function(BuildContext, dynamic) onAddItem;
//   final Function(String) onCustomize;
//   final Function(String) onToggleExpanded;
//   final bool isExpanded;
  
//   const ItemCard({
//     super.key,
//     required this.item,
//     required this.onAddItem,
//     required this.onCustomize,
//     required this.onToggleExpanded,
//     required this.isExpanded,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cartController = Provider.of<CartController>(context);
//     final promotionController = Provider.of<PromotionController>(context);
    
//     final String itemName = item['name'];
//     final String foodType = item['food_type'];
//     final String category = item['category'];
//     final String? description = item['description'];
//     final double price = item['price'].toDouble();
//     final String imageUrl = item['image_url'] ?? '';
    
//     bool hasDiscount = item['has_discount'] ?? false;
//     double discountedPrice = (item['discounted_price'] ?? price).toDouble();
    
//     final int totalQuantity = cartController.getTotalQuantity(itemName);
//     final buyXGetYMessage = _getBuyXGetYMessage();
    
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // LEFT SIDE - Item details
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Item name and price row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             itemName,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             if (discountedPrice < price)
//                               Text(
//                                 '₹$price',
//                                 style: const TextStyle(
//                                   decoration: TextDecoration.lineThrough,
//                                   color: Colors.grey,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             Text(
//                               '₹$discountedPrice',
//                               style: TextStyle(
//                                 color: discountedPrice < price ? Colors.green : Colors.black87,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 4),
                    
//                     // Buy X Get Y message
//                     if (buyXGetYMessage.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         margin: const EdgeInsets.only(bottom: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(color: Colors.blue.withOpacity(0.3)),
//                         ),
//                         child: Text(
//                           buyXGetYMessage,
//                           style: TextStyle(
//                             color: Colors.blue[700],
//                             fontSize: 11,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
                    
//                     // Category and food type
//                     Wrap(
//                       spacing: 4,
//                       runSpacing: 4,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.orange[50],
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                           child: Text(
//                             foodType,
//                             style: TextStyle(fontSize: 10, color: Colors.orange[800]),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                           child: Text(
//                             category,
//                             style: TextStyle(fontSize: 10, color: Colors.blue[800]),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     // Description with expand/collapse
//                     if (description != null && description.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         isExpanded
//                           ? description
//                           : description.length > 40
//                             ? '${description.substring(0, 40)}...'
//                             : description,
//                         style: TextStyle(
//                           color: Colors.grey[700],
//                           fontSize: 12,
//                         ),
//                         maxLines: isExpanded ? 5 : 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (description.length > 40)
//                         GestureDetector(
//                           onTap: () => onToggleExpanded(itemName),
//                           child: Text(
//                             isExpanded ? 'less' : 'more',
//                             style: const TextStyle(
//                               color: Colors.blue,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                     ],
                    
//                     const Spacer(),
                    
//                     // Quantity controls and customize button
//                     Row(
//                       children: [
//                         // Customize button
//                         TextButton.icon(
//                           onPressed: () => onCustomize(itemName),
//                           icon: const Icon(Icons.tune, size: 14),
//                           label: const Text('Custom', style: TextStyle(fontSize: 12)),
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             minimumSize: Size.zero,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
                        
//                         const Spacer(),
                        
//                         // Quantity controls
//                         totalQuantity == 0
//                           ? ElevatedButton(
//                               onPressed: () => onAddItem(context, item),
//                               child: const Text('Add', style: TextStyle(fontSize: 12)),
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                                 minimumSize: Size.zero,
//                               ),
//                             )
//                           : Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Theme.of(context).primaryColor),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () => onAddItem(context, item),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(4),
//                                       child: Icon(Icons.remove, 
//                                         size: 14, 
//                                         color: Theme.of(context).primaryColor),
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                                     child: Text(
//                                       '$totalQuantity',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () => onAddItem(context, item),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(4),
//                                       child: Icon(Icons.add, 
//                                         size: 14, 
//                                         color: Theme.of(context).primaryColor),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // RIGHT SIDE - Image
//             Container(
//               width: 100,
//               height: double.infinity,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // Image
//                   ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topRight: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                     ),
//                     child: imageUrl.isNotEmpty 
//                       ? Image.network(
//                           imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             color: Colors.grey[200],
//                             child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
//                           ),
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               color: Colors.grey[100],
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded / 
//                                       loadingProgress.expectedTotalBytes!
//                                     : null,
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : Container(
//                           color: Colors.grey[200],
//                           child: const Center(
//                             child: Icon(Icons.restaurant, color: Colors.grey),
//                           ),
//                         ),
//                   ),
                  
//                   // Discount badge
//                   if (discountedPrice < price)
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                         decoration: const BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(8),
//                             topRight: Radius.circular(10),
//                           ),
//                         ),
//                         child: Text(
//                           '${((price - discountedPrice) / price * 100).round()}%',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Extract the Buy X Get Y message from the item
//   String _getBuyXGetYMessage() {
//     if (item['discount_rules'] != null && 
//         item['discount_rules'] is List && 
//         item['discount_rules'].isNotEmpty && 
//         item['discount_rules'][0]['type'] == 'buy_x_get_y') {
          
//       final buyQuantity = item['discount_rules'][0]['buy_quantity'];
//       final getQuantity = item['discount_rules'][0]['get_quantity'];
//       final freeQuantity = getQuantity - buyQuantity;
//       return 'Buy $buyQuantity Get $freeQuantity Free';
//     }
//     return '';
//   }
// }
































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
    final String imageUrl = item['name_image'] ?? '';
    
    bool hasDiscount = item['has_discount'] ?? false;
    double discountedPrice = (item['discounted_price'] ?? price).toDouble();
    
    final int totalQuantity = cartController.getTotalQuantity(itemName);
    final buyXGetYMessage = _getBuyXGetYMessage();
    final bool hasCustomization = cartController.itemCustomizations.containsKey(itemName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main content row
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Content section (left side)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top content area
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item name with veg/non-veg indicator
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Veg/Non-veg indicator
                                  // Container(
                                  //   margin: const EdgeInsets.only(top: 3, right: 6),
                                  //   padding: const EdgeInsets.all(2),
                                  //   decoration: BoxDecoration(
                                  //     border: Border.all(
                                  //       color: foodType.toLowerCase().contains('veg') 
                                  //         ? Colors.green 
                                  //         : Colors.red, 
                                  //       width: 1
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  //   child: Icon(
                                  //     Icons.circle,
                                  //     size: 8,
                                  //     color: foodType.toLowerCase().contains('veg') 
                                  //       ? Colors.green 
                                  //       : Colors.red,
                                  //   ),
                                  // ),

                                      // Replace the circle indicator with a simple food type badge
    Container(
      margin: const EdgeInsets.only(top: 3, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        foodType,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    ),
                                  
                                  // Item name
                                  Expanded(
                                    child: Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Category badge
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Description with expand/collapse
                              if (description != null && description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  isExpanded
                                    ? description
                                    : description.length > 60
                                      ? '${description.substring(0, 60)}...'
                                      : description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                  maxLines: isExpanded ? 4 : 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (description.length > 60)
                                  GestureDetector(
                                    onTap: () => onToggleExpanded(itemName),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        isExpanded ? 'Read less' : 'Read more',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              
                              // Buy X Get Y message
                              if (buyXGetYMessage.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    buyXGetYMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              
                              // Customization indicator
                              if (hasCustomization)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Custom: ${cartController.itemCustomizations[itemName]}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Bottom section with price and controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Price display
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (discountedPrice < price)
                                    Text(
                                      '₹$price',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  Text(
                                    '₹$discountedPrice',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: discountedPrice < price ? 
                                        Colors.green[700] : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Quantity controls
                              totalQuantity == 0
                                ? _buildAddButton(context)
                                : _buildQuantityControls(context, totalQuantity),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Image section (right side)
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        // Item image
                        if (imageUrl.isNotEmpty)
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Center(child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32)),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: Center(
                              child: Icon(Icons.restaurant_menu, color: Colors.grey[300], size: 40),
                            ),
                          ),
                          
                        // Customize button overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Material(
                            color: Colors.black.withOpacity(0.6),
                            child: InkWell(
                              onTap: () => onCustomize(itemName),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.tune, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'CUSTOMIZE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Discount badge
                        if (discountedPrice < price)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.redAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${((price - discountedPrice) / price * 100).round()}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add button
  Widget _buildAddButton(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withBlue(255)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAddItem(context, item),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: const Text(
              'ADD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Quantity controls
  Widget _buildQuantityControls(BuildContext context, int quantity) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Decrease button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onAddItem(context, item),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(Icons.remove, color: Theme.of(context).primaryColor, size: 16),
              ),
            ),
          ),
          
          // Quantity
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ),
          
          // Increase button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onAddItem(context, item),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 16),
              ),
            ),
          ),
        ],
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
