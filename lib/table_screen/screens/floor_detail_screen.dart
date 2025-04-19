// import 'package:flutter/material.dart';
// import '../models/floor_model.dart';
// import '../models/table_model.dart';
// import '../services/floor_service.dart';
// import '../services/table_service.dart';
// import '../services/websocket_service.dart';
// import '../widgets/table_grid.dart';
// import '../widgets/section_filter.dart';
// import 'table_management_screen.dart';

// class FloorDetailScreen extends StatefulWidget {
//   final String floorId;
  
//   const FloorDetailScreen({
//     Key? key, 
//     required this.floorId,
//   }) : super(key: key);

//   @override
//   _FloorDetailScreenState createState() => _FloorDetailScreenState();
// }

// class _FloorDetailScreenState extends State<FloorDetailScreen> {
//   late FloorService _floorService;
//   late TableService _tableService;
//   late WebSocketService _websocketService;
  
//   bool _isLoading = true;
//   FloorModel? _floor;
//   List<TableModel> _tables = [];
//   List<TableModel> _filteredTables = [];
//   TableSection? _selectedSection;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }
  
//   Future<void> _initializeServices() async {
//     _websocketService = WebSocketService();
    
//     try {
//       await _websocketService.connect();
      
//       // Fix: No arguments for FloorService and only WebSocketService for TableService
//       _floorService = FloorService();
//       _tableService = TableService(_websocketService);
      
//       await _loadFloorAndTables();
      
//       // Listen for WebSocket updates
//       _websocketService.messageStream.listen((message) {
//         if (message['type'] == 'table_status_updated') {
//           _handleTableUpdate(message['data']);
//         } else if (message['type'] == 'refresh_data' && message['tables'] != null) {
//           _updateTables(message['tables']);
//         } else if (message['type'] == 'initial_data') {
//           if (message['tables'] != null) {
//             _updateTables(message['tables']);
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

//   void _handleTableUpdate(dynamic tableData) {
//     final updatedTable = TableModel.fromJson(tableData);
    
//     setState(() {
//       // Update the table in our list
//       final index = _tables.indexWhere((t) => t.id == updatedTable.id);
//       if (index >= 0) {
//         _tables[index] = updatedTable;
//         _applyFilters();
//       }
//     });
//   }
  
//   void _updateTables(dynamic tablesData) {
//     setState(() {
//       _tables = (tablesData as List)
//           .map((table) => TableModel.fromJson(table))
//           .where((table) => table.floorId == widget.floorId)
//           .toList();
//       _applyFilters();
//       _isLoading = false;
//     });
//   }

//   Future<void> _loadFloorAndTables() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final floor = await _floorService.getFloorById(widget.floorId);
//       final tables = await _tableService.getTablesByFloor(widget.floorId);
      
//       setState(() {
//         _floor = floor;
//         _tables = tables;
//         _filteredTables = List.from(_tables);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load floor data: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
  
//   void _applyFilters() {
//     setState(() {
//       if (_selectedSection != null) {
//         _filteredTables = _tables
//             .where((table) => table.section == _selectedSection)
//             .toList();
//       } else {
//         _filteredTables = List.from(_tables);
//       }
//     });
//   }
  
//   void _onSectionChanged(TableSection? section) {
//     setState(() {
//       _selectedSection = section;
//       _applyFilters();
//     });
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
//         title: _floor == null 
//             ? const Text('Floor Detail') 
//             : Text(_floor!.name),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadFloorAndTables,
//             tooltip: 'Refresh tables',
//           ),
//         ],
//       ),
//       body: _buildBody(),
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
//               onPressed: _loadFloorAndTables,
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Section filter
//         SectionFilter(
//           selectedSection: _selectedSection,
//           onSectionChanged: _onSectionChanged,
//         ),
        
//         // Floor description if available
//         if (_floor?.description != null && _floor!.description!.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue[700]),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _floor!.description!,
//                         style: TextStyle(color: Colors.blue[700]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
        
