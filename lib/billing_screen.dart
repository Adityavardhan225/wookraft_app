import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'http_client.dart';
import 'customer_info.dart';
import 'bill_discount.dart';
import 'menu_screen/billing/bill_pdf_viewer.dart';

class BillingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const BillingScreen({
    super.key,
    required this.order,
  });

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool isLoading = false;
  bool showBill = false;
  Map<String, dynamic>? orderDetails;
  String? errorMessage;


  static String? currentOrderId;
  static int? currentTableNumber;
  static String? currentWaiterNo;

  // Customer details state variables
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  String? customerAddress;

  // Coupons applied via the BillDiscount widget
  List<Map<String, dynamic>> appliedCoupons = [];

  @override
  void initState() {
    super.initState();
    // _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await HttpClient.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final orderId = widget.order['id'];
      final tableNumber = widget.order['table_number'];
      

      final queryParams = {
        if (orderId != null) 'order_id': orderId,
        if (tableNumber != null) 'table_number': tableNumber.toString(),
        'token': token,
      };

      final uri = Uri.parse('${Config.baseUrl}/billing/order_details')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orderDetails = data;
          isLoading = false;
          showBill = true;
        }
        );
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Add method to handle customer info submission
  void _submitCustomerDetails(String name, String phone, String? email, String? address) {
    setState(() {
      customerName = name;
      customerPhone = phone;
      customerEmail = email;
      customerAddress = address;
      isLoading = true;
    });
    _fetchOrderDetails();
  }

