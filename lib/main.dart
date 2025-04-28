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

// // Import reservation management components
// import 'reservation_screen/screens/dashboard_screen.dart';
// import 'reservation_screen/services/reservation_service.dart';
// import 'reservation_screen/services/websocket_service.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalNotifications.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

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
          
//           // Add route for reservation management
//           '/reservations': (context) => const ReservationManagementWrapper(),
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
//   const TableManagementWrapper({super.key});

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

// // Wrapper component for reservation management
// class ReservationManagementWrapper extends StatefulWidget {
//   const ReservationManagementWrapper({super.key});

//   @override
//   State<ReservationManagementWrapper> createState() => _ReservationManagementWrapperState();
// }

// class _ReservationManagementWrapperState extends State<ReservationManagementWrapper> {
//   bool _isInitialized = false;
//   String? _errorMessage;
//   ReservationWebSocketService? _websocketService;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }
  
//   @override
//   void dispose() {
//     // Clean up WebSocket connection when the screen is disposed
//     _websocketService?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeServices() async {
//     try {
//       // Delay just enough to allow Flutter to finish its initialization
//       await Future.delayed(const Duration(milliseconds: 100));
      
//       // Initialize the WebSocket service
//       _websocketService = ReservationWebSocketService();
//       await _websocketService!.connect();
      
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize reservation services: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Reservation Management')),
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
//         appBar: AppBar(title: const Text('Reservation Management')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Create the reservation service to pass to the dashboard
//     final reservationService = ReservationService(_websocketService!);
    
//     // Now it's safe to show the reservation dashboard
//     return DashboardScreen();
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({super.key, required this.user});

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
                  
//                   // Add reservation management for waiters
//                   if (isWaiter && !resources.containsKey('reservation_management')) {
//                     resources['reservation_management'] = ['read', 'create', 'update'];
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
                              
//                               // Add navigation logic for reservation management
//                               else if (resource == 'reservation_management' && 
//                                       (action == 'read' || action == 'create' || action == 'update')) {
//                                 Navigator.pushNamed(context, '/reservations');
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
              
//               // Add reservation management button for waiters
//               _buildMenuButton(
//                 context,
//                 icon: Icons.event,
//                 label: 'Reservations',
//                 onPressed: () => Navigator.pushNamed(context, '/reservations'),
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
//       case 'reservation_management':
//         return 'Reservation Management';
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

// // Import reservation management components
// import 'reservation_screen/screens/dashboard_screen.dart';
// import 'reservation_screen/services/reservation_service.dart';
// import 'reservation_screen/services/websocket_service.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   LocalNotifications.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

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
          
//           // Add route for reservation management
//           '/reservations': (context) => const ReservationManagementWrapper(),
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
//   const TableManagementWrapper({super.key});

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

// // Wrapper component for reservation management
// class ReservationManagementWrapper extends StatefulWidget {
//   const ReservationManagementWrapper({super.key});

//   @override
//   State<ReservationManagementWrapper> createState() => _ReservationManagementWrapperState();
// }

// class _ReservationManagementWrapperState extends State<ReservationManagementWrapper> {
//   bool _isInitialized = false;
//   String? _errorMessage;
//   ReservationWebSocketService? _websocketService;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }
  
//   @override
//   void dispose() {
//     // Clean up WebSocket connection when the screen is disposed
//     _websocketService?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeServices() async {
//     try {
//       // Delay just enough to allow Flutter to finish its initialization
//       await Future.delayed(const Duration(milliseconds: 100));
      
//       // Initialize the WebSocket service
//       _websocketService = ReservationWebSocketService();
//       await _websocketService!.connect();
      
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize reservation services: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Reservation Management')),
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
//         appBar: AppBar(title: const Text('Reservation Management')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Create the reservation service to pass to the dashboard
//     final reservationService = ReservationService(_websocketService!);
    
//     // Now it's safe to show the reservation dashboard
//     return DashboardScreen();
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final User user;

//   const HomeScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     // Check if user is a waiter based on permissions
//     final bool isWaiter = _isWaiter(user);
//     final size = MediaQuery.of(context).size;
//     final theme = Theme.of(context);
//     final primaryColor = theme.primaryColor;
    
//     // Get the user role name
//     final String roleName = _getRoleName(user, isWaiter);

