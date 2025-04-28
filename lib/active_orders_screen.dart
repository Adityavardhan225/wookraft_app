


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'websocket_service.dart';
// import 'http_client.dart';
// import 'config.dart';
// import 'local_notifications.dart';
// import 'billing_screen.dart';

// class ActiveOrdersScreen extends StatefulWidget {
//   const ActiveOrdersScreen({super.key});

//   @override
//   _ActiveOrdersScreenState createState() => _ActiveOrdersScreenState();
// }

// class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
//   List<Map<String, dynamic>> activeOrders = [];
//   List<Map<String, dynamic>> filteredOrders = [];
//   late WebSocketService webSocketService;
//   bool isLoading = true;
//   String? errorMessage;
//   TextEditingController tableController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebSocket();
//     LocalNotifications.init(); // Initialize local notifications
//   }

//   Future<void> _initializeWebSocket() async {
//     final employeeId = await HttpClient.getEmployeeId();
//     final token = await HttpClient.getToken();
//     if (token != null) {
//       webSocketService = WebSocketService(
//         url: '${Config.wsUrl}/waiter/$employeeId',
//         token: token,
//       );
//       webSocketService.connect();
//       webSocketService.onMessage.listen((message) {
//         final data = jsonDecode(message);
//         if (data['type'] == 'order_update') {
//           print('Order Update Received: $data'); // Debug print
//           _updateOrderStatus(data);
//           print('Order Update Received 1: $data'); // Debug print
//           _showNotification(data['item_name']);
//         } else if (data['type'] == 'cancellation_approved') {
//           _handleCancellationApproved(data);
//         } else if (data['type'] == 'cancellation_rejected') {
//           _handleCancellationRejected(data);
//         }
       
//          else {
//           setState(() {
//             activeOrders.add(data);
//             filteredOrders = List.from(activeOrders); // Initialize filteredOrders
//             isLoading = false;
//           });
//         }
//       });
//     } else {
//       setState(() {
//         errorMessage = 'Token not found';
//       });
//     }
//   }

//   void _updateOrderStatus(Map<String, dynamic> data) {
//     setState(() {
//       final orderId = data['order_id'];
//       final itemName = data['item_name'];
//       final status = data['status'];

//       for (var order in activeOrders) {
//         if (order['id'] == orderId) {
//           if (itemName != null) {
//             for (var item in order['items']) {
//               if (item['name'] == itemName) {
//                 item['prepared_items'] = status == 'prepared';
//               }
//             }
//           } else {
//             order['prepared'] = status == 'prepared';
//             for (var item in order['items']) {
//               item['prepared_items'] = status == 'prepared';
//             }
//           }
//         }
//       }
//       filteredOrders = List.from(activeOrders); // Update filteredOrders
//     });
//   }

//   void _handleCancellationApproved(Map<String, dynamic> data) {
//     final orderId = data['order_id'];
//     final itemName = data['item_name'];

//     setState(() {
//       for (var order in activeOrders) {
//         if (order['id'] == orderId) {
//           order['items'].removeWhere((item) => item['name'] == itemName);
//         }
//       }
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Cancellation approved for $itemName')),
//     );
//   }

//   void _handleCancellationRejected(Map<String, dynamic> data) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Cancellation rejected for ${data['item_name']}: ${data['reason']}',
//         ),
//       ),
//     );
//   }

//   void _showNotification(String message) {
//     LocalNotifications.showSimpleNotification(
//       title: 'Order Update',
//       body: message,
//       payload: 'order_update',
//     );
//   }

//   void _filterOrders() {
//     setState(() {
//       if (tableController.text.isEmpty) {
//         filteredOrders = List.from(activeOrders);
//       } else {
//         int? tableNumber = int.tryParse(tableController.text);
//         if (tableNumber != null) {
//           filteredOrders = activeOrders.where((order) => order['table_number'] == tableNumber).toList();
//         } else {
//           filteredOrders = [];
//         }
//       }
//     });
//   }

//   void _resetSearch() {
//     setState(() {
//       tableController.clear();
//       filteredOrders = List.from(activeOrders);
//     });
//   }

