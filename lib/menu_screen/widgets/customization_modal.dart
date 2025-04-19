import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/promotion_controller.dart';
import '../services/api_service.dart';
import '../models/get_item_info.dart';

class CustomizationModal extends StatefulWidget {
  final String itemName;
  final dynamic menuItem;
  final int initialQuantity;
  final String initialCustomization;
  final int? groupIndex;
  
  const CustomizationModal({
    super.key,
    required this.itemName,
    required this.menuItem,
    this.initialQuantity = 0,
    this.initialCustomization = '',
    this.groupIndex,
  });

  @override
  CustomizationModalState createState() => CustomizationModalState();
}

class CustomizationModalState extends State<CustomizationModal> {
  late TextEditingController _customizationController;
  late int _quantity;
  late final Map<String, bool> _addonSelections = {};
  late double _addonsTotal;
  final Map<String, Map<String, dynamic>> _selectedAddons = {};
  bool _isLoading = true;
  List<dynamic> _addons = [];
  bool _hasSize = false;
  String _selectedSize = '';
  double _sizePriceIncrement = 0.0;
  List<dynamic> _discountedItems = [];
  late PromotionController _promotionController;
  // Track local copies of get item quantities for this specific buy item context
  final Map<String, int> _localGetItemQuantities = {};

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _customizationController = TextEditingController(text: widget.initialCustomization);
    _addonsTotal = (widget.menuItem['discounted_price'] ?? widget.menuItem['price']).toDouble();
    
    // Get the promotion controller
    _promotionController = Provider.of<PromotionController>(context, listen: false);
    
