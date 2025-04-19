// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'menu_screen.dart';
// import 'order_screen.dart';
// import 'kds_screen.dart';
// import 'user.dart'; // Import User model
// import 'active_orders_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Login',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LoginScreen(),
//       routes: {
//         '/menu': (context) => const MenuScreen(),
//         '/order': (context) => const OrderScreen(),
//         '/kds': (context) => const KDSScreen(),
//         '/active_orders': (context) => ActiveOrdersScreen(), 
//       },
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return ListView(
//                     children: user.resources.keys.map((resource) {
//                       return ExpansionTile(
//                         title: Text(resource),
//                         children: user.resources[resource]!.map((action) {
//                           return ListTile(
//                             title: Text(action),
//                             onTap: () {
//                               Navigator.pop(context);
//                               if (resource == 'order_management' && action == 'read') {
//                                 Navigator.pushNamed(context, '/order');
//                                 Navigator.pushNamed(context, '/active_orders');
//                               } else if (resource == 'order_management_kds' && action == 'read') {
//                                 Navigator.pushNamed(context, '/kds');
//                               } else if (resource == 'menu_filter' && action == 'read') {
//                                 Navigator.pushNamed(context, '/menu');
//                               }
//                             },
//                           );
//                         }).toList(),
//                       );
//                     }).toList(),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text('Welcome, ${user.name}'),
//       ),
//     );
//   }
// }















































// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// // import 'menu_screen.dart';
// import './menu_screen/screens/menu_screen.dart';
// // import 'order_screen.dart';
// import './menu_screen/screens/orders_details_screen.dart';
// import 'kds_screen.dart';
// import 'user.dart'; // Import User model
// import 'active_orders_screen.dart';
// import 'local_notifications.dart';
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalNotifications.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Login',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LoginScreen(),
//       routes: {
//         '/menu': (context) => const MenuScreen(),
//         '/order': (context) => const OrderDetailsScreen(),
//         '/kds': (context) => const KDSScreen(),
//         '/active_orders': (context) => ActiveOrdersScreen(), 
//       },
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return ListView(
//                     children: user.resources.keys.map((resource) {
//                       return ExpansionTile(
//                         title: Text(resource),
//                         children: user.resources[resource]!.map((action) {
//                           return ListTile(
//                             title: Text(action),
//                             onTap: () {
//                               Navigator.pop(context);
//                               if (resource == 'order_management' && action == 'read') {
//                                 Navigator.pushNamed(context, '/order');
//                                 Navigator.pushNamed(context, '/active_orders');
//                               } else if (resource == 'order_management_kds' && action == 'read') {
//                                 Navigator.pushNamed(context, '/kds');
//                               } else if (resource == 'menu_filter' && action == 'read') {
//                                 Navigator.pushNamed(context, '/menu');
//                               }
//                             },
//                           );
//                         }).toList(),
//                       );
//                     }).toList(),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text('Welcome, ${user.name}'),
//       ),
//     );
//   }
// }



















// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'login_screen.dart';
// import 'menu_screen/screens/menu_screen.dart';
// import 'menu_screen/screens/orders_details_screen.dart';
// import 'kds_screen.dart';
// import 'active_orders_screen.dart';
// import 'local_notifications.dart';
// import 'user.dart';
// import 'menu_screen/controllers/menu_controller.dart' as menuCtrl;
// import 'menu_screen/controllers/cart_controller.dart';
// import 'menu_screen/controllers/promotion_controller.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalNotifications.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => PromotionController()),
        
//         ChangeNotifierProxyProvider<PromotionController, CartController>(
//           create: (context) => CartController(
//             Provider.of<PromotionController>(context, listen: false),
//           ),
//           update: (context, promotionController, previous) => 
//             previous ?? CartController(promotionController),
//         ),
        
//         ChangeNotifierProvider(create: (_) => menuCtrl.MenuController()),
//       ],
//       child: MaterialApp(
//         title: 'Restaurant POS',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           scaffoldBackgroundColor: Colors.grey[50],
//           appBarTheme: const AppBarTheme(
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             centerTitle: true,
//           ),
//         ),
//         home: const LoginScreen(),
//         routes: {
//           '/menu': (context) => const MenuScreen(),
//           '/order': (context) => const OrderDetailsScreen(),
//           '/kds': (context) => const KDSScreen(),
//           '/active_orders': (context) => ActiveOrdersScreen(), 
//         },
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return ListView(
//                     children: user.resources.keys.map((resource) {
//                       return ExpansionTile(
//                         title: Text(resource),
//                         children: user.resources[resource]!.map((action) {
//                           return ListTile(
//                             title: Text(action),
//                             onTap: () {
//                               Navigator.pop(context);
//                               if (resource == 'order_management' && action == 'read') {
//                                 Navigator.pushNamed(context, '/order');
//                                 Navigator.pushNamed(context, '/active_orders');
//                               } else if (resource == 'order_management_kds' && action == 'read') {
//                                 Navigator.pushNamed(context, '/kds');
//                               } else if (resource == 'menu_filter' && action == 'read') {
//                                 Navigator.pushNamed(context, '/menu');
//                               }
//                             },
//                           );
//                         }).toList(),
//                       );
//                     }).toList(),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text('Welcome, ${user.name}'),
//       ),
//     );
//   }
// }



























// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'login_screen.dart';
// import 'menu_screen/screens/menu_screen.dart';
// import 'menu_screen/screens/orders_details_screen.dart';
// import 'kds_screen.dart';
// import 'active_orders_screen.dart';
// import 'local_notifications.dart';
// import 'user.dart';
// import 'menu_screen/controllers/menu_controller.dart' as menuCtrl;
// import 'menu_screen/controllers/cart_controller.dart';
// import 'menu_screen/controllers/promotion_controller.dart';

// // Import table management components
// import 'table_screen/screens/floor_list_screen.dart';
// import 'table_screen/screens/table_management_screen.dart';
// import 'table_screen/services/floor_service.dart';


// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalNotifications.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => PromotionController()),
        
//         ChangeNotifierProxyProvider<PromotionController, CartController>(
//           create: (context) => CartController(
//             Provider.of<PromotionController>(context, listen: false),
//           ),
//           update: (context, promotionController, previous) => 
//             previous ?? CartController(promotionController),
//         ),
        
//         ChangeNotifierProvider(create: (_) => menuCtrl.MenuController()),
        
//         // Add just the floor service without WebSocket initialization
//         Provider<FloorService>(create: (_) => FloorService()),
//       ],
//       child: MaterialApp(
//         title: 'Restaurant POS',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           scaffoldBackgroundColor: Colors.grey[50],
//           appBarTheme: const AppBarTheme(
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             centerTitle: true,
//           ),
//         ),
//         home: const LoginScreen(),
//         routes: {
//           '/menu': (context) => const MenuScreen(),
//           '/order': (context) => const OrderDetailsScreen(),
//           '/kds': (context) => const KDSScreen(),
//           '/active_orders': (context) => ActiveOrdersScreen(),
          
//           // Use lazy-loading wrapper for table management
//           '/tables': (context) => const TableManagementWrapper(),
//         },
//         onGenerateRoute: (settings) {
//           if (settings.name == '/table_management') {
//             final tableId = settings.arguments as String;
//             return MaterialPageRoute(
//               builder: (context) => TableManagementScreen(tableId: tableId),
//             );
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }

// // Wrapper component that safely initializes table management
// class TableManagementWrapper extends StatefulWidget {
//   const TableManagementWrapper({Key? key}) : super(key: key);

//   @override
//   State<TableManagementWrapper> createState() => _TableManagementWrapperState();
// }

// class _TableManagementWrapperState extends State<TableManagementWrapper> {
//   bool _isInitialized = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     try {
//       // Delay just enough to allow Flutter to finish its initialization
//       await Future.delayed(const Duration(milliseconds: 100));
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize services: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Table Management')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 48),
//               const SizedBox(height: 16),
//               Text('Error: $_errorMessage'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _initializeServices,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Table Management')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Now it's safe to show the floor list
//     return const FloorListScreen();
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Check if user is a waiter based on permissions
//     final bool isWaiter = _isWaiter(user);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   // Create a base list of resources
//                   final resources = Map<String, List<String>>.from(user.resources);
                  
//                   // Add table management for waiters
//                   if (isWaiter && !resources.containsKey('table_management')) {
//                     resources['table_management'] = ['read', 'update'];
//                   }
                  
//                   return ListView(
//                     children: resources.keys.map((resource) {
//                       return ExpansionTile(
//                         title: Text(_getDisplayResource(resource)),
//                         children: resources[resource]!.map((action) {
//                           return ListTile(
//                             title: Text(_getDisplayAction(action)),
//                             onTap: () {
//                               Navigator.pop(context);
                              
//                               // Existing navigation logic
//                               if (resource == 'order_management' && action == 'read') {
//                                 Navigator.pushNamed(context, '/order');
//                                 Navigator.pushNamed(context, '/active_orders');
//                               } else if (resource == 'order_management_kds' && action == 'read') {
//                                 Navigator.pushNamed(context, '/kds');
//                               } else if (resource == 'menu_filter' && action == 'read') {
//                                 Navigator.pushNamed(context, '/menu');
//                               } 
                              
//                               // Add navigation logic for table management
//                               else if (resource == 'table_management' && 
//                                       (action == 'read' || action == 'update')) {
//                                 Navigator.pushNamed(context, '/tables');
//                               }
//                             },
//                           );
//                         }).toList(),
//                       );
//                     }).toList(),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome, ${user.name}', 
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
            
//             // Show table management button for waiters
//             if (isWaiter) ...[
//               _buildMenuButton(
//                 context,
//                 icon: Icons.table_bar,
//                 label: 'Table Management',
//                 onPressed: () => Navigator.pushNamed(context, '/tables'),
//               ),
//               const SizedBox(height: 20),
//             ],
            
//             // Order management button
//             if (user.resources.containsKey('order_management')) ...[
//               _buildMenuButton(
//                 context,
//                 icon: Icons.receipt_long,
//                 label: 'Orders',
//                 onPressed: () => Navigator.pushNamed(context, '/active_orders'),
//               ),
//               const SizedBox(height: 20),
//             ],
            
//             // Menu button
//             if (user.resources.containsKey('menu_filter')) ...[
//               _buildMenuButton(
//                 context,
//                 icon: Icons.menu_book,
//                 label: 'Menu',
//                 onPressed: () => Navigator.pushNamed(context, '/menu'),
//               ),
//               const SizedBox(height: 20),
//             ],
            
//             // Kitchen display button
//             if (user.resources.containsKey('order_management_kds')) ...[
//               _buildMenuButton(
//                 context,
//                 icon: Icons.kitchen,
//                 label: 'Kitchen Display',
//                 onPressed: () => Navigator.pushNamed(context, '/kds'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Helper method to determine if a user is a waiter
//   bool _isWaiter(User user) {
//     return user.resources.containsKey('menu_filter') && 
//            !user.resources.containsKey('order_management_kds');
//   }
  
//   // Helper method to build menu buttons
//   Widget _buildMenuButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       icon: Icon(icon, size: 24),
//       label: Text(label, style: const TextStyle(fontSize: 18)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         minimumSize: const Size(250, 60),
//       ),
//       onPressed: onPressed,
//     );
//   }
  
//   // Helper method to format resource names for display
//   String _getDisplayResource(String resource) {
//     switch (resource) {
//       case 'table_management':
//         return 'Table Management';
//       case 'order_management':
//         return 'Order Management';
//       case 'order_management_kds':
//         return 'Kitchen Display';
//       case 'menu_filter':
//         return 'Menu';
//       default:
//         return resource.split('_').map(_capitalize).join(' ');
//     }
//   }
  
//   // Helper method to format action names for display
//   String _getDisplayAction(String action) {
//     switch (action) {
//       case 'read':
//         return 'View';
//       case 'create':
//         return 'Create';
//       case 'update':
//         return 'Update';
//       case 'delete':
//         return 'Delete';
//       default:
//         return _capitalize(action);
//     }
//   }
  
//   // Capitalize the first letter of a string
//   String _capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
// }

































import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'menu_screen/screens/menu_screen.dart';
import 'menu_screen/screens/orders_details_screen.dart';
import 'kds_screen.dart';
import 'active_orders_screen.dart';
import 'local_notifications.dart';
import 'user.dart';
import 'menu_screen/controllers/menu_controller.dart' as menuCtrl;
import 'menu_screen/controllers/cart_controller.dart';
import 'menu_screen/controllers/promotion_controller.dart';

// Import table management components
import 'table_screen/screens/floor_list_screen.dart';
import 'table_screen/screens/table_management_screen.dart';
import 'table_screen/services/floor_service.dart';

// Import reservation management components
import 'reservation_screen/screens/dashboard_screen.dart';
import 'reservation_screen/services/reservation_service.dart';
import 'reservation_screen/services/websocket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotifications.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PromotionController()),
        
        ChangeNotifierProxyProvider<PromotionController, CartController>(
          create: (context) => CartController(
            Provider.of<PromotionController>(context, listen: false),
          ),
          update: (context, promotionController, previous) => 
            previous ?? CartController(promotionController),
        ),
        
        ChangeNotifierProvider(create: (_) => menuCtrl.MenuController()),
        
        // Add just the floor service without WebSocket initialization
        Provider<FloorService>(create: (_) => FloorService()),
      ],
      child: MaterialApp(
        title: 'Restaurant POS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: true,
          ),
        ),
        home: const LoginScreen(),
        routes: {
          '/menu': (context) => const MenuScreen(),
          '/order': (context) => const OrderDetailsScreen(),
          '/kds': (context) => const KDSScreen(),
          '/active_orders': (context) => ActiveOrdersScreen(),
          
          // Use lazy-loading wrapper for table management
          '/tables': (context) => const TableManagementWrapper(),
          
          // Add route for reservation management
          '/reservations': (context) => const ReservationManagementWrapper(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/table_management') {
            final tableId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TableManagementScreen(tableId: tableId),
            );
          }
          return null;
        },
      ),
    );
  }
}