//   Future<void> _showCancellationDialog(String orderId, String itemName) async {
//     final reasonController = TextEditingController();
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Cancel Item'),
//         content: TextField(
//           controller: reasonController,
//           decoration: InputDecoration(
//             hintText: 'Enter reason for cancellation',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               print('Requesting cancellation for $itemName');
//               webSocketService.requestItemCancellation(
//                 orderId,
//                 itemName,
//                 reasonController.text,
//               );
//               Navigator.pop(context);
//             },
//             child: Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showUpdateOrderDialog(String orderId, Map<String, dynamic> item) async {
//     final quantityController = TextEditingController(text: item['quantity'].toString());
//     final customizationController = TextEditingController(text: item['customization'] ?? '');

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Update Item'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: quantityController,
//               decoration: InputDecoration(
//                 labelText: 'Quantity',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: customizationController,
//               decoration: InputDecoration(
//                 labelText: 'Customization',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               final updates = {
//                 'items': [
//                   {
//                     'name': item['name'],
//                     'quantity': int.parse(quantityController.text),
//                     'customization': customizationController.text,
//                   }
//                 ]
//               };
//               webSocketService.updateOrder(orderId, updates);
//               Navigator.pop(context);
//             },
//             child: Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     webSocketService.dispose();
//     tableController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Active Orders', 
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Colors.deepOrange,
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Refresh Orders',
//             onPressed: () {
//               setState(() {
//                 isLoading = true;
//               });
//               _initializeWebSocket();
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.grey[100],
//         child: isLoading
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.deepOrange),
//                     const SizedBox(height: 12),
//                     Text('Loading orders...',
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                   ],
//                 ),
//               )
//             : errorMessage != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red, size: 48),
//                         const SizedBox(height: 12),
//                         Text(errorMessage!, style: TextStyle(fontSize: 16)),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepOrange,
//                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                           ),
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry Connection'),
//                           onPressed: () {
//                             setState(() {
//                               isLoading = true;
//                               errorMessage = null;
//                             });
//                             _initializeWebSocket();
//                           },
//                         ),
//                       ],
//                     ),
//                   )
//                 : Column(
//                     children: [
//                       // Enhanced search bar
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               blurRadius: 5,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.grey[300]!),
//                                 ),
//                                 child: TextField(
//                                   controller: tableController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Search by table number',
//                                     prefixIcon: Icon(Icons.table_bar, color: Colors.grey[600]),
//                                     border: InputBorder.none,
//                                     contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                                   ),
//                                   keyboardType: TextInputType.number,
//                                   onSubmitted: (_) => _filterOrders(),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Material(
//                               color: Colors.deepOrange,
//                               borderRadius: BorderRadius.circular(8),
//                               child: InkWell(
//                                 onTap: _filterOrders,
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(10),
//                                   child: const Icon(Icons.search, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Material(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                               child: InkWell(
//                                 onTap: _resetSearch,
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(10),
//                                   child: Icon(Icons.clear, color: Colors.grey[700]),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       // Order status summary
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         color: Colors.grey[200],
//                         child: Row(
//                           children: [
//                             Text(
//                               '${filteredOrders.length} Active Order${filteredOrders.length != 1 ? 's' : ''}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.deepOrange,
//                               ),
//                             ),
//                             const Spacer(),
//                             if (tableController.text.isNotEmpty)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.deepOrange.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.filter_list, size: 14, color: Colors.deepOrange),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       'Filtered by table: ${tableController.text}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.deepOrange,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
                      
//                       // Orders list
//                       Expanded(
//                         child: filteredOrders.isEmpty 
//                             ? Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       'No active orders found',
//                                       style: TextStyle(
//                                         fontSize: 16, 
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     if (tableController.text.isNotEmpty)
//                                       Padding(
//                                         padding: const EdgeInsets.only(top: 8),
//                                         child: Text(
//                                           'Try clearing your search filter',
//                                           style: TextStyle(
//                                             fontSize: 14, 
//                                             color: Colors.grey[500],
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 padding: const EdgeInsets.all(8),
//                                 itemCount: filteredOrders.length,
//                                 itemBuilder: (context, index) {
//                                   final order = filteredOrders[index];
//                                   final isPrepared = order['prepared'] ?? false;
//                                   final items = order['items'] as List<dynamic>? ?? [];
                                  
