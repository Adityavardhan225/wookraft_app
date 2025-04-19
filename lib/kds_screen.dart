// import 'dart:convert';
// import 'package:flutter/material.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'http_client.dart'; // Import HttpClient
// import 'config.dart';

// class KDSScreen extends StatefulWidget {
//   final List<String> initialSelectedFoodTypes;
//   final List<String> initialSelectedFoodCategories;

//   const KDSScreen({
//     Key? key,
//     this.initialSelectedFoodTypes = const [],
//     this.initialSelectedFoodCategories = const [],
//   }) : super(key: key);

//   @override
//   _KDSScreenState createState() => _KDSScreenState();
// }

// class _KDSScreenState extends State<KDSScreen> {
//   late WebSocketChannel channel;
//   List<Map<String, dynamic>> orders = [];
//   List<String> foodTypes = [];
//   List<String> categories = [];
//   List<String> selectedFoodTypes = [];
//   List<String> selectedFoodCategories = [];
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     selectedFoodTypes = List<String>.from(widget.initialSelectedFoodTypes);
//     selectedFoodCategories = List<String>.from(widget.initialSelectedFoodCategories);
//     _initializeWebSocket();
//     _getFoodTypes();
//     _getCategories();
//   }

//   Future<void> _initializeWebSocket() async {
//     final token = await HttpClient.getToken(); // Replace with actual token retrieval method

//     if (token != null) {
//       // final url = 'ws://127.0.0.1:8000/ws/kds?token=$token';
//       final url = '${Config.wsUrl}/kds?token=$token';
//       channel = WebSocketChannel.connect(
//         Uri.parse(url),
//       );

//       channel.stream.listen((message) {
//         final order = jsonDecode(message);
//         setState(() {
//           orders.add(order);
//           print('Orders is for debuging: $orders'); // Print orders for debugging
//         });
//       }, onError: (error) {
//         print('WebSocket error: $error');
//       });
//     } else {
//       setState(() {
//         _errorMessage = 'Token not found';
//       });
//     }
//   }

//   Future<void> _getFoodTypes() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       // final uri = Uri.http('127.0.0.1:8000', '/menu/food_types');
//       final uri = Uri.parse('${Config.baseUrl}/menu/food_types');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           foodTypes = List<String>.from(jsonDecode(response.body).map((type) => type['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load food types';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   Future<void> _getCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       // final uri = Uri.http('127.0.0.1:8000', '/menu/categories');
//       final uri = Uri.parse('${Config.baseUrl}/menu/categories');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           categories = List<String>.from(jsonDecode(response.body).map((category) => category['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load categories';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     channel.sink.close(1000);
//     super.dispose();
//   }

//   Future<void> _applyFilters() async {
//     try {
//       final response = await http.post(
//         // Uri.parse('http://localhost:8000/ordersystem/filter_orders'),
//          Uri.parse('${Config.baseUrl}/ordersystem/filter_orders'), // Use Config for the URL
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'food_types': selectedFoodTypes,
//           'food_categories': selectedFoodCategories,
//         }),
//       );

//       if (response.statusCode == 200) {
//         _reloadScreen(); // Reload the screen after applying filters
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to update filter criteria';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   void _removeFilters() {
//     setState(() {
//       selectedFoodTypes = [];
//       selectedFoodCategories = [];
//     });
//     _applyFilters();
//   }