// Wrapper component that safely initializes table management
class TableManagementWrapper extends StatefulWidget {
  const TableManagementWrapper({super.key});

  @override
  State<TableManagementWrapper> createState() => _TableManagementWrapperState();
}

class _TableManagementWrapperState extends State<TableManagementWrapper> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Delay just enough to allow Flutter to finish its initialization
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize services: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Table Management')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeServices,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Table Management')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Now it's safe to show the floor list
    return const FloorListScreen();
  }
}

// Wrapper component for reservation management
class ReservationManagementWrapper extends StatefulWidget {
  const ReservationManagementWrapper({super.key});

  @override
  State<ReservationManagementWrapper> createState() => _ReservationManagementWrapperState();
}

class _ReservationManagementWrapperState extends State<ReservationManagementWrapper> {
  bool _isInitialized = false;
  String? _errorMessage;
  ReservationWebSocketService? _websocketService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  @override
  void dispose() {
    // Clean up WebSocket connection when the screen is disposed
    _websocketService?.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Delay just enough to allow Flutter to finish its initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Initialize the WebSocket service
      _websocketService = ReservationWebSocketService();
      await _websocketService!.connect();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize reservation services: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservation Management')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeServices,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservation Management')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Create the reservation service to pass to the dashboard
    final reservationService = ReservationService(_websocketService!);
    