//                                   return Card(
//                                     elevation: 2,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                       side: BorderSide(
//                                         color: isPrepared ? Colors.green : Colors.deepOrange.withOpacity(0.3),
//                                         width: isPrepared ? 2 : 1,
//                                       ),
//                                     ),
//                                     margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         // Order header
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: isPrepared ? Colors.green[50] : Colors.deepOrange[50],
//                                             borderRadius: const BorderRadius.only(
//                                               topLeft: Radius.circular(12),
//                                               topRight: Radius.circular(12),
//                                             ),
//                                           ),
//                                           padding: const EdgeInsets.all(12),
//                                           child: Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Container(
//                                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.deepOrange,
//                                                       borderRadius: BorderRadius.circular(8),
//                                                     ),
//                                                     child: Text(
//                                                       'Table ${order['table_number']}',
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.bold,
//                                                         fontSize: 14,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 12),
//                                                   Text(
//                                                     'Waiter: ${order['employee_id']}',
//                                                     style: TextStyle(
//                                                       color: Colors.grey[700],
//                                                       fontWeight: FontWeight.w500,
//                                                       fontSize: 14,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Container(
//                                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                 decoration: BoxDecoration(
//                                                   color: isPrepared ? Colors.green[100] : Colors.orange[100],
//                                                   borderRadius: BorderRadius.circular(16),
//                                                 ),
//                                                 child: Row(
//                                                   children: [
//                                                     Icon(
//                                                       isPrepared ? Icons.check_circle : Icons.hourglass_empty,
//                                                       size: 16,
//                                                       color: isPrepared ? Colors.green[700] : Colors.orange[700],
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       isPrepared ? 'Prepared' : 'Preparing',
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         fontWeight: FontWeight.bold,
//                                                         color: isPrepared ? Colors.green[700] : Colors.orange[700],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
                                        
//                                         // Overall customization if present
//                                         if (order['overall_customization'] != null && 
//                                             order['overall_customization'].toString().isNotEmpty)
//                                           Container(
//                                             color: Colors.teal[50],
//                                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                             child: Row(
//                                               children: [
//                                                 Icon(Icons.comment, size: 18, color: Colors.teal),
//                                                 const SizedBox(width: 8),
//                                                 Expanded(
//                                                   child: Text(
//                                                     'Note: ${order['overall_customization']}',
//                                                     style: TextStyle(
//                                                       fontStyle: FontStyle.italic,
//                                                       color: Colors.teal[800],
//                                                       fontSize: 13,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
                                        
//                                         // Order items
//                                         Container(
//                                           padding: const EdgeInsets.all(16),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     'Order Items (${items.length})',
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               const Divider(),
//                                               ...items.map((item) {
//                                                 final isPreparedItem = item['prepared_items'] ?? false;
                                                
//                                                 return Container(
//                                                   margin: const EdgeInsets.only(bottom: 12),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(8),
//                                                     color: isPreparedItem ? Colors.green[50] : Colors.white,
//                                                     border: Border.all(
//                                                       color: isPreparedItem ? Colors.green[200]! : Colors.grey[300]!,
//                                                     ),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(12),
//                                                     child: Row(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       children: [
//                                                         // Quantity indicator
//                                                         Container(
//                                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                           decoration: BoxDecoration(
//                                                             color: Colors.deepOrange,
//                                                             borderRadius: BorderRadius.circular(6),
//                                                           ),
//                                                           child: Text(
//                                                             '×${item['quantity']}',
//                                                             style: const TextStyle(
//                                                               color: Colors.white,
//                                                               fontWeight: FontWeight.bold,
//                                                               fontSize: 12,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         const SizedBox(width: 12),
                                                        
//                                                         // Item details
//                                                         Expanded(
//                                                           child: Column(
//                                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                                             children: [
//                                                               Row(
//                                                                 children: [
//                                                                   Expanded(
//                                                                     child: Text(
//                                                                       item['name'],
//                                                                       style: const TextStyle(
//                                                                         fontWeight: FontWeight.bold,
//                                                                         fontSize: 14,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   if (isPreparedItem)
//                                                                     Container(
//                                                                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                                                       decoration: BoxDecoration(
//                                                                         color: Colors.green[100],
//                                                                         borderRadius: BorderRadius.circular(4),
//                                                                       ),
//                                                                       child: Row(
//                                                                         children: [
//                                                                           Icon(Icons.check, size: 12, color: Colors.green[700]),
//                                                                           const SizedBox(width: 2),
//                                                                           Text(
//                                                                             'Ready',
//                                                                             style: TextStyle(
//                                                                               fontSize: 10,
//                                                                               color: Colors.green[700],
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                 ],
//                                                               ),
//                                                               const SizedBox(height: 4),
                                                              