//         // Tables count summary
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Row(
//             children: [
//               Text(
//                 '${_filteredTables.length} Tables',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold, 
//                   fontSize: 16,
//                 ),
//               ),
//               const Spacer(),
//               if (_selectedSection != null)
//                 Chip(
//                   label: Text(_selectedSection!.displayName),
//                   deleteIcon: const Icon(Icons.close, size: 16),
//                   onDeleted: () => _onSectionChanged(null),
//                 ),
//             ],
//           ),
//         ),
        
//         // Table grid
//         Expanded(
//           child: _filteredTables.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.table_bar, size: 64, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'No tables found',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                       if (_selectedSection != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             'Try removing the section filter',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                     ],
//                   ),
//                 )
//               : TableGrid(
//                   tables: _filteredTables,
//                   onTableTap: (table) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => TableManagementScreen(tableId: table.id),
//                       ),
//                     ).then((_) => _loadFloorAndTables());
//                   },
//                 ),
//         ),
//       ],
//     );
//   }
// }

















import 'package:flutter/material.dart';
import '../models/floor_model.dart';
import '../models/table_model.dart';
import '../services/floor_service.dart';
import '../services/table_service.dart';
import '../services/websocket_service.dart';
import '../widgets/section_filter.dart';
import 'table_management_screen.dart';

class FloorDetailScreen extends StatefulWidget {
  final String floorId;
  
  const FloorDetailScreen({
    super.key, 
    required this.floorId,
  });

  @override
  _FloorDetailScreenState createState() => _FloorDetailScreenState();
}

class _FloorDetailScreenState extends State<FloorDetailScreen> {
  late FloorService _floorService;
  late TableService _tableService;
  late WebSocketService _websocketService;
  
  bool _isLoading = true;
  FloorModel? _floor;
  List<TableModel> _tables = [];
  List<TableModel> _filteredTables = [];
  TableSection? _selectedSection;
  String? _errorMessage;
  bool _showFloorInfo = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    _websocketService = WebSocketService();
    
    try {
      await _websocketService.connect();
      
      _floorService = FloorService();
      _tableService = TableService(_websocketService);
      
      await _loadFloorAndTables();
      
      // Listen for WebSocket updates
      _websocketService.messageStream.listen((message) {
        if (message['type'] == 'table_status_updated') {
          _handleTableUpdate(message['data']);
        } else if (message['type'] == 'refresh_data' && message['tables'] != null) {
          _updateTables(message['tables']);
        } else if (message['type'] == 'initial_data') {
          if (message['tables'] != null) {
            _updateTables(message['tables']);
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

  void _handleTableUpdate(dynamic tableData) {
    final updatedTable = TableModel.fromJson(tableData);
    
    setState(() {
      // Update the table in our list
      final index = _tables.indexWhere((t) => t.id == updatedTable.id);
      if (index >= 0) {
        _tables[index] = updatedTable;
        _applyFilters();
      }
    });
  }
  
  void _updateTables(dynamic tablesData) {
    setState(() {
      _tables = (tablesData as List)
          .map((table) => TableModel.fromJson(table))
          .where((table) => table.floorId == widget.floorId)
          .toList();
      _applyFilters();
      _isLoading = false;
    });
  }

  Future<void> _loadFloorAndTables() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final floor = await _floorService.getFloorById(widget.floorId);
      final tables = await _tableService.getTablesByFloor(widget.floorId);
      
      setState(() {
        _floor = floor;
        _tables = tables;
        _filteredTables = List.from(_tables);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load floor data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() {
    setState(() {
      if (_selectedSection != null) {
        _filteredTables = _tables
            .where((table) => table.section == _selectedSection)
            .toList();
      } else {
        _filteredTables = List.from(_tables);
      }
    });
  }
  
  void _onSectionChanged(TableSection? section) {
    setState(() {
      _selectedSection = section;
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _websocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _floor == null 
            ? const Text('Floor Detail') 
            : Text(_floor!.name),
        actions: [
          if (_floor?.description != null && _floor!.description!.isNotEmpty)
            IconButton(
              icon: Icon(
                _showFloorInfo ? Icons.info : Icons.info_outline,
                color: _showFloorInfo ? Colors.blue : null,
              ),
              onPressed: () {
                setState(() {
                  _showFloorInfo = !_showFloorInfo;
                });
              },
              tooltip: 'Floor information',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFloorAndTables,
            tooltip: 'Refresh tables',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadFloorAndTables,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Section filter - compact horizontal scroll
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SectionFilter(
            selectedSection: _selectedSection,
            onSectionChanged: _onSectionChanged,
          ),
        ),
        
        // Floor description if toggled on
        if (_showFloorInfo && _floor?.description != null && _floor!.description!.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _floor!.description!,
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        
        // Tables count and filter indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredTables.length} Tables',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              if (_selectedSection != null)
                SizedBox(
                  height: 28,
                  child: Chip(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    label: Text(
                      _selectedSection!.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    deleteIcon: Icon(Icons.close, size: 14, color: Theme.of(context).primaryColor),
                    onDeleted: () => _onSectionChanged(null),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ),
        
        // Enhanced table grid
        Expanded(
          child: _filteredTables.isEmpty
              ? _buildEmptyState()
              : _buildTableGrid(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_bar, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No tables found',
            style: TextStyle(fontSize: 18),
          ),
          if (_selectedSection != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Try removing the section filter',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // Improved table grid with responsive sizing
  Widget _buildTableGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal table size based on screen width
        final double screenWidth = constraints.maxWidth;
        
        // Determine number of columns and item size based on screen width
        int crossAxisCount;
        if (screenWidth > 900) {
          crossAxisCount = 8; // Extra large screens
        } else if (screenWidth > 600) {
          crossAxisCount = 6; // Tablet size
        } else if (screenWidth > 400) {
          crossAxisCount = 4; // Large phones
        } else {
          crossAxisCount = 3; // Small phones
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _filteredTables.length,
          itemBuilder: (context, index) {
            final table = _filteredTables[index];
            return _buildTableItem(table);
          },
        );
      }
    );
  }

  // Enhanced table item with shape-based design
  Widget _buildTableItem(TableModel table) {
    final statusColor = _getStatusColor(table.status);
    final isOccupied = table.status == TableStatus.OCCUPIED;
    final peopleCount = table.customerCount ?? 0;
    
    // Choose shape based on table shape property
    Widget tableShape;
    switch (table.shape) {
      case TableShape.ROUND:
        tableShape = _buildRoundTable(table, statusColor);
        break;
      case TableShape.SQUARE:
        tableShape = _buildSquareTable(table, statusColor);
        break;
      case TableShape.RECTANGULAR:
        tableShape = _buildRectangleTable(table, statusColor);
        break;
      default:
        tableShape = _buildSquareTable(table, statusColor);
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableManagementScreen(tableId: table.id),
          ),
        ).then((_) => _loadFloorAndTables());
      },
      child: tableShape,
    );
  }
  
  // Round table visualization
  Widget _buildRoundTable(TableModel table, Color statusColor) {
    final isOccupied = table.status == TableStatus.OCCUPIED;
    final peopleCount = table.customerCount ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor.withOpacity(0.2),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${table.tableNumber}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: statusColor.withOpacity(0.7),
              ),
              Text(
                isOccupied ? '$peopleCount/${table.capacity}' : '${table.capacity}',
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Square table visualization
  Widget _buildSquareTable(TableModel table, Color statusColor) {
    final isOccupied = table.status == TableStatus.OCCUPIED;
    final peopleCount = table.customerCount ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${table.tableNumber}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getStatusText(table.status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: statusColor.withOpacity(0.7),
              ),
              Text(
                isOccupied ? '$peopleCount/${table.capacity}' : '${table.capacity}',
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Rectangle table visualization
  Widget _buildRectangleTable(TableModel table, Color statusColor) {
    final isOccupied = table.status == TableStatus.OCCUPIED;
    final peopleCount = table.customerCount ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${table.tableNumber}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getStatusText(table.status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 12,
                color: statusColor.withOpacity(0.7),
              ),
              Text(
                isOccupied ? '$peopleCount/${table.capacity}' : '${table.capacity}',
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return Colors.green;
      case TableStatus.OCCUPIED:
        return Colors.red;
      case TableStatus.RESERVED:
        return Colors.orange;
      case TableStatus.CLEANING:
        return Colors.blue;
      case TableStatus.MAINTENANCE:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.VACANT:
        return 'Free';
      case TableStatus.OCCUPIED:
        return 'Occupied';
      case TableStatus.RESERVED:
        return 'Reserved';
      case TableStatus.CLEANING:
        return 'Cleaning';
      case TableStatus.MAINTENANCE:
        return 'Repair';
      default:
        return '';
    }
  }
}