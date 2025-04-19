import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/menu_controller.dart' as menuCtrl;
import '../controllers/cart_controller.dart';
import '../controllers/promotion_controller.dart';
import '../widgets/item_card.dart';
import '../widgets/customization_modal.dart';
import '../widgets/category_modal.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'orders_details_screen.dart';
import '../../login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuController = Provider.of<menuCtrl.MenuController>(context, listen: false);
      menuController.initializeMenu();
      
      // Set up search controller listener
      _searchController.addListener(() {
        menuController.search(_searchController.text);
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Handle adding/updating item quantity
  void _handleAddItem(BuildContext context, dynamic item) async {
    final String itemName = item['name'];
    final cartController = Provider.of<CartController>(context, listen: false);
    final menuController = Provider.of<menuCtrl.MenuController>(context, listen: false);



    
    
  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  // Check all features asynchronously
  final bool hasAddons = await menuController.hasAddons(itemName);
  final bool hasSizes = await menuController.hasSizes(itemName);
  final bool hasDiscounts = await menuController.hasDiscounts(itemName);
  print('debug has discount $hasDiscounts');
  // Hide loading
  if (context.mounted) {
    Navigator.of(context).pop();
  }
    
    // If the item needs customization, show the modal
    if (hasAddons || hasSizes || hasDiscounts) {
    // Check if item already has customizations in cart
    if (cartController.hasExistingCustomizations(itemName)) {
      // Show existing customizations modal
      showExistingCustomizationsModal(
        context,
        itemName: itemName,
        menuItem: item,
      );
    } else {
      // Show normal customization modal for new item
      showCustomizationModal(
        context,
        itemName: itemName,
        menuItem: item,
        initialQuantity: 1,
        initialCustomization: cartController.itemCustomizations[itemName] ?? '',
      );
    }
  }else {
      // For simple items without customization
      final currentQty = cartController.getTotalQuantity(itemName);
      if (currentQty == 0) {
        cartController.incrementQuantity(itemName);
      } else {
        // Show an action sheet to increment, decrement, or customize
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add One More'),
                  onTap: () {
                    cartController.incrementQuantity(itemName);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.remove),
                  title: const Text('Remove One'),
                  onTap: () {
                    cartController.decrementQuantity(itemName, context);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Customize'),
                  onTap: () {
                    Navigator.pop(context);
                    _customizeItem(itemName);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
  
  // Show customization modal
  void _customizeItem(String itemName) {
    final menuController = Provider.of<menuCtrl.MenuController>(context, listen: false);
    final item = menuController.findMenuItem(itemName);
    if (item != null) {
      showCustomizationModal(
        context,
        itemName: itemName,
        menuItem: item,
      );
    }
  }
  
  // Navigate to order details screen
  void _navigateToOrderDetails() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderDetailsScreen(),
      ),
    );
    
    if (result == true) {
      // Order was completed, refresh the menu screen
      final menuController = Provider.of<menuCtrl.MenuController>(context, listen: false);
      menuController.refreshMenuItems();
    }
  }


















@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Menu Items'),
      actions: [
        // Add refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Store Data',
          onPressed: () {
            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset Store Data'),
                content: const Text(
                  'This will clear all cart items and reset promotional data. '
                  'This action cannot be undone.'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final cartController = Provider.of<CartController>(
                        context, 
                        listen: false
                      );
                      cartController.refreshAllStoreData();
                      
                      // Also refresh menu data
                      final menuController = Provider.of<menuCtrl.MenuController>(
                        context, 
                        listen: false
                      );
                      menuController.refreshMenuItems();
                      
                      Navigator.pop(context);
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Store data refreshed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Reset', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        // Keep existing logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await StorageService.clearUserSession();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    ),
    body: Consumer3<menuCtrl.MenuController, CartController, PromotionController>(
      builder: (context, menuController, cartController, promotionController, _) {
        return Stack(
          children: [
            Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                
                // Food type filters
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: menuController.foodTypes.length,
                    itemBuilder: (context, index) {
                      final foodType = menuController.foodTypes[index];
                      final isSelected = menuController.selectedFoodTypes.contains(foodType['name']);
                      
                      return GestureDetector(
                        onTap: () => menuController.toggleFoodType(foodType['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              foodType['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Menu items list or loading indicator
                if (menuController.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (menuController.errorMessage.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        menuController.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: menuController.menuItems.isEmpty
                      ? const Center(child: Text('No items found'))
                      : ListView.builder(
                          itemCount: menuController.menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuController.menuItems[index];
                            final itemName = item['name'];
                            final isExpanded = menuController.isExpandedMap[itemName] ?? false;
                            
                            return ItemCard(
                              item: item,
                              onAddItem: _handleAddItem,
                              onCustomize: _customizeItem,
                              onToggleExpanded: menuController.toggleExpanded,
                              isExpanded: isExpanded,
                            );
                          },
                        ),
                  ),
              ],
            ),
            
            // Category modal
            if (menuController.isCategoryModalVisible)
              Positioned(
                bottom: 10,
                left: 30,
                right: 30,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Categories',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: menuController.categories.length,
                          itemBuilder: (context, index) {
                            final category = menuController.categories[index];
                            return ListTile(
                              title: Text(category['name']),
                              onTap: () => menuController.setCategory(category['name']),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        );
      },
    ),
    floatingActionButton: Consumer<CartController>(
      builder: (context, cartController, child) {
        return Stack(
          children: [
            if (!cartController.isEmpty)
              Positioned(
                bottom: 70,
                right: 0,
                child: FloatingActionButton.extended(
                  onPressed: _navigateToOrderDetails,
                  label: Row(
                    children: [
                      Text('${cartController.totalItemCount} items'),
                      const SizedBox(width: 8),
                      const Icon(Icons.shopping_cart),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  final menuController = Provider.of<menuCtrl.MenuController>(context, listen: false);
                  menuController.toggleCategoryModal();
                },
                child: const Icon(Icons.category),
              ),
            ),
          ],
        );
      },
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}
}