//                                                               // Customization
//                                                               if (item['customization'] != null && item['customization'].toString().isNotEmpty)
//                                                                 Container(
//                                                                   margin: const EdgeInsets.only(top: 4),
//                                                                   padding: const EdgeInsets.all(6),
//                                                                   decoration: BoxDecoration(
//                                                                     color: Colors.grey[100],
//                                                                     borderRadius: BorderRadius.circular(4),
//                                                                   ),
//                                                                   child: Row(
//                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                     children: [
//                                                                       Icon(Icons.notes, size: 14, color: Colors.grey[600]),
//                                                                       const SizedBox(width: 4),
//                                                                       Expanded(
//                                                                         child: Text(
//                                                                           item['customization'].toString(),
//                                                                           style: TextStyle(
//                                                                             fontSize: 12,
//                                                                             fontStyle: FontStyle.italic,
//                                                                             color: Colors.grey[700],
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                             ],
//                                                           ),
//                                                         ),
                                                        
//                                                         // Actions column
//                                                         Column(
//                                                           children: [
//                                                             Material(
//                                                               color: Colors.blue[50],
//                                                               borderRadius: BorderRadius.circular(4),
//                                                               child: InkWell(
//                                                                 onTap: () => _showUpdateOrderDialog(order['id'], item),
//                                                                 borderRadius: BorderRadius.circular(4),
//                                                                 child: Padding(
//                                                                   padding: const EdgeInsets.all(6),
//                                                                   child: Icon(Icons.edit, size: 18, color: Colors.blue[700]),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             const SizedBox(height: 8),
//                                                             Material(
//                                                               color: Colors.red[50],
//                                                               borderRadius: BorderRadius.circular(4),
//                                                               child: InkWell(
//                                                                 onTap: () => _showCancellationDialog(order['id'], item['name']),
//                                                                 borderRadius: BorderRadius.circular(4),
//                                                                 child: Padding(
//                                                                   padding: const EdgeInsets.all(6),
//                                                                   child: Icon(Icons.delete, size: 18, color: Colors.red[700]),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               }),
//                                             ],
//                                           ),
//                                         ),

//                                         // NEW ADDITION: Billing Section
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey[100],
//                                             borderRadius: const BorderRadius.only(
//                                               bottomLeft: Radius.circular(12),
//                                               bottomRight: Radius.circular(12),
//                                             ),
//                                             border: Border(
//                                               top: BorderSide(color: Colors.grey[300]!),
//                                             ),
//                                           ),
//                                           padding: const EdgeInsets.all(12),
//                                           child: Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               // Order status
//                                               Row(
//                                                 children: [
//                                                   Icon(
//                                                     isPrepared ? Icons.check_circle : Icons.pending,
//                                                     size: 16,
//                                                     color: isPrepared ? Colors.green[700] : Colors.orange[700],
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Text(
//                                                     'Status: ${isPrepared ? 'Prepared' : 'Preparing'}',
//                                                     style: TextStyle(
//                                                       fontWeight: FontWeight.bold,
//                                                       fontSize: 13,
//                                                       color: Colors.grey[800],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
                                              
//                                               // Go to billing button
//                                               ElevatedButton.icon(
//                                                 onPressed: () {
//                                                   // Navigate to billing screen with this order
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) => BillingScreen(order: order),
//                                                     ),
//                                                   );
//                                                 },
//                                                 icon: const Icon(Icons.receipt_long, size: 16),
//                                                 label: const Text('Go to Billing'),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.green[700],
//                                                   foregroundColor: Colors.white,
//                                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                                   elevation: 2,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//       ),
//     );
//   }
// }


















