    // Load add-ons, sizes, and discounted items
    _loadAddons();
    _loadSizes();
    _loadDiscountedItems();
  }
  
  Future<void> _loadAddons() async {
    setState(() => _isLoading = true);
    
    try {
      // Load add-ons from API
      _addons = await ApiService.getAddons(widget.itemName);
      
      print("Received addons for ${widget.itemName}");
      
      // Initialize add-on selections map with null safety
      for (var addon in _addons) {
        // Safely get the addon name with null check
        String addonName = addon['addon_item_name']?.toString() ?? 'Unknown';
        _addonSelections[addonName] = false;
      }
    } catch (e) {
      print('Error loading add-ons: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _loadSizes() async {
  setState(() => _isLoading = true);
  
  try {
    // Initialize sizes with null safety
    _hasSize = widget.menuItem['sizes'] != null && 
           widget.menuItem['sizes'] is List && 
           (widget.menuItem['sizes'] as List).isNotEmpty;
    
    if (_hasSize) {
      final sizes = widget.menuItem['sizes'];
      widget.menuItem['sizes'] = sizes;
      
      // If editing existing item, use the saved size
      if (widget.groupIndex != null) {
        // Get existing customization from cart
        final cartController = Provider.of<CartController>(context, listen: false);
        final customizationGroups = cartController.itemOrderGroups[widget.itemName] ?? [];
        
        if (widget.groupIndex! < customizationGroups.length) {
          final existingCustomization = customizationGroups[widget.groupIndex!];
          if (existingCustomization['has_size'] == true && 
              existingCustomization['selectedSize'] != null) {
            _selectedSize = existingCustomization['selectedSize'] as String? ?? '';
            _sizePriceIncrement = existingCustomization['sizePriceIncrement'] as double? ?? 0.0;
            print('Loaded existing size: $_selectedSize with price increment: $_sizePriceIncrement');
          }
        }
      }
      
      // If no size is already selected (new item or no previous selection), select default
      if (_selectedSize.isEmpty) {
        // Find default size in the menu item
        for (var size in widget.menuItem['sizes']) {
          bool isDefault = size['is_default'] == true;
          if (isDefault) {
            _selectedSize = size['name']?.toString() ?? '';
            _sizePriceIncrement = (size['price_increment'] as num?)?.toDouble() ?? 0.0;
            print('Selected default size: $_selectedSize with price increment: $_sizePriceIncrement');
            break;
          }
        }
        
        // If no size is marked as default, use the first size
        if (_selectedSize.isEmpty && (widget.menuItem['sizes'] as List).isNotEmpty) {
          var firstSize = (widget.menuItem['sizes'] as List)[0];
          _selectedSize = firstSize['name']?.toString() ?? '';
          _sizePriceIncrement = (firstSize['price_increment'] as num?)?.toDouble() ?? 0.0;
          print('No default size found, using first size: $_selectedSize');
        }
      }
    }
  } catch (e) {
    print('Error loading sizes: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _loadDiscountedItems() async {
    setState(() => _isLoading = true);
    
    try {
      // Get discounted items from controller instead of direct API call
      print("🛒 Loading discounted items via PromotionController for ${widget.itemName}");
      
      final List<GetItemInfo> items = await _promotionController.getDiscountedItems(widget.itemName);
      print("🛒 Controller returned ${items.length} items");
      
      // Convert GetItemInfo objects to map format for UI consistency
      _discountedItems = items.map((item) => {
        'name': item.name,
        'price': item.originalPrice,
        'original_price': item.originalPrice,
        'discounted_price': item.discountedPrice,
        'description': item.description,
        'food_type': item.foodType,
      }).toList();
      
      // Initialize local quantities from controller, but only for THIS buy item
      _localGetItemQuantities.clear();
      for (var item in items) {
        print("🛒 Processing ${item.name} , $item");
        final compositeKey = '${widget.itemName}_${item.name}';
        final info = _promotionController.getItemInfoMap[compositeKey];
        if (info != null) {
          // Only copy quantities that were specifically selected for THIS buy item
          if (info.buyItemName == widget.itemName) {
            print("🛒 Copying quantity for ${item.name}: ${info.currentQuantity} ${info.buyItemName} ffdsdfss ${widget.itemName} hhdksjlkfd$info");
            _localGetItemQuantities[item.name] = info.currentQuantity;
          } else {
            _localGetItemQuantities[item.name] = 0;
          }
        } else {
          _localGetItemQuantities[item.name] = 0;
        }
      }
      
      print("🛒 Processed ${_discountedItems.length} items for UI display");
      print("🛒 Local quantities initialized: $_localGetItemQuantities");
    } catch (e) {
      print('🛒 Error loading discounted items from controller: $e');
      
      // Fall back to direct API call if controller fails
      try {
        print("🛒 Falling back to direct API call");
        final discountData = await ApiService.getDiscountedItems(widget.itemName);
        
        if (discountData['details'] != null && discountData['details'].isNotEmpty) {
          _discountedItems = discountData['details'];
          print("🛒 API returned ${_discountedItems.length} items directly");
          
          // Initialize local quantities from API data
          _localGetItemQuantities.clear();
          for (var item in discountData['details']) {
            final name = item['name']?.toString() ?? 'Unknown';
            _localGetItemQuantities[name] = 0;
          }
          
          // Also initialize the controller with these items
          await _promotionController.initializeGetItemInfo(_discountedItems, widget.itemName);
        }
      } catch (fallbackError) {
        print('🛒 Even fallback API call failed: $fallbackError');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _adjustGetItemQuantitiesIfNeeded() {
    // Get the total quantity from CartController
    final cartController = Provider.of<CartController>(context, listen: false);
    final existingQuantity = cartController.getTotalQuantity(widget.itemName) - 
                          (widget.groupIndex != null ? widget.initialQuantity : 0);
    
    // Calculate total quantity including current modal
    final totalQuantity = existingQuantity + _quantity;
    
    // Loop through all get items
    for (var detail in _discountedItems) {
      final getItemName = detail['name']?.toString() ?? 'Unknown';
      
      // Calculate new maximum based on TOTAL quantity
      final newMax = _promotionController.calculateMaxGetItems(
        widget.itemName, getItemName, totalQuantity
      );
      
      // If current quantity exceeds new maximum, reduce it
      if ((_localGetItemQuantities[getItemName] ?? 0) > newMax) {
        print("🛒 Adjusting $getItemName quantity from ${_localGetItemQuantities[getItemName]} to $newMax");
        _localGetItemQuantities[getItemName] = newMax;
      }
    }
  }

  Widget _buildDiscountedItemsSection() {
    if (_discountedItems.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promotional Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _discountedItems.length,
          itemBuilder: (context, index) {
            final detail = _discountedItems[index];
            return _buildGetItemCard(detail);
          },
        ),
      ],
    );
  }

  Widget _buildGetItemCard(Map<String, dynamic> detail) {
    final getItemName = detail['name']?.toString() ?? 'Unknown';
    
    // Get current quantity from local state for THIS customization
    final currentQuantity = _localGetItemQuantities[getItemName] ?? 0;
    
    // Extract details
    final originalPrice = (detail['original_price'] as num?)?.toDouble() ?? 0.0;
    final discountedPrice = (detail['discounted_price'] as num?)?.toDouble() ?? 
                           (detail['price'] as num?)?.toDouble() ?? originalPrice;
    final description = detail['description']?.toString() ?? '';
    final foodType = detail['food_type']?.toString() ?? '';
    
    // Calculate the total quantity of this get item selected with this specific buy item
    // across all customizations
    final compositeKey = '${widget.itemName}_$getItemName';
    final info = _promotionController.getItemInfoMap[compositeKey];
    final totalGetItemQuantity = info?.currentQuantity ?? 0;
    
    // Get the total quantity of this buy item from CartController
    final cartController = Provider.of<CartController>(context, listen: false);
    final existingQuantity = cartController.getTotalQuantity(widget.itemName) - 
                            (widget.groupIndex != null ? widget.initialQuantity : 0);
    
    // Calculate total quantity including current modal
    final totalBuyItemQuantity = existingQuantity + _quantity;
    
    // Calculate max get items allowed
    final maxGetItems = _promotionController.calculateMaxGetItems(
      widget.itemName, getItemName, totalBuyItemQuantity
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add an info panel showing total get items with this buy item
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total $getItemName with ${widget.itemName}:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalGetItemQuantity selected',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maximum available:',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '$maxGetItems',
                    style: TextStyle(
                      fontSize: 13,
                      color: totalGetItemQuantity >= maxGetItems ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Promotional Message when quantity > 0 (for THIS customization)
        if (currentQuantity > 0)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Selected in This Customization',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adding $currentQuantity $getItemName at ₹$discountedPrice each',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Main Item Card
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name
                Text(
                  getItemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),

                // Price and Food Type Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (discountedPrice < originalPrice) ...[
                          Text(
                            '₹$originalPrice',
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
                              fontSize: 16,
                            ),
                          ),
                        ] else
                          Text(
                            'Price: ₹$originalPrice',
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                    if (foodType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          foodType,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),

                // Description
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                
                // Quantity controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildQuantityControls(getItemName, currentQuantity, maxGetItems),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(
      String getItemName, int currentQuantity, int maxGetItems) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: currentQuantity > 0
              ? () => _handleQuantityChange(getItemName, currentQuantity - 1)
              : null,
        ),
        Text("$currentQuantity", style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: Icon(Icons.add,
              color: currentQuantity < maxGetItems
                  ? Colors.blue
                  : Colors.grey),
          onPressed: currentQuantity < maxGetItems
              ? () => _handleQuantityChange(getItemName, currentQuantity + 1)
              : null,
        ),
      ],
    );
  }

  void _handleQuantityChange(String getItemName, int newQuantity) {
    setState(() {
      // Reset other get items first if this one is being increased
      if (newQuantity > 0) {
        _localGetItemQuantities.forEach((name, qty) {
          if (name != getItemName && qty > 0) {
            // Reset other items
            _localGetItemQuantities[name] = 0;
          }
        });
      }
      
      // Update this item's quantity in local state only
      _localGetItemQuantities[getItemName] = newQuantity;
    });
  }

  double _calculateTotalPrice() {
    double basePrice = (widget.menuItem['discounted_price'] ?? widget.menuItem['price']).toDouble();
    double addonsPrice = _selectedAddons.values.fold(0.0, (total, addon) => total + (addon['price'] as double));
    return (basePrice + addonsPrice + _sizePriceIncrement) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize ${widget.itemName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quantity selector
                Row(
                  children: [
                    const Text('Quantity: '),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 0
                        ? () => setState(() {
                            _quantity--;
                            // When decreasing, check if any selected get items exceed new max
                            _adjustGetItemQuantitiesIfNeeded();
                          })
                        : null,
                    ),
                    Text('$_quantity'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        _quantity++;
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Size selection if available
                if (_hasSize) ...[
                  const Text(
                    'Select Size:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
  const SizedBox(height: 8),
  Wrap(
    spacing: 8,
    children: (widget.menuItem['sizes'] as List).map<Widget>((size) {
      String sizeName = size['name']?.toString() ?? 'Unknown';
      double priceIncrement = (size['price_increment'] as num?)?.toDouble() ?? 0.0;
      
      return ChoiceChip(
        label: Text('$sizeName (+₹$priceIncrement)'),
        selected: _selectedSize == sizeName,
        onSelected: (selected) {
          // Only allow selecting a different size
          // Prevent deselection of the current size
          if (selected && _selectedSize != sizeName) {
            setState(() {
              _selectedSize = sizeName;
              _sizePriceIncrement = priceIncrement;
            });
          }
          // If user tries to deselect the current size, ignore it
        },
      );
    }).toList(),
  ),
  const SizedBox(height: 16),
],
                
                // Add-ons section if available
                if (_addons.isNotEmpty) ...[
                  const Text(
                    'Add-ons:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._addons.map((addon) {
                    String addonName = addon['addon_item_name']?.toString() ?? 'Unknown';
                    double addonPrice = (addon['addon_price'] as num?)?.toDouble() ?? 0.0;
                    
                    return CheckboxListTile(
                      title: Text('$addonName (+₹$addonPrice)'),
                      value: _addonSelections[addonName] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _addonSelections[addonName] = value ?? false;
                          
                          if (value ?? false) {
                            // Add to selected add-ons
                            _selectedAddons[addonName] = {
                              'name': addonName,
                              'price': addonPrice,
                            };
                            _addonsTotal += addonPrice;
                          } else {
                            // Remove from selected add-ons
                            _selectedAddons.remove(addonName);
                            _addonsTotal -= addonPrice;
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                
                // Replace simple discounted items with new styled section
                if (_discountedItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDiscountedItemsSection(),
                ],
                
                const SizedBox(height: 16),
                
                // Special instructions / customization
                TextField(
                  controller: _customizationController,
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions',
                    border: OutlineInputBorder(),
                    hintText: 'E.g., No onions, extra spicy, etc.',
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                // Total price calculation
                Text(
                  'Total: ₹${_calculateTotalPrice()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitCustomization,
                    child: Text(
                      widget.groupIndex != null ? 'Update' : 'Add to Cart',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
  
  void _submitCustomization() {

      if (_quantity <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a quantity greater than zero'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

    final cartController = Provider.of<CartController>(context, listen: false);
    
    // Create a map of get items selected in this customization
    final Map<String, int> getItems = {};


      final existingQuantity = cartController.getTotalQuantity(widget.itemName) - 
                        (widget.groupIndex != null ? widget.initialQuantity : 0);
  final totalQuantity = existingQuantity + _quantity;



    _localGetItemQuantities.forEach((getItemName, quantity) {
      int maxAllowedQuantity = _promotionController.calculateMaxGetItems(
        widget.itemName, 
        getItemName, 
        totalQuantity
      );
      print('local ge item quantitites $getItemName $quantity ,jidfsdfjs ${_localGetItemQuantities[getItemName]}');
      if (quantity > 0) {
        getItems[getItemName] = quantity;
        print('Adding $quantity of $getItemName to get items');
        // Also update the promotion controller
        _promotionController.updateGetItemQuantity(getItemName, widget.itemName, quantity);
        print('Updated promotion controller with $quantity of $getItemName');
      }
      print('🛒 Checking $getItemName quantity: $quantity > $maxAllowedQuantity');
      if (quantity >= maxAllowedQuantity) {
         _promotionController.updateGetItemQuantity(getItemName, widget.itemName, maxAllowedQuantity);
        print('🚨 Quantity of $getItemName exceeds max allowed: $quantity > $maxAllowedQuantity');
      }
      print('🛒 Checking $getItemName quantity: $quantity == 0');
      if (quantity == 0 ){
        getItems[getItemName] = quantity;
        print('🚨 Quantity of $getItemName is zero');
         _promotionController.updateGetItemQuantity(getItemName, widget.itemName, quantity);
      }

      

    });
    
    // FIXED: The double quantity issue by adding items directly without duplicate updateGetItemInfo
    if (widget.groupIndex != null) {
      // Update existing customization
      cartController.updateCustomizedItem(
        itemName: widget.itemName,
        groupIndex: widget.groupIndex!,
        quantity: _quantity,
        addonSelections: _addonSelections,
        customization: _customizationController.text,
        addonsTotal: _calculateTotalPrice(),
        selectedAddons: _selectedAddons,
        hasSize: _hasSize,
        selectedSize: _selectedSize,
        sizePriceIncrement: _sizePriceIncrement * _quantity,
        skipPromotionUpdate: true,
        getItems: getItems, // Add the get items map
      );
    } else {
      // Add new customization
      cartController.addCustomizedItem(
        itemName: widget.itemName,
        quantity: _quantity,
        addonSelections: _addonSelections,
        customization: _customizationController.text,
        addonsTotal: _calculateTotalPrice(),
        selectedAddons: _selectedAddons,
        hasSize: _hasSize,
        selectedSize: _selectedSize,
        sizePriceIncrement: _sizePriceIncrement * _quantity,
        skipPromotionUpdate: true,
        getItems: getItems, // Add the get items map
      );
    }
    
    Navigator.pop(context);
  }
  
  @override
  void dispose() {
    _customizationController.dispose();
    super.dispose();
  }
}

// Helper function to show customization modal
void showCustomizationModal(BuildContext context, {
  required String itemName,
  required dynamic menuItem,
  int initialQuantity = 0,
  String initialCustomization = '',
  int? groupIndex,
}) {
  print("Showing customization modal for $itemName");
  print("Menu item data: $menuItem");
  print('Initial quantity: $initialQuantity');
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: CustomizationModal(
          itemName: itemName,
          menuItem: menuItem,
          initialQuantity: initialQuantity,
          initialCustomization: initialCustomization,
          groupIndex: groupIndex,
        ),
      ),
    ),
  );
}
















void showExistingCustomizationsModal(BuildContext context, {
  required String itemName,
  required dynamic menuItem,
}) {
  print("Showing existing customizations modal for $itemName");
  
  final cartController = Provider.of<CartController>(context, listen: false);
  var customizationGroups = cartController.itemOrderGroups[itemName] ?? [];
  
  // First, delete all zero-quantity customizations and track their indices
  List<int> toRemove = [];
  for (int i = customizationGroups.length - 1; i >= 0; i--) {
    int quantity = customizationGroups[i]['quantity'] as int? ?? 0;
    if (quantity <= 0) {
      toRemove.add(i);
    }
  }
  
  // Remove the zero-quantity customizations
  for (int index in toRemove) {
    cartController.removeCustomizedItem(itemName, index);
    print("🧹 Removed zero-quantity customization at index $index");
  }
  
  // Reload the (now updated) customization groups
  customizationGroups = cartController.itemOrderGroups[itemName] ?? [];
  
  // If there are no customizations left, show new customization modal directly
  if (customizationGroups.isEmpty) {
    print("No valid customizations found, showing new customization modal");
    showCustomizationModal(
      context,
      itemName: itemName,
      menuItem: menuItem,
    );
    return;
  }



  
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing $itemName in Cart',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: customizationGroups.length + 1, // +1 for "Add New" button
                itemBuilder: (context, index) {
                  // Last item is "Add New" button
                  if (index == customizationGroups.length) {
                    return ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.blue),
                      title: const Text('Add New Customization'),
                      onTap: () {
                        Navigator.pop(context);
                        showCustomizationModal(
                          context,
                          itemName: itemName,
                          menuItem: menuItem,
                        );
                      },
                    );
                  }
                  
                  // Display existing customization
                  var customization = customizationGroups[index];
                  int quantity = customization['quantity'] ?? 0;
                  String notes = customization['customization'] ?? '';
                  
                  // Format add-ons for display
                  String addons = '';
                  if (customization['selectedAddons'] != null &&
                      customization['selectedAddons'] is Map &&
                      customization['selectedAddons'].isNotEmpty) {
                    addons = customization['selectedAddons'].keys.join(', ');
                  }
                  
                  // Format size info if available
                  String sizeInfo = '';
                  if (customization['has_size'] == true && 
                      customization['selectedSize'] != null &&
                      customization['selectedSize'].isNotEmpty) {
                    sizeInfo = 'Size: ${customization['selectedSize']}';
                  }
                  
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantity: $quantity', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showCustomizationModal(
                                        context, 
                                        itemName: itemName,
                                        menuItem: menuItem,
                                        initialQuantity: quantity,
                                        initialCustomization: notes,
                                        groupIndex: index,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      cartController.removeCustomizedItem(itemName, index);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (sizeInfo.isNotEmpty)...[
                            const SizedBox(height: 4),
                            Text(sizeInfo),
                          ],
                          if (addons.isNotEmpty)...[
                            const SizedBox(height: 4),
                            Text('Add-ons: $addons'),
                          ],
                          if (notes.isNotEmpty)...[
                            const SizedBox(height: 4),
                            Text('Notes: $notes'),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}