//   void _reloadScreen() {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation1, animation2) => KDSScreen(
//           initialSelectedFoodTypes: selectedFoodTypes,
//           initialSelectedFoodCategories: selectedFoodCategories,
//         ),
//         transitionDuration: Duration.zero,
//         reverseTransitionDuration: Duration.zero,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('KDS Screen'),
//       ),
//       body: _errorMessage != null
//           ? Center(child: Text(_errorMessage!))
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: foodTypes.map((type) {
//                         return ChoiceChip(
//                           label: Text(type),
//                           selected: selectedFoodTypes.contains(type),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodTypes.add(type);
//                               } else {
//                                 selectedFoodTypes.remove(type);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: categories.map((category) {
//                         return ChoiceChip(
//                           label: Text(category),
//                           selected: selectedFoodCategories.contains(category),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodCategories.add(category);
//                               } else {
//                                 selectedFoodCategories.remove(category);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: _applyFilters,
//                           child: Text("Apply Filters"),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: _removeFilters,
//                           child: Text("Remove Filters"),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       selectedFoodTypes.isNotEmpty || selectedFoodCategories.isNotEmpty
//                           ? 'Items are filtered in these food types: ${selectedFoodTypes.join(', ')} and categories: ${selectedFoodCategories.join(', ')}'
//                           : 'No filter applied',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     ...orders.map((order) {
//                       final tableNumber = order['table_number'];
//                       final employeeId = order['employee_id'];
//                       final overallCustomization = order['overall_customization'] ?? '';
//                       final items = (order['items'] as List<dynamic>? ?? []).toList();
//                       print('waiterId: $employeeId');
//                       print('employeeId: $order');
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Table No: $tableNumber, Waiter ID: $employeeId',
//                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text('Order Prepared'),
//                                       Checkbox(
//                                         value: order['prepared'] ?? false,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final index = updatedOrders.indexOf(order);
//                                             updatedOrders[index] = {
//                                               ...order,
//                                               'prepared': value,
//                                             };
//                                             orders = updatedOrders;
//                                           });
//                                           if (value == true) {
//                                             _markOrderAsPrepared(order['_id']);
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               if (overallCustomization.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Text(
//                                     'Overall Customization: $overallCustomization',
//                                     style: TextStyle(fontStyle: FontStyle.italic),
//                                   ),
//                                 ),
//                               DataTable(
//                                 columns: const [
//                                   DataColumn(label: Text('Item Name')),
//                                   DataColumn(label: Text('Customization')),
//                                   DataColumn(label: Text('Quantity')),
//                                   DataColumn(label: Text('Prepared')),
//                                 ],
//                                 rows: items.map((item) {
//                                   final itemName = item['name'];
//                                   final itemCustomization = item['customization'] ?? '';
//                                   final itemQuantity = item['quantity'];
//                                   final itemPrepared = item['prepared_items'] ?? false;

//                                   return DataRow(cells: [
//                                     DataCell(Text(itemName)),
//                                     DataCell(Text(itemCustomization)),
//                                     DataCell(Text(itemQuantity.toString())),
//                                     DataCell(
//                                       Checkbox(
//                                         value: itemPrepared,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedItems = List<Map<String, dynamic>>.from(order['items']);
//                                             final index = updatedItems.indexOf(item);
//                                             updatedItems[index] = {
//                                               ...item,
//                                               'prepared_items': value,
//                                             };
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final orderIndex = updatedOrders.indexOf(order);
//                                             updatedOrders[orderIndex] = {
//                                               ...order,
//                                               'items': updatedItems,
//                                             };
//                                             orders = updatedOrders;
//                                             print('Updated Items: $updatedItems'); // Print updated items for debugging
//                                             print('Updated Orders: $updatedOrders');
//                                           });
//                                           if (value == true) {
//                                             final orderId = order['_id'].toString();
//                                             final itemName = item['name'];
//                                             print('Order ID: $orderId');
//                                             print('Item Name: $itemName');
//                                             _markItemAsPrepared(orderId, itemName);
//                                           }
//                                         },
//                                         activeColor: Colors.blue,
//                                       ),
//                                     ),
//                                   ]);
//                                 }).toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   void _markOrderAsPrepared(String orderId) {
//     final message = jsonEncode({
//       'type': 'prepare_order',
//       'order_id': orderId,
//     });
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }

//   void _markItemAsPrepared(String orderId, String itemName) {
//     final message = jsonEncode({
//       'type': 'prepare_item',
//       'order_id': orderId,
//       'item_name': itemName,
//     });
//     print('Message: $message'); // Print the message for debugging
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }
// }
























































































// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'http_client.dart'; // Import HttpClient
// import 'config.dart';

// class KDSScreen extends StatefulWidget {
//   final List<String> initialSelectedFoodTypes;
//   final List<String> initialSelectedFoodCategories;

//   const KDSScreen({
//     Key? key,
//     this.initialSelectedFoodTypes = const [],
//     this.initialSelectedFoodCategories = const [],
//   }) : super(key: key);

//   @override
//   _KDSScreenState createState() => _KDSScreenState();
// }

// class _KDSScreenState extends State<KDSScreen> {
//   late WebSocketChannel channel;
//   List<Map<String, dynamic>> orders = [];
//   List<String> foodTypes = [];
//   List<String> categories = [];
//   List<String> selectedFoodTypes = [];
//   List<String> selectedFoodCategories = [];
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     selectedFoodTypes = List<String>.from(widget.initialSelectedFoodTypes);
//     selectedFoodCategories = List<String>.from(widget.initialSelectedFoodCategories);
//     _initializeWebSocket();
//     _getFoodTypes();
//     _getCategories();
//   }

//   Future<void> _initializeWebSocket() async {
//     final token = await HttpClient.getToken(); // Replace with actual token retrieval method

//     if (token != null) {
//       final url = '${Config.wsUrl}/kds?token=$token';
//       channel = WebSocketChannel.connect(
//         Uri.parse(url),
//       );

//       channel.stream.listen((message) {
//         final data = jsonDecode(message);
//         if (data['type'] == 'cancellation_request') {
//           print('Cancellation request received: $data');
//           _showCancellationDialog(data);
//         } else {
//           setState(() {
//             orders.add(data);
//             print('Orders is for debugging: $orders'); // Print orders for debugging
//           });
//         }
//       }, onError: (error) {
//         print('WebSocket error: $error');
//       });
//     } else {
//       setState(() {
//         _errorMessage = 'Token not found';
//       });
//     }
//   }

//   Future<void> _getFoodTypes() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       final uri = Uri.parse('${Config.baseUrl}/menu/food_types');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           foodTypes = List<String>.from(jsonDecode(response.body).map((type) => type['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load food types';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   Future<void> _getCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       final uri = Uri.parse('${Config.baseUrl}/menu/categories');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           categories = List<String>.from(jsonDecode(response.body).map((category) => category['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load categories';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     channel.sink.close(1000);
//     super.dispose();
//   }

//   Future<void> _applyFilters() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}/ordersystem/filter_orders'), // Use Config for the URL
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'food_types': selectedFoodTypes,
//           'food_categories': selectedFoodCategories,
//         }),
//       );

//       if (response.statusCode == 200) {
//         _reloadScreen(); // Reload the screen after applying filters
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to update filter criteria';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   void _removeFilters() {
//     setState(() {
//       selectedFoodTypes = [];
//       selectedFoodCategories = [];
//     });
//     _applyFilters();
//   }

//   void _reloadScreen() {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation1, animation2) => KDSScreen(
//           initialSelectedFoodTypes: selectedFoodTypes,
//           initialSelectedFoodCategories: selectedFoodCategories,
//         ),
//         transitionDuration: Duration.zero,
//         reverseTransitionDuration: Duration.zero,
//       ),
//     );
//   }

//   Future<void> _showCancellationDialog(Map<String, dynamic> data) async {
//     final orderId = data['order_id'];
//     final itemName = data['item_name'];
//     final reason = data['reason'];

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Cancellation Request'),
//         content: Text('Do you want to cancel $itemName for the following reason: $reason?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _approveCancellation(orderId, itemName);
//               Navigator.pop(context);
//             },
//             child: Text('Yes'),
//           ),
//           TextButton(
//             onPressed: () {
//               _rejectCancellation(orderId, itemName, 'Cancellation rejected by KDS');
//               Navigator.pop(context);
//             },
//             child: Text('No'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _approveCancellation(String orderId, String itemName) {
//     final message = jsonEncode({
//       'type': 'approve_cancellation',
//       'order_id': orderId,
//       'item_name': itemName,
//     });
//     channel.sink.add(message);
//   }

//   void _rejectCancellation(String orderId, String itemName, String reason) {
//     final message = jsonEncode({
//       'type': 'reject_cancellation',
//       'order_id': orderId,
//       'item_name': itemName,
//       'reason': reason,
//     });
//     channel.sink.add(message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('KDS Screen'),
//       ),
//       body: _errorMessage != null
//           ? Center(child: Text(_errorMessage!))
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: foodTypes.map((type) {
//                         return ChoiceChip(
//                           label: Text(type),
//                           selected: selectedFoodTypes.contains(type),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodTypes.add(type);
//                               } else {
//                                 selectedFoodTypes.remove(type);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: categories.map((category) {
//                         return ChoiceChip(
//                           label: Text(category),
//                           selected: selectedFoodCategories.contains(category),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodCategories.add(category);
//                               } else {
//                                 selectedFoodCategories.remove(category);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: _applyFilters,
//                           child: Text("Apply Filters"),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: _removeFilters,
//                           child: Text("Remove Filters"),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       selectedFoodTypes.isNotEmpty || selectedFoodCategories.isNotEmpty
//                           ? 'Items are filtered in these food types: ${selectedFoodTypes.join(', ')} and categories: ${selectedFoodCategories.join(', ')}'
//                           : 'No filter applied',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     ...orders.map((order) {
//                       final tableNumber = order['table_number'];
//                       final employeeId = order['employee_id'];
//                       final overallCustomization = order['overall_customization'] ?? '';
//                       final items = (order['items'] as List<dynamic>? ?? []).toList();
//                       print('waiterId: $employeeId');
//                       print('employeeId: $order');
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Table No: $tableNumber, Waiter ID: $employeeId',
//                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text('Order Prepared'),
//                                       Checkbox(
//                                         value: order['prepared'] ?? false,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final index = updatedOrders.indexOf(order);
//                                             updatedOrders[index] = {
//                                               ...order,
//                                               'prepared': value,
//                                             };
//                                             orders = updatedOrders;
//                                           });
//                                           if (value == true) {
//                                             _markOrderAsPrepared(order['_id']);
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               if (overallCustomization.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Text(
//                                     'Overall Customization: $overallCustomization',
//                                     style: TextStyle(fontStyle: FontStyle.italic),
//                                   ),
//                                 ),
//                               DataTable(
//                                 columns: const [
//                                   DataColumn(label: Text('Item Name')),
//                                   DataColumn(label: Text('Customization')),
//                                   DataColumn(label: Text('Quantity')),
//                                   DataColumn(label: Text('Prepared')),
//                                 ],
//                                 rows: items.map((item) {
//                                   final itemName = item['name'];
//                                   final itemCustomization = item['customization'] ?? '';
//                                   final itemQuantity = item['quantity'];
//                                   final itemPrepared = item['prepared_items'] ?? false;

//                                   return DataRow(cells: [
//                                     DataCell(Text(itemName)),
//                                     DataCell(Text(itemCustomization)),
//                                     DataCell(Text(itemQuantity.toString())),
//                                     DataCell(
//                                       Checkbox(
//                                         value: itemPrepared,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedItems = List<Map<String, dynamic>>.from(order['items']);
//                                             final index = updatedItems.indexOf(item);
//                                             updatedItems[index] = {
//                                               ...item,
//                                               'prepared_items': value,
//                                             };
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final orderIndex = updatedOrders.indexOf(order);
//                                             updatedOrders[orderIndex] = {
//                                               ...order,
//                                               'items': updatedItems,
//                                             };
//                                             orders = updatedOrders;
//                                             print('Updated Items: $updatedItems'); // Print updated items for debugging
//                                             print('Updated Orders: $updatedOrders');
//                                           });
//                                           if (value == true) {
//                                             final orderId = order['_id'].toString();
//                                             final itemName = item['name'];
//                                             print('Order ID: $orderId');
//                                             print('Item Name: $itemName');
//                                             _markItemAsPrepared(orderId, itemName);
//                                           }
//                                         },
//                                         activeColor: Colors.blue,
//                                       ),
//                                     ),
//                                   ]);
//                                 }).toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   void _markOrderAsPrepared(String orderId) {
//     final message = jsonEncode({
//       'type': 'prepare_order',
//       'order_id': orderId,
//     });
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }

//   void _markItemAsPrepared(String orderId, String itemName) {
//     final message = jsonEncode({
//       'type': 'prepare_item',
//       'order_id': orderId,
//       'item_name': itemName,
//     });
//     print('Message: $message'); // Print the message for debugging
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }
// }








































































































// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'http_client.dart'; // Import HttpClient
// import 'config.dart';

// class KDSScreen extends StatefulWidget {
//   final List<String> initialSelectedFoodTypes;
//   final List<String> initialSelectedFoodCategories;

//   const KDSScreen({
//     Key? key,
//     this.initialSelectedFoodTypes = const [],
//     this.initialSelectedFoodCategories = const [],
//   }) : super(key: key);

//   @override
//   _KDSScreenState createState() => _KDSScreenState();
// }

// class _KDSScreenState extends State<KDSScreen> {
//   late WebSocketChannel channel;
//   List<Map<String, dynamic>> orders = [];
//   List<String> foodTypes = [];
//   List<String> categories = [];
//   List<String> selectedFoodTypes = [];
//   List<String> selectedFoodCategories = [];
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     selectedFoodTypes = List<String>.from(widget.initialSelectedFoodTypes);
//     selectedFoodCategories = List<String>.from(widget.initialSelectedFoodCategories);
//     _initializeWebSocket();
//     _getFoodTypes();
//     _getCategories();
//   }

//   Future<void> _initializeWebSocket() async {
//     final token = await HttpClient.getToken(); // Replace with actual token retrieval method

//     if (token != null) {
//       final url = '${Config.wsUrl}/kds?token=$token';
//       channel = WebSocketChannel.connect(
//         Uri.parse(url),
//       );

//       channel.stream.listen((message) {
//         final data = jsonDecode(message);
//         if (data['type'] == 'cancellation_request') {
//           _showCancellationDialog(data);
//         } else if (data['type'] == 'order_update') {
//           _updateOrderStatus(data);
//         } else if (data['type'] == 'order_placed') {
//           _handleOrderPlaced(data);
//         } else {
//           setState(() {
//             orders.add(data);
//             print('Orders is for debugging: $orders'); // Print orders for debugging
//           });
//         }
//       }, onError: (error) {
//         print('WebSocket error: $error');
//       });
//     } else {
//       setState(() {
//         _errorMessage = 'Token not found';
//       });
//     }
//   }

//   void _updateOrderStatus(Map<String, dynamic> data) {
//     setState(() {
//       final orderId = data['order_id'];
//       final itemName = data['item_name'];
//       final status = data['status'];

//       for (var order in orders) {
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
//     });
//   }

//   void _handleOrderPlaced(Map<String, dynamic> data) {
//     setState(() {
//       final newOrder = data['order'];
//       orders.add(newOrder);
//       _reloadScreen();
//     });
//   }

//   Future<void> _getFoodTypes() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       final uri = Uri.parse('${Config.baseUrl}/menu/food_types');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           foodTypes = List<String>.from(jsonDecode(response.body).map((type) => type['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load food types';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   Future<void> _getCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('access_token');

//       final uri = Uri.parse('${Config.baseUrl}/menu/categories');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         setState(() {
//           categories = List<String>.from(jsonDecode(response.body).map((category) => category['name']));
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _errorMessage = 'Failed to load categories';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     channel.sink.close(1000);
//     super.dispose();
//   }

//   Future<void> _applyFilters() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}/ordersystem/filter_orders'), // Use Config for the URL
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'food_types': selectedFoodTypes,
//           'food_categories': selectedFoodCategories,
//         }),
//       );

//       if (response.statusCode == 200) {
//         _reloadScreen(); // Reload the screen after applying filters
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to update filter criteria';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred: $e';
//       });
//     }
//   }

//   void _removeFilters() {
//     setState(() {
//       selectedFoodTypes = [];
//       selectedFoodCategories = [];
//     });
//     _applyFilters();
//   }

//   void _reloadScreen() {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation1, animation2) => KDSScreen(
//           initialSelectedFoodTypes: selectedFoodTypes,
//           initialSelectedFoodCategories: selectedFoodCategories,
//         ),
//         transitionDuration: Duration.zero,
//         reverseTransitionDuration: Duration.zero,
//       ),
//     );
//   }

//   Future<void> _showCancellationDialog(Map<String, dynamic> data) async {
//     final orderId = data['order_id'];
//     final itemName = data['item_name'];
//     final reason = data['reason'];

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Cancellation Request'),
//         content: Text('Do you want to cancel $itemName for the following reason: $reason?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _approveCancellation(orderId, itemName);
//               Navigator.pop(context);
//             },
//             child: Text('Yes'),
//           ),
//           TextButton(
//             onPressed: () {
//               _rejectCancellation(orderId, itemName, 'Cancellation rejected by KDS');
//               Navigator.pop(context);
//             },
//             child: Text('No'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _approveCancellation(String orderId, String itemName) {
//     final message = jsonEncode({
//       'type': 'approve_cancellation',
//       'order_id': orderId,
//       'item_name': itemName,
//     });
//     channel.sink.add(message);
//   }

//   void _rejectCancellation(String orderId, String itemName, String reason) {
//     final message = jsonEncode({
//       'type': 'reject_cancellation',
//       'order_id': orderId,
//       'item_name': itemName,
//       'reason': reason,
//     });
//     channel.sink.add(message);
//   }

//   void _acknowledgeOrder(String orderId) {
//     final message = jsonEncode({
//       'type': 'acknowledgment',
//       'order_id': orderId,
//     });
//     channel.sink.add(message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('KDS Screen'),
//       ),
//       body: _errorMessage != null
//           ? Center(child: Text(_errorMessage!))
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: foodTypes.map((type) {
//                         return ChoiceChip(
//                           label: Text(type),
//                           selected: selectedFoodTypes.contains(type),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodTypes.add(type);
//                               } else {
//                                 selectedFoodTypes.remove(type);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: categories.map((category) {
//                         return ChoiceChip(
//                           label: Text(category),
//                           selected: selectedFoodCategories.contains(category),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedFoodCategories.add(category);
//                               } else {
//                                 selectedFoodCategories.remove(category);
//                               }
//                             });
//                           },
//                           selectedColor: Colors.blue,
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         ElevatedButton(
//                           onPressed: _applyFilters,
//                           child: Text("Apply Filters"),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: _removeFilters,
//                           child: Text("Remove Filters"),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       selectedFoodTypes.isNotEmpty || selectedFoodCategories.isNotEmpty
//                           ? 'Items are filtered in these food types: ${selectedFoodTypes.join(', ')} and categories: ${selectedFoodCategories.join(', ')}'
//                           : 'No filter applied',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     ...orders.map((order) {
//                       final tableNumber = order['table_number'];
//                       final employeeId = order['employee_id'];
//                       final overallCustomization = order['overall_customization'] ?? '';
//                       final items = (order['items'] as List<dynamic>? ?? []).toList();
//                       print('waiterId: $employeeId');
//                       print('employeeId: $order');
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Table No: $tableNumber, Waiter ID: $employeeId',
//                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text('Order Prepared'),
//                                       Checkbox(
//                                         value: order['prepared'] ?? false,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final index = updatedOrders.indexOf(order);
//                                             updatedOrders[index] = {
//                                               ...order,
//                                               'prepared': value,
//                                             };
//                                             orders = updatedOrders;
//                                           });
//                                           if (value == true) {
//                                             _markOrderAsPrepared(order['_id']);
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               if (overallCustomization.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Text(
//                                     'Overall Customization: $overallCustomization',
//                                     style: TextStyle(fontStyle: FontStyle.italic),
//                                   ),
//                                 ),
//                               DataTable(
//                                 columns: const [
//                                   DataColumn(label: Text('Item Name')),
//                                   DataColumn(label: Text('Customization')),
//                                   DataColumn(label: Text('Quantity')),
//                                   DataColumn(label: Text('Prepared')),
//                                 ],
//                                 rows: items.map((item) {
//                                   final itemName = item['name'];
//                                   final itemCustomization = item['customization'] ?? '';
//                                   final itemQuantity = item['quantity'];
//                                   final itemPrepared = item['prepared_items'] ?? false;

//                                   return DataRow(cells: [
//                                     DataCell(Text(itemName)),
//                                     DataCell(Text(itemCustomization)),
//                                     DataCell(Text(itemQuantity.toString())),
//                                     DataCell(
//                                       Checkbox(
//                                         value: itemPrepared,
//                                         onChanged: (bool? value) {
//                                           setState(() {
//                                             final updatedItems = List<Map<String, dynamic>>.from(order['items']);
//                                             final index = updatedItems.indexOf(item);
//                                             updatedItems[index] = {
//                                               ...item,
//                                               'prepared_items': value,
//                                             };
//                                             final updatedOrders = List<Map<String, dynamic>>.from(orders);
//                                             final orderIndex = updatedOrders.indexOf(order);
//                                             updatedOrders[orderIndex] = {
//                                               ...order,
//                                               'items': updatedItems,
//                                             };
//                                             orders = updatedOrders;
//                                             print('Updated Items: $updatedItems'); // Print updated items for debugging
//                                             print('Updated Orders: $updatedOrders');
//                                           });
//                                           if (value == true) {
//                                             final orderId = order['_id'].toString();
//                                             final itemName = item['name'];
//                                             print('Order ID: $orderId');
//                                             print('Item Name: $itemName');
//                                             _markItemAsPrepared(orderId, itemName);
//                                           }
//                                         },
//                                         activeColor: Colors.blue,
//                                       ),
//                                     ),
//                                   ]);
//                                 }).toList(),
//                               ),


//                               if (order['received'] != true)
//                                  ElevatedButton(
//                                       onPressed: () {
//                                        _acknowledgeOrder(order['_id']);
//                                         setState(() {
//                                             order['received'] = true;
//                                           });
//                                         },
//                                        style: ElevatedButton.styleFrom(
//                                        backgroundColor: Colors.blue, // Button color
//                                      ),
//                                        child: Text('Order Preparing'),
//                                    ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   void _markOrderAsPrepared(String orderId) {
//     final message = jsonEncode({
//       'type': 'prepare_order',
//       'order_id': orderId,
//     });
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }

//   void _markItemAsPrepared(String orderId, String itemName) {
//     final message = jsonEncode({
//       'type': 'prepare_item',
//       'order_id': orderId,
//       'item_name': itemName,
//     });
//     print('Message: $message'); // Print the message for debugging
//     channel.sink.add(message);
//     _reloadScreen(); // Reload the screen
//   }
// }































import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'http_client.dart'; // Import HttpClient
import 'config.dart';

class KDSScreen extends StatefulWidget {
  final List<String> initialSelectedFoodTypes;
  final List<String> initialSelectedFoodCategories;

  const KDSScreen({
    super.key,
    this.initialSelectedFoodTypes = const [],
    this.initialSelectedFoodCategories = const [],
  });

  @override
  _KDSScreenState createState() => _KDSScreenState();
}

class _KDSScreenState extends State<KDSScreen> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> orders = [];
  List<String> foodTypes = [];
  List<String> categories = [];
  List<String> selectedFoodTypes = [];
  List<String> selectedFoodCategories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedFoodTypes = List<String>.from(widget.initialSelectedFoodTypes);
    selectedFoodCategories = List<String>.from(widget.initialSelectedFoodCategories);
    _initializeWebSocket();
    _getFoodTypes();
    _getCategories();
  }

  Future<void> _initializeWebSocket() async {
    final token = await HttpClient.getToken(); // Replace with actual token retrieval method

    if (token != null) {
      final url = '${Config.wsUrl}/kds?token=$token';
      channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      channel.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'cancellation_request') {
          _showCancellationDialog(data);
        } else if (data['type'] == 'order_update') {
          _updateOrderStatus(data);
        } else if (data['type'] == 'order_placed') {
          _handleOrderPlaced(data);
        } else {
          setState(() {
            orders.add(data);
            print('Orders is for debugging: $orders'); // Print orders for debugging
          });
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      });
    } else {
      setState(() {
        _errorMessage = 'Token not found';
      });
    }
  }

  void _updateOrderStatus(Map<String, dynamic> data) {
    setState(() {
      final orderId = data['order_id'];
      final itemName = data['item_name'];
      final status = data['status'];

      for (var order in orders) {
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
    });
  }

  void _handleOrderPlaced(Map<String, dynamic> data) {
    setState(() {
      final newOrder = data['order'];
      orders.add(newOrder);
      _reloadScreen();
    });
  }

  Future<void> _getFoodTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final uri = Uri.parse('${Config.baseUrl}/menu/food_types');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          foodTypes = List<String>.from(jsonDecode(response.body).map((type) => type['name']));
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load food types';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final uri = Uri.parse('${Config.baseUrl}/menu/categories');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          categories = List<String>.from(jsonDecode(response.body).map((category) => category['name']));
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load categories';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close(1000);
    super.dispose();
  }

  Future<void> _applyFilters() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/ordersystem/filter_orders'), // Use Config for the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'food_types': selectedFoodTypes,
          'food_categories': selectedFoodCategories,
        }),
      );

      if (response.statusCode == 200) {
        _reloadScreen(); // Reload the screen after applying filters
      } else {
        setState(() {
          _errorMessage = 'Failed to update filter criteria';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _removeFilters() {
    setState(() {
      selectedFoodTypes = [];
      selectedFoodCategories = [];
    });
    _applyFilters();
  }

  void _reloadScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => KDSScreen(
          initialSelectedFoodTypes: selectedFoodTypes,
          initialSelectedFoodCategories: selectedFoodCategories,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _showCancellationDialog(Map<String, dynamic> data) async {
    final orderId = data['order_id'];
    final itemName = data['item_name'];
    final reason = data['reason'];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancellation Request'),
        content: Text('Do you want to cancel $itemName for the following reason: $reason?'),
        actions: [
          TextButton(
            onPressed: () {
              _approveCancellation(orderId, itemName);
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              _rejectCancellation(orderId, itemName, 'Cancellation rejected by KDS');
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  void _approveCancellation(String orderId, String itemName) {
    final message = jsonEncode({
      'type': 'approve_cancellation',
      'order_id': orderId,
      'item_name': itemName,
    });
    channel.sink.add(message);
  }

  void _rejectCancellation(String orderId, String itemName, String reason) {
    final message = jsonEncode({
      'type': 'reject_cancellation',
      'order_id': orderId,
      'item_name': itemName,
      'reason': reason,
    });
    channel.sink.add(message);
  }

  void _acknowledgeOrder(String orderId) {
    final message = jsonEncode({
      'type': 'acknowledgment',
      'order_id': orderId,
    });
    channel.sink.add(message);
  }

  // Helper function to format customization details
  String _formatCustomizationDetails(dynamic customizationData) {
    if (customizationData == null) return '';
    
    // If customization is a string (old format), just return it
    if (customizationData is String) return customizationData;
    
    // Handle new format with customization as an object
    String result = '';
    
    // Add customization text
    if (customizationData['text'] != null && customizationData['text'].toString().isNotEmpty) {
      result = customizationData['text'].toString();
    }
    
    return result;
  }
  
  // Helper function to get size information
  String _formatSizeInfo(dynamic customizationData) {
    if (customizationData == null) return '';
    
    // If customization is a string (old format), return empty
    if (customizationData is String) return '';
    
    // Extract size info from the new format
    if (customizationData['size'] != null) {
      final size = customizationData['size'];
      if (size != null && size['size_name'] != null) {
        return size['size_name'].toString();
      }
    }
    
    return '';
  }
  
  // Helper function to format addons list
  String _formatAddons(dynamic customizationData) {
    if (customizationData == null) return '';
    
    // If customization is a string (old format), return empty
    if (customizationData is String) return '';
    
    // Extract addons from the new format
    if (customizationData['addons'] != null) {
      final addons = customizationData['addons'] as List?;
      if (addons != null && addons.isNotEmpty) {
        return addons.map((addon) {
          final addonName = addon['addon_name'] ?? '';
          final quantity = addon['quantity'] ?? 1;
          return '$addonName${quantity > 1 ? ' × $quantity' : ''}';
        }).join(', ');
      }
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display'),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
              children: [
                // Compact filter section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filters', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _applyFilters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size(50, 28),
                                ),
                                child: const Text("Apply", style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: _removeFilters,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size(50, 28),
                                ),
                                child: const Text("Clear", style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Horizontal scrollable filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...foodTypes.map((type) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: FilterChip(
                                label: Text(type, style: TextStyle(fontSize: 11)),
                                selected: selectedFoodTypes.contains(type),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedFoodTypes.add(type);
                                    } else {
                                      selectedFoodTypes.remove(type);
                                    }
                                  });
                                },
                                selectedColor: Colors.deepOrange[100],
                                labelStyle: TextStyle(fontSize: 11),
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                checkmarkColor: Colors.deepOrange,
                                visualDensity: VisualDensity.compact,
                              ),
                            )),
                            const SizedBox(width: 6),
                            ...categories.map((category) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: FilterChip(
                                label: Text(category, style: TextStyle(fontSize: 11)),
                                selected: selectedFoodCategories.contains(category),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedFoodCategories.add(category);
                                    } else {
                                      selectedFoodCategories.remove(category);
                                    }
                                  });
                                },
                                selectedColor: Colors.deepOrange[100],
                                checkmarkColor: Colors.deepOrange,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Orders display - MAXIMIZE COLUMN USAGE
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate optimal number of columns based on available width
                      final double screenWidth = constraints.maxWidth;
                      final int columns = (screenWidth / 320).floor();
                      final int actualColumns = columns > 0 ? columns : 1; // Ensure at least 1 column
                      
                      if (actualColumns == 1) {
                        // Single column layout - use ListView for full height cards
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: orders.length,
                          itemBuilder: (context, index) => 
                            _buildOrderCard(orders[index]),
                        );
                      } else {
                        // Multi-column layout - use available space optimally
                        return SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(actualColumns, (columnIndex) {
                              // Get orders for this column
                              final List<Map<String, dynamic>> columnOrders = [];
                              for (int i = columnIndex; i < orders.length; i += actualColumns) {
                                columnOrders.add(orders[i]);
                              }
                              
                              // Build column of orders
                              return Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Column(
                                    children: columnOrders.map((order) => 
                                      _buildOrderCard(order)).toList(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  // Build a single order card with all items visible (no internal scrolling)
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final tableNumber = order['table_number'];
    final employeeId = order['employee_id'];
    final overallCustomization = order['overall_customization'] ?? '';
    final items = (order['items'] as List<dynamic>? ?? []).toList();
    final isPrepared = order['prepared'] ?? false;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isPrepared ? Colors.green : Colors.grey[300]!,
          width: isPrepared ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isPrepared ? Colors.green[50] : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Table $tableNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waiter: $employeeId',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      isPrepared ? 'Ready' : 'Pending',
                      style: TextStyle(
                        color: isPrepared ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Checkbox(
                      value: isPrepared,
                      activeColor: Colors.green,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) {
                        setState(() {
                          final index = orders.indexOf(order);
                          final updatedOrders = List<Map<String, dynamic>>.from(orders);
                          updatedOrders[index] = {
                            ...order,
                            'prepared': value,
                          };
                          orders = updatedOrders;
                        });
                        if (value == true) {
                          _markOrderAsPrepared(order['_id']);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notes if available - with teal color instead of yellow
          if (overallCustomization.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.teal[50], 
              child: Row(
                children: [
                  const Icon(Icons.note, color: Colors.teal, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      overallCustomization,
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.teal[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          
          // Items - NO SCROLLING, ALL VISIBLE
          ...items.map((item) {
            final itemName = item['name'];
            final itemCustomization = _formatCustomizationDetails(item['customization']);
            final itemSize = _formatSizeInfo(item['customization']);
            final itemAddons = _formatAddons(item['customization']);
            final itemQuantity = item['quantity'];
            final itemPrepared = item['prepared_items'] ?? false;
            
            final bool hasCustomization = itemCustomization.isNotEmpty;
            final bool hasSize = itemSize.isNotEmpty;
            final bool hasAddons = itemAddons.isNotEmpty;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                color: itemPrepared ? Colors.green[50] : Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox for item preparation
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: itemPrepared,
                      activeColor: Colors.green,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) {
                        setState(() {
                          final orderIndex = orders.indexOf(order);
                          final updatedItems = List<Map<String, dynamic>>.from(order['items']);
                          final itemIndex = updatedItems.indexOf(item);
                          updatedItems[itemIndex] = {
                            ...item,
                            'prepared_items': value,
                          };
                          
                          final updatedOrders = List<Map<String, dynamic>>.from(orders);
                          updatedOrders[orderIndex] = {
                            ...order,
                            'items': updatedItems,
                          };
                          orders = updatedOrders;
                        });
                        if (value == true) {
                          _markItemAsPrepared(order['_id'].toString(), itemName);
                        }
                      },
                    ),
                  ),
                  
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item name and quantity
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'x$itemQuantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Size (if available) - with distinct indigo color
                        if (hasSize)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 2),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Size: $itemSize',
                                    style: TextStyle(
                                      color: Colors.indigo[800],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Add-ons (if available)
                        if (hasAddons)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 2),
                            child: Text(
                              'Add: $itemAddons',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11,
                              ),
                            ),
                          ),
                        
                        // Customization (if available)
                        if (hasCustomization)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 2),
                            child: Text(
                              'Note: $itemCustomization',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // Acknowledge button
          if (order['received'] != true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () {
                  _acknowledgeOrder(order['_id']);
                  setState(() {
                    final index = orders.indexOf(order);
                    orders[index] = {
                      ...order,
                      'received': true,
                    };
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Acknowledge Order', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _markOrderAsPrepared(String orderId) {
    final message = jsonEncode({
      'type': 'prepare_order',
      'order_id': orderId,
    });
    channel.sink.add(message);
    _reloadScreen(); // Reload the screen
  }

  void _markItemAsPrepared(String orderId, String itemName) {
    final message = jsonEncode({
      'type': 'prepare_item',
      'order_id': orderId,
      'item_name': itemName,
    });
    print('Message: $message'); // Print the message for debugging
    channel.sink.add(message);
    _reloadScreen(); // Reload the screen
  }
}