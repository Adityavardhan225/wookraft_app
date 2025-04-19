// import 'package:flutter/material.dart';
// import '../models/floor_model.dart';
// import '../services/floor_service.dart';
// import '../services/websocket_service.dart';
// import '../widgets/floor_card.dart';
// import 'floor_detail_screen.dart';

// class FloorListScreen extends StatefulWidget {
//   const FloorListScreen({Key? key}) : super(key: key);

//   @override
//   _FloorListScreenState createState() => _FloorListScreenState();
// }

// class _FloorListScreenState extends State<FloorListScreen> {
//   late FloorService _floorService;
//   late WebSocketService _websocketService;
//   bool _isLoading = true;
//   List<FloorModel> _floors = [];
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     _floorService = FloorService();
//     _websocketService = WebSocketService();
    
//     try {
//       await _websocketService.connect();
//       _loadFloors();
      
//       // Listen for WebSocket updates
//       _websocketService.messageStream.listen((message) {
//         if (message['type'] == 'initial_data' || message['type'] == 'refresh_data') {
//           if (message['floors'] != null) {
//             setState(() {
//               _floors = (message['floors'] as List)
//                   .map((floor) => FloorModel.fromJson(floor))
//                   .toList();
//               _isLoading = false;
//             });
//           }
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadFloors() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final floors = await _floorService.getAllFloors();
      
//       setState(() {
//         _floors = floors;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load floors: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _websocketService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Restaurant Floors'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadFloors,
//             tooltip: 'Refresh floors',
//           ),
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () {
//           // Navigate to add floor screen
//           // Implementation would be added here
//         },
//         tooltip: 'Add new floor',
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             const Text(
//               'Error',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 _errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               onPressed: _loadFloors,
//             ),
//           ],
//         ),
//       );
//     }

//     if (_floors.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.view_agenda_outlined, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'No floors found',
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Add your first floor to get started',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _floors.length,
//       itemBuilder: (context, index) {
//         final floor = _floors[index];
//         return FloorCard(
//           floor: floor,
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => FloorDetailScreen(floorId: floor.id),
//               ),
//             ).then((_) => _loadFloors()); // Refresh after returning
//           },
//         );
//       },
//     );
//   }
// }
































import 'package:flutter/material.dart';
import '../models/floor_model.dart';
import '../services/floor_service.dart';
import '../services/websocket_service.dart';
import 'floor_detail_screen.dart';

class FloorListScreen extends StatefulWidget {
  const FloorListScreen({super.key});

  @override
  _FloorListScreenState createState() => _FloorListScreenState();
}

class _FloorListScreenState extends State<FloorListScreen> with SingleTickerProviderStateMixin {
  late FloorService _floorService;
  late WebSocketService _websocketService;
  bool _isLoading = true;
  List<FloorModel> _floors = [];
  String? _errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _floorService = FloorService();
    _websocketService = WebSocketService();
    
    try {
      await _websocketService.connect();
      await _loadFloors();
      
      // Listen for WebSocket updates
      _websocketService.messageStream.listen((message) {
        if (message['type'] == 'initial_data' || message['type'] == 'refresh_data') {
          if (message['floors'] != null) {
            setState(() {
              _floors = (message['floors'] as List)
                  .map((floor) => FloorModel.fromJson(floor))
                  .toList();
              _isLoading = false;
            });
            _animationController.forward(from: 0.0);
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFloors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final floors = await _floorService.getAllFloors();
      
      setState(() {
        _floors = floors;
        _isLoading = false;
      });
      
      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load floors: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _websocketService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Floors'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFloors,
            tooltip: 'Refresh floors',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add floor feature coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        tooltip: 'Add new floor',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_floors.isEmpty) {
      return _buildEmptyState();
    }

    // Decide between grid or list based on screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildGridView();
        } else {
          return _buildListView();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading floors...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              onPressed: _initializeServices,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business,
                size: 64,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Floors Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first floor to start managing tables.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add First Floor'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add floor feature coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _floors.length,
          itemBuilder: (context, index) {
            final floor = _floors[index];
            
            // Calculate staggered animation delay
            final delay = index * 0.1;
            final animValue = _animationController.value > delay
                ? (_animationController.value - delay) / (1 - delay)
                : 0.0;
            
            // Apply animation transforms
            return Transform.scale(
              scale: 0.9 + (0.1 * animValue),
              child: Opacity(
                opacity: animValue,
                child: _buildFloorCard(floor),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildListView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _floors.length,
          itemBuilder: (context, index) {
            final floor = _floors[index];
            
            // Calculate staggered animation delay
            final delay = index * 0.1;
            final animValue = _animationController.value > delay
                ? (_animationController.value - delay) / (1 - delay)
                : 0.0;
            
            // Apply animation transforms
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animValue)),
              child: Opacity(
                opacity: animValue,
                child: _buildFloorCard(floor),
              ),
            );
          },
        );
      }
    );
  }

// Only the _buildFloorCard method needs to be fixed:

Widget _buildFloorCard(FloorModel floor) {
  return Card(
    elevation: 4,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FloorDetailScreen(floorId: floor.id),
          ),
        ).then((_) => _loadFloors());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with floor name and icon
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: Text(
                    floor.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    floor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.table_bar, 
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Tables',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (floor.description != null && floor.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        floor.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Spacer(),
            
            // View details button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FloorDetailScreen(floorId: floor.id),
                    ),
                  ).then((_) => _loadFloors());
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Manage Tables'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Color _getOccupancyColor(double rate) {
    if (rate < 0.3) return Colors.green;
    if (rate < 0.7) return Colors.orange;
    return Colors.red;
  }
  
  String _getOccupancyStatus(double rate) {
    if (rate < 0.3) return 'Low';
    if (rate < 0.7) return 'Moderate';
    if (rate < 0.9) return 'High';
    return 'Full';
  }
}