import 'dart:convert';
import 'package:flutter/material.dart';
import 'websocket_service.dart';
import 'http_client.dart';
import 'config.dart';
import 'local_notifications.dart';
import 'billing_screen.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  _ActiveOrdersScreenState createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  List<Map<String, dynamic>> activeOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  late WebSocketService webSocketService;
  bool isLoading = true;
  String? errorMessage;
  TextEditingController tableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    LocalNotifications.init();
  }

  Future<void> _initializeWebSocket() async {

      setState(() {
    activeOrders.clear();
    filteredOrders.clear();
    isLoading = true;
    errorMessage = null;
  });
  
    final employeeId = await HttpClient.getEmployeeId();
    final token = await HttpClient.getToken();
    if (token != null) {
      webSocketService = WebSocketService(
        url: '${Config.wsUrl}/waiter/$employeeId',
        token: token,
      );
      webSocketService.connect();
      webSocketService.onMessage.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'order_update') {
          _updateOrderStatus(data);
          _showNotification(data['item_name']);
        } else if (data['type'] == 'cancellation_approved') {
          _handleCancellationApproved(data);
        } else if (data['type'] == 'cancellation_rejected') {
          _handleCancellationRejected(data);
        } else {
          setState(() {
            activeOrders.add(data);
            filteredOrders = List.from(activeOrders);
            isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        errorMessage = 'Token not found';
      });
    }
  }

  void _updateOrderStatus(Map<String, dynamic> data) {
    setState(() {
      final orderId = data['order_id'];
      final itemName = data['item_name'];
      final status = data['status'];

      for (var order in activeOrders) {
        if (order['id'] == orderId) {
          if (itemName != null) {
            for (var item in order['items']) {
              if (item['name'] == itemName) {
                item['prepared_items'] = status == 'prepared';
              }
            }
          } else {
            order['prepared'] = status == 'prepared';
            for (var item in order['items']) {
              item['prepared_items'] = status == 'prepared';
            }
          }
        }
      }
      filteredOrders = List.from(activeOrders);
    });
  }

  void _handleCancellationApproved(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final itemName = data['item_name'];

    setState(() {
      for (var order in activeOrders) {
        if (order['id'] == orderId) {
          order['items'].removeWhere((item) => item['name'] == itemName);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancellation approved for $itemName')),
    );
  }

  void _handleCancellationRejected(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cancellation rejected for ${data['item_name']}: ${data['reason']}',
        ),
      ),
    );
  }

  void _showNotification(String message) {
    LocalNotifications.showSimpleNotification(
      title: 'Order Update',
      body: message,
      payload: 'order_update',
    );
  }

  void _filterOrders() {
    setState(() {
      if (tableController.text.isEmpty) {
        filteredOrders = List.from(activeOrders);
      } else {
        int? tableNumber = int.tryParse(tableController.text);
        if (tableNumber != null) {
          filteredOrders = activeOrders.where((order) => order['table_number'] == tableNumber).toList();
        } else {
          filteredOrders = [];
        }
      }
    });
  }

  void _resetSearch() {
    setState(() {
      tableController.clear();
      filteredOrders = List.from(activeOrders);
    });
  }

  Future<void> _showCancellationDialog(String orderId, String itemName) async {
    final reasonController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Item'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            hintText: 'Enter reason for cancellation',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              webSocketService.requestItemCancellation(
                orderId,
                itemName,
                reasonController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

Future<void> _showUpdateOrderDialog(String orderId, Map<String, dynamic> item) async {
  final quantityController = TextEditingController(text: item['quantity'].toString());
  
  // Extract only the customization text
  String customizationText = '';
  if (item['customization'] != null) {
    if (item['customization'] is String) {
      customizationText = item['customization'];
    } else if (item['customization'] is Map) {
      // Extract only the 'text' field from the customization Map
      final customization = item['customization'] as Map;
      if (customization.containsKey('text')) {
        customizationText = customization['text']?.toString() ?? '';
      }
    }
  }
  
  final customizationController = TextEditingController(text: customizationText);
  
  // Only show the customization field if we have text or for new input
  final bool showCustomizationField = true; // Always allow customization input
  
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Update Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity',
            ),
            keyboardType: TextInputType.number,
          ),
          if (showCustomizationField)
            TextField(
              controller: customizationController,
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'Enter any special instructions',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // For the update, wrap the text in a proper customization object
            final updates = {
              'items': [
                {
                  'name': item['name'],
                  'quantity': int.parse(quantityController.text),
                  'customization': {'text': customizationController.text}
                }
              ]
            };
            webSocketService.updateOrder(orderId, updates);
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    ),
  );
}
  // Improved parsing to extract just values
  Map<String, String> parseCustomization(String customizationStr) {
    Map<String, String> result = {};
    
    // Handle empty or null case
    if (customizationStr.isEmpty || customizationStr == "null") {
      return result;
    }
    
    try {
      // Remove braces if present
      String workingStr = customizationStr;
      if (workingStr.startsWith('{') && workingStr.endsWith('}')) {
        workingStr = workingStr.substring(1, workingStr.length - 1);
      }
      
      // Split by key-value pairs
      List<String> pairs = [];
      
      // Simple parser for key-value pairs
      int startPos = 0;
      bool inQuotes = false;
      
      for (int i = 0; i < workingStr.length; i++) {
        if (workingStr[i] == '"' || workingStr[i] == "'") {
          inQuotes = !inQuotes;
        } else if (workingStr[i] == ',' && !inQuotes) {
          pairs.add(workingStr.substring(startPos, i).trim());
          startPos = i + 1;
        }
      }
      
      // Add the last pair
      if (startPos < workingStr.length) {
        pairs.add(workingStr.substring(startPos).trim());
      }
      
      // Process each pair
      for (String pair in pairs) {
        List<String> keyValue = pair.split(':');
        if (keyValue.length >= 2) {
          String key = keyValue[0].trim();
          // Remove quotes from key if present
          if ((key.startsWith('"') && key.endsWith('"')) || 
              (key.startsWith("'") && key.endsWith("'"))) {
            key = key.substring(1, key.length - 1);
          }
          
          // Join back the value parts if there were colons in the value
          String value = keyValue.sublist(1).join(':').trim();
          // Remove quotes from value if present
          if ((value.startsWith('"') && value.endsWith('"')) || 
              (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length - 1);
          }
          
          // Skip null and empty values
          if (value != "null" && value.isNotEmpty) {
            // For size_name, store just as "size"
            if (key.contains('size')) {
              result['size'] = value;
            } 
            // For addons_name, store just as "addons"
            else if (key.contains('addons')) {
              result['addons'] = value;
            }
            // For text/instructions
            else if (key.contains('text')) {
              result['text'] = value;
            }
            // For any other keys
            else {
              result[key] = value;
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing customization: $e');
    }
    
    return result;
  }

  @override
  void dispose() {
    webSocketService.dispose();
    tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _initializeWebSocket();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.deepOrange),
                    const SizedBox(height: 12),
                    Text('Loading orders...',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(errorMessage!, style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _initializeWebSocket();
                          },
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Search bar with gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepOrange, Colors.deepOrange.shade700],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: tableController,
                                  decoration: InputDecoration(
                                    hintText: 'Search by table number',
                                    prefixIcon: Icon(Icons.table_bar, color: Colors.grey[600]),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (_) => _filterOrders(),
                                ),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.deepOrange),
                                onPressed: _filterOrders,
                              ),
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600]),
                                onPressed: _resetSearch,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Order count summary
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.grey[50],
                        child: Row(
                          children: [
                            Icon(Icons.list_alt, size: 20, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              '${filteredOrders.length} Active Order${filteredOrders.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const Spacer(),
                            if (tableController.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list, size: 14, color: Colors.deepOrange),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Table ${tableController.text}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Orders list
                      Expanded(
                        child: filteredOrders.isEmpty 
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No active orders found',
                                      style: TextStyle(
                                        fontSize: 18, 
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (tableController.text.isNotEmpty)
                                      TextButton.icon(
                                        onPressed: _resetSearch,
                                        icon: Icon(Icons.refresh),
                                        label: Text('Clear filter'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.deepOrange,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  final isPrepared = order['prepared'] ?? false;
                                  final items = order['items'] as List<dynamic>? ?? [];
                                  
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Order header
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isPrepared 
                                                ? [Colors.green.shade400, Colors.green.shade300]
                                                : [Colors.deepOrange.shade300, Colors.deepOrange.shade200],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Table and waiter info
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 2,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.table_restaurant, 
                                                          size: 18, 
                                                          color: Colors.deepOrange,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          'Table ${order['table_number']}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Waiter: ${order['employee_id']}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                      shadows: [
                                                        Shadow(
                                                          offset: Offset(0, 1),
                                                          blurRadius: 2,
                                                          color: Color.fromRGBO(0, 0, 0, 0.3),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              // Order status
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isPrepared ? Icons.check_circle : Icons.timelapse,
                                                      size: 16,
                                                      color: isPrepared ? Colors.green[700] : Colors.orange[700],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      isPrepared ? 'Prepared' : 'Preparing',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: isPrepared ? Colors.green[700] : Colors.orange[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Overall customization if present
                                        if (order['overall_customization'] != null && 
                                            order['overall_customization'].toString().isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            color: Colors.teal[50],
                                            child: Row(
                                              children: [
                                                Icon(Icons.comment_outlined, color: Colors.teal, size: 18),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Order Note:',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.teal[700],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        order['overall_customization'].toString(),
                                                        style: TextStyle(
                                                          color: Colors.teal[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        
                                        // Order items
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Items header
                                              Row(
                                                children: [
                                                  Icon(Icons.fastfood, size: 18, color: Colors.grey[700]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Order Items',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      '${items.length}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              const Divider(height: 24),
                                              
                                              // Items list
                                              ...items.map((item) {
                                                final isPreparedItem = item['prepared_items'] ?? false;
                                                
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 14),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: isPreparedItem ? Colors.green[200]! : Colors.grey[300]!,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      // Item header
                                                      Padding(
                                                        padding: const EdgeInsets.all(12),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // Quantity badge
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                              decoration: BoxDecoration(
                                                                color: Colors.deepOrange,
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              child: Text(
                                                                '× ${item['quantity']}',
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            
                                                            // Item name and status
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(
                                                                          item['name'],
                                                                          style: const TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (isPreparedItem)
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.green[100],
                                                                            borderRadius: BorderRadius.circular(4),
                                                                          ),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(Icons.check, size: 14, color: Colors.green[700]),
                                                                              const SizedBox(width: 4),
                                                                              Text(
                                                                                'Ready',
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Colors.green[700],
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            
                                                            // Action buttons
                                                            Row(
                                                              children: [
                                                                // Edit button
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.blue[50],
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                  child: IconButton(
                                                                    icon: Icon(Icons.edit_outlined, color: Colors.blue[700], size: 20),
                                                                    padding: EdgeInsets.all(6),
                                                                    constraints: BoxConstraints(),
                                                                    onPressed: () => _showUpdateOrderDialog(order['id'], item),
                                                                  ),
                                                                ),
                                                                
                                                                const SizedBox(width: 6),
                                                                
                                                                // Cancel button
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red[50],
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                  child: IconButton(
                                                                    icon: Icon(Icons.delete_outlined, color: Colors.red[700], size: 20),
                                                                    padding: EdgeInsets.all(6),
                                                                    constraints: BoxConstraints(),
                                                                    onPressed: () => _showCancellationDialog(order['id'], item['name']),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      
                                                      // Concise horizontal customization display
                                                      if (item['customization'] != null && item['customization'].toString().isNotEmpty)
                                                        _buildCompactCustomizationRow(item['customization'].toString()),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),

                                        // Footer with billing button
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Status summary
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isPrepared ? Colors.green[100] : Colors.orange[100],
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      isPrepared ? Icons.check : Icons.hourglass_bottom,
                                                      size: 16,
                                                      color: isPrepared ? Colors.green[700] : Colors.orange[700],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    isPrepared ? 'Ready to Serve' : 'In Preparation',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isPrepared ? Colors.green[700] : Colors.orange[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              // Billing button
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => BillingScreen(order: order),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.receipt_long, size: 18),
                                                label: const Text('Go to Billing'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green[700],
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
  
  // Compact, space-efficient customization display
  Widget _buildCompactCustomizationRow(String customizationStr) {
    Map<String, String> components = parseCustomization(customizationStr);
    
    // Early return if empty
    if (components.isEmpty) {
      return SizedBox.shrink();
    }
    
    // Create chips for each customization
    List<Widget> customizationChips = [];
    
    // Size chip (if present)
    if (components.containsKey('size') && components['size']!.isNotEmpty) {
      customizationChips.add(_buildChip(
        components['size']!,
        Icons.straighten,
        Colors.purple,
      ));
    }
    
    // Add-ons chip (if present and not empty)
    if (components.containsKey('addons') && components['addons']!.isNotEmpty && 
        components['addons'] != '[]' && components['addons'] != 'null') {
      customizationChips.add(_buildChip(
        components['addons']!,
        Icons.add_circle_outline,
        Colors.green,
      ));
    }
    
    // Special instructions (if present and not empty)
    if (components.containsKey('text') && components['text']!.isNotEmpty) {
      customizationChips.add(_buildChip(
        components['text']!,
        Icons.message_outlined,
        Colors.blue,
      ));
    }
    
    // Don't show anything if no valid customizations were found
    if (customizationChips.isEmpty) {
      return SizedBox.shrink();
    }
    
    // Return horizontal scrollable row if we have chips
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: customizationChips,
            ),
          ),
        ],
      ),
    );
  }
  
  // Individual chip for customization
  Widget _buildChip(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}