import 'package:flutter/material.dart';
import 'config.dart';
import 'http_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerInfoForm extends StatefulWidget {
  final Function(String, String, String?, String?) onSubmit;
  final String orderId;
  final int tableNumber;
  final String waiterNo;

  const CustomerInfoForm({
    super.key, 
    required this.onSubmit,
    required this.orderId,
    required this.tableNumber,
    required this.waiterNo,
  });

  @override
  _CustomerInfoFormState createState() => _CustomerInfoFormState();
}

class _CustomerInfoFormState extends State<CustomerInfoForm> {
  final _formKey = GlobalKey<FormState>();
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  String? customerAddress;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the customer name';
                }
                return null;
              },
              onSaved: (value) {
                customerName = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the customer phone number';
                }
                return null;
              },
              onSaved: (value) {
                customerPhone = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                customerEmail = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address (Optional)',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                customerAddress = value;
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _submitForm,
                child: const Text('Generate Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        // Get auth token
        final token = await HttpClient.getToken();
        
        // Make API call to save customer details
        final url = '${Config.baseUrl}/billing_template/save-customer-details?token=$token';
        
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': customerName,
            'phone': customerPhone,
            'email': customerEmail,
            'address': customerAddress,
            'table_number': widget.tableNumber,
            'waiter_no': widget.waiterNo,
            'order_id': widget.orderId,
          }),
        );
        
        if (response.statusCode != 200) {
          throw Exception('Failed to save customer details: ${response.statusCode}');
        }
        
        // Call the original onSubmit callback after successful API call
        widget.onSubmit(customerName!, customerPhone!, customerEmail, customerAddress);
        
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer details: $e')),
        );
      }
    }
  }
}