String _formatPrice(dynamic price) {
  // Handle null value
  if (price == null) return '₹0.00';
  
  // Convert to number if it's not already
  final numPrice = price is num ? price : double.tryParse(price.toString()) ?? 0.0;
  return '₹${numPrice.toStringAsFixed(2)}';
}

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing - Table ${widget.order['table_number']}'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: showBill ? _fetchOrderDetails : null,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Bill',
            onPressed: showBill ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing functionality coming soon')),
              );
            } : null,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Loading bill details...',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : errorMessage != null
          
              ? _buildErrorView()
              : showBill
                  ? _buildBillView()
                  // : CustomerInfoForm(onSubmit: _submitCustomerDetails),
                  :CustomerInfoForm(
                    
  onSubmit: _submitCustomerDetails,
                orderId: widget.order['id'] ?? '',
                tableNumber: widget.order['table_number'] ?? 0,
                waiterNo: widget.order['employee_id'] ?? '1',
),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Could not load bill details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _fetchOrderDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillView() {
    if (orderDetails == null) return const Center(child: Text('No bill data available'));
    
    final items = orderDetails!['items'] as List<dynamic>;
    
    return Stack(
      children: [
        // Main content
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill header card
              _buildBillHeaderCard(),
              
              const SizedBox(height: 24),
              
              // Items header
              Row(
                children: [
                  Icon(Icons.restaurant_menu, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Order Items (${items.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              
              // Items list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemCard(items[index]),
              ),
              
              const SizedBox(height: 24),

              // Coupon button
              Card(
                key: const ValueKey('couponCard'),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BillDiscount(
                        billAmount: orderDetails!['total_price'] ?? 0.0,
                        orderId: orderDetails!['order_id'],
                        onApplyCoupons: (coupons) {
                          setState(() {
                            appliedCoupons = coupons;
                            // You would typically make an API call here to apply the coupons
                            // and update the bill amount
                          });
                          _fetchOrderDetails();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${coupons.length} coupon(s) applied successfully!'),
                              backgroundColor: Colors.green[700],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.purple[700]),
                        const SizedBox(width: 12),
                        const Text(
                          'Apply Coupon',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        appliedCoupons.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${appliedCoupons.length} Applied',
                                  style: TextStyle(
                                    color: Colors.purple[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Icon(Icons.keyboard_arrow_right),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bill summary card
              _buildBillSummaryCard(),
              
              // Space for bottom bar
              const SizedBox(height: 80),
            ],
          ),
        ),
        
        // Bottom payment bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      _formatPrice(orderDetails!['final_price'] ?? orderDetails!['total_discounted_price']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                   
                      BillPdfViewer.showBillPdf(context, orderDetails!['order_id']);
                    
                    
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Process Payment'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant name and logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Icon(Icons.restaurant, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Bill Details',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: orderDetails!['status'] == 'active' 
                        ? Colors.blue[100] 
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    orderDetails!['status'] ?? 'Unknown',
                    style: TextStyle(
                      color: orderDetails!['status'] == 'active' 
                          ? Colors.blue[700] 
                          : Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Order details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Order ID', '# ${orderDetails!['order_id']}'),
                _buildDetailItem('Table', orderDetails!['table_number'].toString()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Date', _formatDate(orderDetails!['timestamp'] ?? '')),
                _buildDetailItem('Server', orderDetails!['employee_id'] ?? ''),
              ],
            ),
            
            // Order notes if any
            if (orderDetails!['overall_customization'] != null && 
                orderDetails!['overall_customization'].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.amber[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        orderDetails!['overall_customization'],
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.amber[800],
                        ),
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
  
  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final isPrepared = item['prepared'] ?? false;
    final isPromotional = item['is_promotion_item'] ?? false;
    final hasCustomizations = item['customization_details'] != null && 
        (item['customization_details']['text'].toString().isNotEmpty || 
         item['customization_details']['size'] != null || 
         (item['customization_details']['addons'] as List).isNotEmpty);
         
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPromotional ? Colors.purple[200]! : Colors.transparent,
          width: isPromotional ? 1 : 0,
        ),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isPromotional ? Colors.purple[50] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item quantity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPromotional ? Colors.purple : Colors.green[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '×${item['quantity']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (item['food_category'] != null || item['food_type'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${item['food_category'] ?? ''} • ${item['food_type'] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      
                      // Preparation status
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPrepared ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPrepared ? Icons.check_circle : Icons.hourglass_empty,
                              size: 12,
                              color: isPrepared ? Colors.green[700] : Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPrepared ? 'Prepared' : 'Preparing',
                              style: TextStyle(
                                fontSize: 10,
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
                
                // Price column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isPromotional || item['total_price'] != item['total_discounted_price'])
                      Text(
                        _formatPrice(item['total_price']),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    Text(
                      _formatPrice(item['total_discounted_price']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPromotional ? Colors.purple : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Promotion badge
          if (isPromotional && item['promotion_details'] != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    size: 14,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Buy ${item['promotion_details']['buy_quantity']} ${item['promotion_details']['buy_item_name']} and get discount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Customization details
          if (hasCustomizations)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Size
                  if (item['customization_details']['size'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.straighten, size: 12, color: Colors.blue[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Size: ${item['customization_details']['size']['name']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatPrice(item['customization_details']['size']['price']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Addons
                  if ((item['customization_details']['addons'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add-ons:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(item['customization_details']['addons'] as List).map((addon) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, top: 4),
                            child: Row(
                              children: [
                                Text(
                                  '• ${addon['name']} ${addon['quantity'] > 1 ? '×${addon['quantity']}' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatPrice(addon['total_price']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  
                  // Customization note
                  if (item['customization_details']['text'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notes, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['customization_details']['text'],
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          
          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Base: ${_formatPrice(item['base_price'])} × ${item['quantity']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Item Total: ${_formatPrice(item['total_discounted_price'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBillSummaryCard() {
    final subtotal = orderDetails!['total_price'] ?? 0.0;
    final total = orderDetails!['total_discounted_price'] ?? subtotal;
    final itemLevelDiscount = subtotal - total;
    
    // New fields for bill discount and final price
    final billDiscountAmount = orderDetails!['bill_discount_amount'] ?? 0.0;
    final finalPrice = orderDetails!['final_price'] ?? total - billDiscountAmount;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.receipt, size: 18),
                SizedBox(width: 8),
                Text(
                  'Bill Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Subtotal row
            _buildSummaryRow('Subtotal:', _formatPrice(subtotal)),
            
            // Item-level discount row if applicable
            if (itemLevelDiscount > 0)
              _buildSummaryRow(
                'Item Discounts:',
                '- ${_formatPrice(itemLevelDiscount)}',
                valueColor: Colors.green[700],
              ),
            
            // After item discount subtotal
            if (itemLevelDiscount > 0)
              _buildSummaryRow(
                'After Item Discounts:',
                _formatPrice(total),
                divider: true,
              ),
              
            // Bill-level discount row if applicable
            if (billDiscountAmount > 0)
              _buildSummaryRow(
                'Bill Discount:',
                '- ${_formatPrice(billDiscountAmount)}',
                valueColor: Colors.green[700],
              ),
            
            // Grand total (final price after all discounts)
            _buildSummaryRow(
              'Final Amount:',
              _formatPrice(finalPrice),
              isTotal: true,
              divider: true,
            ),
            
            // Payment button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  BillPdfViewer.showBillPdf(context, orderDetails!['order_id']);
                },
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool divider = false,
    Color? valueColor,
  }) {
    return Column(
      children: [
        if (divider) const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 18 : 14,
                color: valueColor,
              ),
            ),
          ],
        ),
        if (divider) const SizedBox(height: 0) else const SizedBox(height: 8),
      ],
    );
  }
}