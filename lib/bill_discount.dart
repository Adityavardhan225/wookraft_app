import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'http_client.dart';

class BillDiscount extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onApplyCoupons;
  final double billAmount;
  final String? orderId; // Add orderId parameter

  const BillDiscount({
    super.key, 
    required this.onApplyCoupons,
    required this.billAmount,
    this.orderId, // Make it optional
  });

  @override
  State<BillDiscount> createState() => _BillDiscountState();
}

class _BillDiscountState extends State<BillDiscount> {
  bool isLoading = true;
  bool isApplying = false; // Add loading state for discount application
  List<Map<String, dynamic>> availableCoupons = [];
  List<Map<String, dynamic>> filteredCoupons = [];
  List<Map<String, dynamic>> selectedCoupons = [];
  String? errorMessage;
  Map<String, TextEditingController> detailsControllers = {};
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableCoupons();
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in detailsControllers.values) {
      controller.dispose();
    }
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableCoupons() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await HttpClient.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Use the correct endpoint
      final uri = Uri.parse('${Config.baseUrl}/billing/valid_bill_discounts');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Create a new list with deep-copied maps to avoid reference issues
        final coupons = (data as List).map((item) => 
          Map<String, dynamic>.from(item as Map<String, dynamic>)
        ).toList();
        
        // Initialize controllers for required details
        for (var coupon in coupons) {
          if (coupon['details_required'] != null) {
            final detailsRequired = Map<String, dynamic>.from(coupon['details_required'] as Map);
            for (var key in detailsRequired.keys) {
              detailsControllers['${coupon['coupon_id']}_$key'] = TextEditingController();
            }
          }
        }
        
        setState(() {
          availableCoupons = coupons;
          filteredCoupons = List.from(coupons);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load coupons: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading coupons: ${e.toString()}')),
        );
      }
    }
  }

  void _filterCoupons(String query) {
    if (!mounted) return;
    
    setState(() {
      if (query.isEmpty) {
        filteredCoupons = List.from(availableCoupons);
      } else {
        filteredCoupons = availableCoupons.where((coupon) {
          final name = coupon['discount_coupon_name'].toString().toLowerCase();
          final message = (coupon['message'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || message.contains(searchLower);
        }).toList();
      }
    });
  }

  void _selectCoupon(Map<String, dynamic> coupon) {
    if (!mounted) return;
    
    // Debug info
    print("Selecting coupon: ${coupon['discount_coupon_name']}");
    print("Full coupon data: $coupon");
    
    // Handle null coupon_id safely
    final dynamic rawCouponId = coupon['coupon_id'];
    if (rawCouponId == null) {
      print("Error: Coupon ID is null for ${coupon['discount_coupon_name']}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid coupon data')),
      );
      return;
    }
    
    // Convert to string to be safe
    final String couponId = rawCouponId.toString();
    
    // Check if this coupon is already selected
    final bool isSelected = selectedCoupons.any((c) {
      final dynamic id = c['coupon_id'];
      return id != null && id.toString() == couponId;
    });
    
    setState(() {
      // If already selected, remove it and return
      if (isSelected) {
        selectedCoupons.removeWhere((c) {
          final dynamic id = c['coupon_id'];
          return id != null && id.toString() == couponId;
        });
        print("Removed coupon. Remaining: ${selectedCoupons.length}");
        return;
      }
      
      // Check if the current coupon is exclusive (can't be combined)
      final bool isExclusive = coupon['can_apply_with_other_coupons'] != true;
      
      // If this is an exclusive coupon, remove any other exclusive coupons
      if (isExclusive) {
        // Remove any existing exclusive coupons
        selectedCoupons.removeWhere((c) => c['can_apply_with_other_coupons'] != true);
      }
      
      // Now we can safely add the new coupon
      selectedCoupons.add(Map<String, dynamic>.from(coupon));
      print("Added coupon: ${coupon['discount_coupon_name']}. Total: ${selectedCoupons.length}");
    });
  }

  bool _isCouponApplicable(Map<String, dynamic> coupon) {
    // Check minimum bill amount
    if (coupon['min_bill_amount'] != null && 
        widget.billAmount < (coupon['min_bill_amount'] as num)) {
      return false;
    }
    return true;
  }

  Future<void> _applyCoupons() async {
    // Check if all required details are filled
    bool allDetailsFilled = true;
    String missingDetails = '';

    for (var coupon in selectedCoupons) {
      if (coupon['details_required'] != null) {
        final detailsRequired = Map<String, dynamic>.from(coupon['details_required'] as Map);
        for (var key in detailsRequired.keys) {
          final dynamic rawId = coupon['coupon_id'];
          if (rawId == null) continue;
          
          String controllerId = '${rawId.toString()}_$key';
          if (detailsControllers[controllerId]?.text.isEmpty ?? true) {
            allDetailsFilled = false;
            missingDetails = detailsRequired[key].toString();
            break;
          }
        }
      }
      if (!allDetailsFilled) break;
    }

    if (!allDetailsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all required details: $missingDetails')),
      );
      return;
    }
    
    // Add entered details to the selected coupons
    final selectedCouponsWithDetails = selectedCoupons.map((coupon) {
      final couponWithDetails = Map<String, dynamic>.from(coupon);
      
      if (coupon['details_required'] != null) {
        final enteredDetails = <String, String>{};
        final detailsRequired = Map<String, dynamic>.from(coupon['details_required'] as Map);
        final dynamic rawId = coupon['coupon_id'];
        if (rawId != null) {
          for (var key in detailsRequired.keys) {
            String controllerId = '${rawId.toString()}_$key';
            if (detailsControllers[controllerId] != null) {
              enteredDetails[key] = detailsControllers[controllerId]!.text;
            }
          }
        }
        
        couponWithDetails['entered_details'] = enteredDetails;
      }
      
      return couponWithDetails;
    }).toList();
    
    // If we have an order ID, call the API to apply discounts
    if (widget.orderId != null) {
      await _applyBillDiscounts(selectedCouponsWithDetails);
    }
    
    // Call the callback with selected coupons (regardless of API call)
    widget.onApplyCoupons(selectedCouponsWithDetails);
    
    // Close the bottom sheet
    Navigator.pop(context);
  }
  
  // New method to call the API for applying discounts
  Future<void> _applyBillDiscounts(List<Map<String, dynamic>> couponsWithDetails) async {
    if (widget.orderId == null) return;
    
    try {
      setState(() {
        isApplying = true;
      });
      
      final token = await HttpClient.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Extract just the coupon IDs from the selected coupons
      final List<String> couponIds = couponsWithDetails
          .map((coupon) => coupon['coupon_id']?.toString())
          .where((id) => id != null)
          .toList()
          .cast<String>();
      
      if (couponIds.isEmpty) {
        throw Exception('No valid coupon IDs found');
      }
      
      // Prepare request body
      final requestBody = {
        'order_id': widget.orderId,
        'coupon_ids': couponIds,
        'token': token
      };
      
      print("Applying discounts: ${json.encode(requestBody)}");
      
      // Call the API
      final uri = Uri.parse('${Config.baseUrl}/billing/apply_bill_discounts');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(requestBody)
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Discount applied successfully: $responseData");
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Discounts applied successfully'),
              backgroundColor: Colors.green,
            )
          );
        }
      } else {
        throw Exception('Failed to apply discounts: ${response.statusCode}, ${response.body}');
      }
      
    } catch (e) {
      print("Error applying discounts: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying discounts: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        key: const ValueKey('billDiscountContainer'),
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, size: 24, color: Colors.purple[700]),
                const SizedBox(width: 12),
                const Text(
                  'Available Coupons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              key: const ValueKey('searchField'),
              controller: searchController,
              onChanged: _filterCoupons,
              decoration: InputDecoration(
                hintText: 'Search coupons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : filteredCoupons.isEmpty
                        ? const Center(child: Text('No matching coupons found'))
                        : ListView.builder(
                            key: const ValueKey('couponList'),
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCoupons.length + (selectedCoupons.isNotEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Selected coupons summary at the top
                              if (selectedCoupons.isNotEmpty && index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selected Coupons: ${selectedCoupons.length}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[800],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...selectedCoupons.map((coupon) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: Colors.purple[700],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  coupon['discount_coupon_name'].toString(),
                                                  style: TextStyle(
                                                    color: Colors.purple[700],
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, size: 16, color: Colors.purple[300]),
                                                onPressed: () => _selectCoupon(coupon),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                tooltip: 'Remove coupon',
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              // Adjust index for coupon list when there's a selected coupon summary
                              final couponIndex = selectedCoupons.isNotEmpty ? index - 1 : index;
                              final coupon = filteredCoupons[couponIndex];
                              
                              final isSelected = selectedCoupons.any((c) {
                                final dynamic selId = c['coupon_id'];
                                final dynamic couponId = coupon['coupon_id'];
                                return selId != null && couponId != null && 
                                       selId.toString() == couponId.toString();
                              });
                              final isApplicable = _isCouponApplicable(coupon);
                              
                              return _buildCouponCard(coupon, isSelected, isApplicable);
                            },
                          ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  disabledBackgroundColor: Colors.purple[100],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isApplying || selectedCoupons.isEmpty ? null : _applyCoupons,
                child: isApplying
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Applying discounts...')
                    ],
                  )
                : const Text(
                    'Apply Selected Coupons',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCouponCard(Map<String, dynamic> coupon, bool isSelected, bool isApplicable) {
    return Opacity(
      opacity: isApplicable ? 1.0 : 0.6,
      child: Card(
        key: ValueKey('coupon_${coupon['discount_coupon_name']}'),
        margin: const EdgeInsets.only(bottom: 12),
        color: isSelected ? Colors.purple[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Colors.purple
                : Colors.grey[300]!,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: InkWell(
          onTap: isApplicable ? () => _selectCoupon(coupon) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coupon['discount_coupon_name'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.purple[700]
                              : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.purple[700],
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  coupon['message']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Discount value badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        coupon['discount_value'] != null
                            ? 'Flat ₹${coupon['discount_value']}'
                            : '${coupon['discount_percentage']}% Off',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Minimum bill amount
                    if (coupon['min_bill_amount'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Min: ₹${coupon['min_bill_amount']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      
                    const Spacer(),
                    
                    // Combinable info
                    if (coupon['can_apply_with_other_coupons'] == false)
                      Tooltip(
                        message:
                            'Cannot be combined with other coupons',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.block,
                              size: 16,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Exclusive',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                // Additional details if selected
                if (isSelected && coupon['details_required'] != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(coupon['details_required'] as Map<String, dynamic>)
                          .entries.map<Widget>((entry) {
                            final dynamic rawId = coupon['coupon_id'];
                            if (rawId == null) return const SizedBox.shrink();
                            
                            final controllerId = '${rawId.toString()}_${entry.key}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                key: ValueKey('detail_$controllerId'),
                                controller: detailsControllers[controllerId],
                                decoration: InputDecoration(
                                  labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                                  hintText: entry.value.toString(),
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  
                // Not applicable message
                if (!isApplicable)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Minimum bill amount not met (₹${coupon['min_bill_amount']})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}