//     // Count active permissions
//     final int permissionCount = user.resources.values
//         .fold(0, (sum, permissions) => sum + permissions.length);

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Custom App Bar with Profile
//           SliverAppBar(
//             expandedHeight: 180.0,
//             pinned: true,
//             floating: false,
//             backgroundColor: primaryColor,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       primaryColor,
//                       primaryColor.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Row(
//                       children: [
//                         // User avatar
//                         CircleAvatar(
//                           radius: 45,
//                           backgroundColor: Colors.white.withOpacity(0.9),
//                           child: Text(
//                             user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
//                             style: TextStyle(
//                               fontSize: 36,
//                               fontWeight: FontWeight.bold,
//                               color: primaryColor,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//                         // User details
//                         Expanded(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 8),
//                               Text(
//                                 user.name,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 roleName,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'ID:',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.white.withOpacity(0.9),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Logout button
//                         IconButton(
//                           icon: const Icon(
//                             Icons.logout,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text('Logout'),
//                                 content: const Text('Are you sure you want to logout?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     child: const Text('CANCEL'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(builder: (_) => const LoginScreen()),
//                                       );
//                                     },
//                                     child: const Text('LOGOUT'),
//                                     style: TextButton.styleFrom(
//                                       foregroundColor: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                           tooltip: 'Logout',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
          
