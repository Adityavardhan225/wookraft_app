import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key}); // Add key parameter

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  final _orderItemController = TextEditingController();
  final _tableNumberController = TextEditingController();
  List<dynamic> activeOrders = [];
  Map<String, int> itemQuantities = {};
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _addItemToOrder(String itemName, int quantity) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final tableNumber = int.parse(_tableNumberController.text);

      final response = await http.post(
        // Uri.parse('http://127.0.0.1:8000/ordersystem/add_item'),
        Uri.parse('${Config.baseUrl}/ordersystem/add_item'),
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
        body: jsonEncode({'order_item': {'name': itemName, 'quantity': quantity}, 'table_number': tableNumber}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _errorMessage = 'Item added to order successfully';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to add item to order';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getActiveOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final response = await http.get(
        // Uri.parse('http://127.0.0.1:8000/ordersystem/active_orders'),
        Uri.parse('${Config.baseUrl}/ordersystem/active_orders'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          activeOrders = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load active orders';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _incrementQuantity(String itemName) {
    setState(() {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String itemName) {
    setState(() {
      if (itemQuantities[itemName] != null && itemQuantities[itemName]! > 0) {
        itemQuantities[itemName] = itemQuantities[itemName]! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order System'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _orderItemController,
                  decoration: InputDecoration(
                    labelText: 'Order Item',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _tableNumberController,
                  decoration: InputDecoration(
                    labelText: 'Table Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final itemName = _orderItemController.text;
                  final quantity = itemQuantities[itemName] ?? 0;
                  if (quantity > 0) {
                    _addItemToOrder(itemName, quantity);
                  }
                },
                child: Text('Add Item to Order'),
              ),
              ElevatedButton(
                onPressed: _getActiveOrders,
                child: Text('Get Active Orders'),
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: TextStyle(color: Colors.red))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      return ListTile(
                        title: Text('Table Number: ${order['table_number']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in order['items'])
                              Text('${item['name']} (x${item['quantity']})'),
                            Text('Status: ${order['status']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                for (var itemName in itemQuantities.keys)
                  if (itemQuantities[itemName]! > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(itemName),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _decrementQuantity(itemName),
                            ),
                            Text('${itemQuantities[itemName]}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _incrementQuantity(itemName),
                            ),
                          ],
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}