    // Now it's safe to show the reservation dashboard
    return DashboardScreen();
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Check if user is a waiter based on permissions
    final bool isWaiter = _isWaiter(user);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  // Create a base list of resources
                  final resources = Map<String, List<String>>.from(user.resources);
                  
                  // Add table management for waiters
                  if (isWaiter && !resources.containsKey('table_management')) {
                    resources['table_management'] = ['read', 'update'];
                  }
                  
                  // Add reservation management for waiters
                  if (isWaiter && !resources.containsKey('reservation_management')) {
                    resources['reservation_management'] = ['read', 'create', 'update'];
                  }
                  
                  return ListView(
                    children: resources.keys.map((resource) {
                      return ExpansionTile(
                        title: Text(_getDisplayResource(resource)),
                        children: resources[resource]!.map((action) {
                          return ListTile(
                            title: Text(_getDisplayAction(action)),
                            onTap: () {
                              Navigator.pop(context);
                              
                              // Existing navigation logic
                              if (resource == 'order_management' && action == 'read') {
                                Navigator.pushNamed(context, '/order');
                                Navigator.pushNamed(context, '/active_orders');
                              } else if (resource == 'order_management_kds' && action == 'read') {
                                Navigator.pushNamed(context, '/kds');
                              } else if (resource == 'menu_filter' && action == 'read') {
                                Navigator.pushNamed(context, '/menu');
                              } 
                              
                              // Add navigation logic for table management
                              else if (resource == 'table_management' && 
                                      (action == 'read' || action == 'update')) {
                                Navigator.pushNamed(context, '/tables');
                              }
                              
                              // Add navigation logic for reservation management
                              else if (resource == 'reservation_management' && 
                                      (action == 'read' || action == 'create' || action == 'update')) {
                                Navigator.pushNamed(context, '/reservations');
                              }
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user.name}', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Show table management button for waiters
            if (isWaiter) ...[
              _buildMenuButton(
                context,
                icon: Icons.table_bar,
                label: 'Table Management',
                onPressed: () => Navigator.pushNamed(context, '/tables'),
              ),
              const SizedBox(height: 20),
              
              // Add reservation management button for waiters
              _buildMenuButton(
                context,
                icon: Icons.event,
                label: 'Reservations',
                onPressed: () => Navigator.pushNamed(context, '/reservations'),
              ),
              const SizedBox(height: 20),
            ],
            
            // Order management button
            if (user.resources.containsKey('order_management')) ...[
              _buildMenuButton(
                context,
                icon: Icons.receipt_long,
                label: 'Orders',
                onPressed: () => Navigator.pushNamed(context, '/active_orders'),
              ),
              const SizedBox(height: 20),
            ],
            
            // Menu button
            if (user.resources.containsKey('menu_filter')) ...[
              _buildMenuButton(
                context,
                icon: Icons.menu_book,
                label: 'Menu',
                onPressed: () => Navigator.pushNamed(context, '/menu'),
              ),
              const SizedBox(height: 20),
            ],
            
            // Kitchen display button
            if (user.resources.containsKey('order_management_kds')) ...[
              _buildMenuButton(
                context,
                icon: Icons.kitchen,
                label: 'Kitchen Display',
                onPressed: () => Navigator.pushNamed(context, '/kds'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper method to determine if a user is a waiter
  bool _isWaiter(User user) {
    return user.resources.containsKey('menu_filter') && 
           !user.resources.containsKey('order_management_kds');
  }
  
  // Helper method to build menu buttons
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(250, 60),
      ),
      onPressed: onPressed,
    );
  }
  
  // Helper method to format resource names for display
  String _getDisplayResource(String resource) {
    switch (resource) {
      case 'table_management':
        return 'Table Management';
      case 'reservation_management':
        return 'Reservation Management';
      case 'order_management':
        return 'Order Management';
      case 'order_management_kds':
        return 'Kitchen Display';
      case 'menu_filter':
        return 'Menu';
      default:
        return resource.split('_').map(_capitalize).join(' ');
    }
  }
  
  // Helper method to format action names for display
  String _getDisplayAction(String action) {
    switch (action) {
      case 'read':
        return 'View';
      case 'create':
        return 'Create';
      case 'update':
        return 'Update';
      case 'delete':
        return 'Delete';
      default:
        return _capitalize(action);
    }
  }
  
  // Capitalize the first letter of a string
  String _capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}