//           // User stats section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildStatCard(
//                       context,
//                       icon: Icons.verified_user,
//                       title: 'Role',
//                       value: roleName,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildStatCard(
//                       context,
//                       icon: Icons.shield,
//                       title: 'Permissions',
//                       value: '$permissionCount Active',
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildStatCard(
//                       context,
//                       icon: Icons.access_time,
//                       title: 'Session',
//                       value: 'Active',
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Menu section title
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.dashboard_customize, color: primaryColor),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Dashboard',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     width: 50,
//                     height: 3,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Main menu grid
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             sliver: SliverGrid(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.1,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               delegate: SliverChildListDelegate([
//                 // Conditional menu items
                
//                 // Table Management button for waiters
//                 if (isWaiter)
//                   _buildMenuCard(
//                     context,
//                     icon: Icons.table_bar,
//                     title: 'Table Management',
//                     description: 'Manage restaurant tables and seating',
//                     color: const Color(0xFF4CAF50),
//                     onTap: () => Navigator.pushNamed(context, '/tables'),
//                   ),
                
//                 // Reservation button for waiters  
//                 if (isWaiter)
//                   _buildMenuCard(
//                     context,
//                     icon: Icons.event_note,
//                     title: 'Reservations',
//                     description: 'Manage customer bookings and tables',
//                     color: const Color(0xFF3F51B5),
//                     onTap: () => Navigator.pushNamed(context, '/reservations'),
//                   ),
                
//                 // Orders button
//                 if (user.resources.containsKey('order_management'))
//                   _buildMenuCard(
//                     context,
//                     icon: Icons.receipt_long,
//                     title: 'Orders',
//                     description: 'View and manage active orders',
//                     color: const Color(0xFFFF9800),
//                     onTap: () => Navigator.pushNamed(context, '/active_orders'),
//                   ),
                
//                 // Menu button  
//                 if (user.resources.containsKey('menu_filter'))
//                   _buildMenuCard(
//                     context,
//                     icon: Icons.menu_book,
//                     title: 'Menu',
//                     description: 'Browse and order from restaurant menu',
//                     color: const Color(0xFFE91E63),
//                     onTap: () => Navigator.pushNamed(context, '/menu'),
//                   ),
                
//                 // Kitchen display button  
//                 if (user.resources.containsKey('order_management_kds'))
//                   _buildMenuCard(
//                     context,
//                     icon: Icons.kitchen,
//                     title: 'Kitchen Display',
//                     description: 'View orders ready for preparation',
//                     color: const Color(0xFF9C27B0),
//                     onTap: () => Navigator.pushNamed(context, '/kds'),
//                   ),
//               ]),
//             ),
//           ),
          
//           // Permissions section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.security, color: primaryColor),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Your Permissions',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     width: 50,
//                     height: 3,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Permissions list
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final resourceName = user.resources.keys.elementAt(index);
//                   final permissions = user.resources[resourceName]!;
                  
//                   return Card(
//                     elevation: 1,
//                     margin: const EdgeInsets.only(bottom: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _getDisplayResource(resourceName),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: permissions.map((permission) {
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: primaryColor.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(color: primaryColor.withOpacity(0.3)),
//                                 ),
//                                 child: Text(
//                                   _getDisplayAction(permission),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: primaryColor,
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 childCount: user.resources.length,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build statistics card widget
//   Widget _buildStatCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 20,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build menu card widget
//   Widget _buildMenuCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String description,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               color,
//               color.withOpacity(0.8),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 description,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 13,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Helper method to determine if a user is a waiter
//   bool _isWaiter(User user) {
//     return user.resources.containsKey('menu_filter') && 
//            !user.resources.containsKey('order_management_kds');
//   }
  
//   // Helper method to get role name
//   String _getRoleName(User user, bool isWaiter) {
//     if (isWaiter) {
//       return 'Waiter';
//     } else if (user.resources.containsKey('order_management_kds')) {
//       return 'Kitchen Staff';
//     } else if (user.resources.length > 3) {
//       return 'Manager';
//     } else {
//       return 'Staff Member';
//     }
//   }
  
//   // Helper method to format resource names for display
//   String _getDisplayResource(String resource) {
//     switch (resource) {
//       case 'table_management':
//         return 'Table Management';
//       case 'reservation_management':
//         return 'Reservation Management';
//       case 'order_management':
//         return 'Order Management';
//       case 'order_management_kds':
//         return 'Kitchen Display';
//       case 'menu_filter':
//         return 'Menu Access';
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
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isSmallScreen = size.width < 360;
    
    // Get the user role name
    final String roleName = _getRoleName(user, isWaiter);

    // Count active permissions
    final int permissionCount = user.resources.values
        .fold(0, (sum, permissions) => sum + permissions.length);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile
          SliverAppBar(
            expandedHeight: isSmallScreen ? 160.0 : 180.0,
            pinned: true,
            floating: false,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                    child: Row(
                      children: [
                        // User avatar
                        CircleAvatar(
                          radius: isSmallScreen ? 40 : 45,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 30 : 36,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 16 : 20),
                        // User details
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 22 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                roleName,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID:',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout button
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        );
                                      },
                                      child: const Text('LOGOUT'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: isSmallScreen ? 24 : 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // User stats section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.verified_user,
                      title: 'Role',
                      value: roleName,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.shield,
                      title: 'Permissions',
                      value: '$permissionCount Active',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.access_time,
                      title: 'Session',
                      value: 'Active',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Menu section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dashboard_customize, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main menu grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                childAspectRatio: 1.0, // More square shape
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate([
                // Conditional menu items
                
                // Table Management button for waiters
                if (isWaiter)
                  _buildMenuCard(
                    context,
                    icon: Icons.table_bar,
                    title: 'Table Management',
                    description: 'Manage restaurant tables and seating',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pushNamed(context, '/tables'),
                  ),
                
                // Reservation button for waiters  
                if (isWaiter)
                  _buildMenuCard(
                    context,
                    icon: Icons.event_note,
                    title: 'Reservations',
                    description: 'Manage customer bookings and tables',
                    color: const Color(0xFF3F51B5),
                    onTap: () => Navigator.pushNamed(context, '/reservations'),
                  ),
                
                // Orders button
                if (user.resources.containsKey('order_management'))
                  _buildMenuCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    description: 'View and manage active orders',
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.pushNamed(context, '/active_orders'),
                  ),
                
                // Menu button  
                if (user.resources.containsKey('menu_filter'))
                  _buildMenuCard(
                    context,
                    icon: Icons.menu_book,
                    title: 'Menu',
                    description: 'Browse and order from restaurant menu',
                    color: const Color(0xFFE91E63),
                    onTap: () => Navigator.pushNamed(context, '/menu'),
                  ),
                
                // Kitchen display button  
                if (user.resources.containsKey('order_management_kds'))
                  _buildMenuCard(
                    context,
                    icon: Icons.kitchen,
                    title: 'Kitchen Display',
                    description: 'View orders ready for preparation',
                    color: const Color(0xFF9C27B0),
                    onTap: () => Navigator.pushNamed(context, '/kds'),
                  ),
              ]),
            ),
          ),
          
          // Permissions section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Your Permissions',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Permissions list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final resourceName = user.resources.keys.elementAt(index);
                  final permissions = user.resources[resourceName]!;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.06),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getResourceIcon(resourceName),
                                  size: 16,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getDisplayResource(resourceName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: permissions.map((permission) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _getDisplayAction(permission),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: user.resources.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get appropriate icon for each resource
  IconData _getResourceIcon(String resource) {
    switch (resource) {
      case 'table_management':
        return Icons.table_bar;
      case 'reservation_management':
        return Icons.event_note;
      case 'order_management':
        return Icons.receipt_long;
      case 'order_management_kds':
        return Icons.kitchen;
      case 'menu_filter':
        return Icons.menu_book;
      default:
        return Icons.folder_open;
    }
  }
  
  // Build statistics card widget
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust padding based on screen size
    final horizontalPadding = screenWidth < 360 ? 8.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Build menu card widget
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Hero(
      tag: 'menu_$title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.75),
                ],
                stops: const [0.2, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to determine if a user is a waiter
  bool _isWaiter(User user) {
    return user.resources.containsKey('menu_filter') && 
           !user.resources.containsKey('order_management_kds');
  }
  
  // Helper method to get role name
  String _getRoleName(User user, bool isWaiter) {
    if (isWaiter) {
      return 'Waiter';
    } else if (user.resources.containsKey('order_management_kds')) {
      return 'Kitchen Staff';
    } else if (user.resources.length > 3) {
      return 'Manager';
    } else {
      return 'Staff Member';
    }
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
        return 'Menu Access';
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