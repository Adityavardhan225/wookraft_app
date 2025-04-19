import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/table_model.dart';
import '../services/table_service.dart';
// import '../services/api_service.dart';
import '../../http_client.dart';

class TableSelectionScreen extends StatefulWidget {
  final DateTime selectedDate;
  final int partySize;
  final List<String> initialSelectedTableIds;
  final bool selectionMode;
  final String heroTagPrefix;

  const TableSelectionScreen({
    super.key,
    required this.selectedDate,
    required this.partySize,
    this.initialSelectedTableIds = const [],
    this.selectionMode = true,
    this.heroTagPrefix = 'default',
    
  });

  @override
  _TableSelectionScreenState createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> with SingleTickerProviderStateMixin {
  late TableService _tableService;
  late AnimationController _animationController;
  
  List<dynamic> _floorPlans = [];
  int _selectedFloorIndex = 0;
  List<TableModel> _selectedTables = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // _tableService = TableService(_websocketService);
    _loadFloorPlans();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

Future<void> _loadFloorPlans() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Format the reservation date for API
    final String formattedDateTime = widget.selectedDate.toIso8601String();
    
    // Load floors
    final response = await HttpClient.get('tables_management/floors');
    if (response.statusCode != 200) {
      throw Exception('Failed to load floors');
    }
    
    // Parse floor data
    final List<dynamic> floorsJson = json.decode(response.body);
    final floors = floorsJson;
    
    // Load tables for each floor
    for (int i = 0; i < floors.length; i++) {
      final floorId = floors[i]['id'];
      
      // Include the reservation_datetime parameter using queryParams (not queryParameters)
      // and use Map<String, String> instead of Map<String, dynamic>
      final tablesResponse = await HttpClient.get(
        'tables_management/tables',
        queryParams: {
          'floor_id': floorId.toString(),
          'reservation_datetime': formattedDateTime
        }
      );
      
      if (tablesResponse.statusCode == 200) {
        final List<dynamic> tablesJson = json.decode(tablesResponse.body);
        final List<TableModel> tables = tablesJson
            .map((json) => TableModel.fromJson(json))
            .toList();
        
        floors[i]['tables'] = tables;
      } else {
        floors[i]['tables'] = [];
      }
    }
    
    setState(() {
      _floorPlans = floors;
      _isLoading = false;
      
      // Initialize from selected IDs if any
      if (widget.initialSelectedTableIds.isNotEmpty) {
        _initializeSelectedTables();
      }
    });
    
    _animationController.forward(from: 0.0);
    
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load floor plans: ${e.toString()}';
      _isLoading = false;
    });
  }
}
  
  void _initializeSelectedTables() {
    if (widget.initialSelectedTableIds.isEmpty) return;
    
    final selectedTables = <TableModel>[];
    
    for (final floor in _floorPlans) {
      for (final table in floor['tables']) {
        if (widget.initialSelectedTableIds.contains(table.id)) {
          selectedTables.add(table);
        }
      }
    }
    
    setState(() {
      _selectedTables = selectedTables;
    });
  }
  
  void _toggleTableSelection(TableModel table) {
    // Don't allow selecting tables that are not vacant
    if (table.status != TableStatus.VACANT && !_selectedTables.any((t) => t.id == table.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.tableNumber} is ${table.status.displayName.toLowerCase()} and cannot be selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if table has enough capacity
    if (table.capacity < widget.partySize && !_selectedTables.any((t) => t.id == table.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.tableNumber} is too small for your party size of ${widget.partySize}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      if (_selectedTables.any((t) => t.id == table.id)) {
        _selectedTables.removeWhere((t) => t.id == table.id);
      } else {
        _selectedTables.add(table);
      }
    });
  }

  int _getTotalCapacity() {
    return _selectedTables.fold(0, (sum, table) => sum + table.capacity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Tables for ${DateFormat('MMM d, h:mm a').format(widget.selectedDate)}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('CONFIRM', style: TextStyle(color: Colors.white)),
            onPressed: _selectedTables.isEmpty ? null : () {
              Navigator.pop(context, _selectedTables);
            },
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading 
          ? _buildLoadingView()
          : _errorMessage != null
              ? _buildErrorView()
              : _buildFloorPlanView(),
      bottomSheet: _selectedTables.isNotEmpty
          ? _buildSelectedTablesSheet()
          : null,
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading available tables...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Tables',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _loadFloorPlans,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorPlanView() {
    if (_floorPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_bar, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No floor plans available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _animationController.value,
          child: Column(
            children: [
              // Floor selector tabs
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_floorPlans.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(_floorPlans[index]['name']),
                            selected: _selectedFloorIndex == index,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFloorIndex = index;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              
              // Party size info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Party Size: ${widget.partySize}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tables: ${_selectedTables.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedTables.isEmpty
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tables grid
              Expanded(
                child: _floorPlans.isEmpty || _floorPlans[_selectedFloorIndex]['tables'].isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_restaurant, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tables on this floor',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _floorPlans[_selectedFloorIndex]['tables'].length,
                        itemBuilder: (context, index) {
                          final table = _floorPlans[_selectedFloorIndex]['tables'][index];
                          final isSelected = _selectedTables.any((t) => t.id == table.id);
                          return _buildTableCard(table, isSelected);
                        },
                      ),
              ),
              
              // Space for the bottom sheet
              if (_selectedTables.isNotEmpty)
                const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCard(TableModel table, bool isSelected) {
    final Color statusColor = _getStatusColor(table.status);
    final bool isAvailable = table.status == TableStatus.VACANT;
    final bool capacityOk = table.capacity >= widget.partySize;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : statusColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : statusColor.withOpacity(0.05),
      child: InkWell(
        onTap: () => _toggleTableSelection(table),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Table number with shape background
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isSelected ? Theme.of(context).primaryColor : statusColor).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : statusColor,
                        width: 2,
                      ),
                    ),
                  ),
                  Text(
                    '${table.tableNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : statusColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Capacity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : (!capacityOk ? Colors.orange : Colors.grey[800]),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : isAvailable
                            ? Icons.check_circle_outline
                            : Icons.do_not_disturb,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : statusColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSelected
                        ? 'Selected'
                        : isAvailable ? 'Available' : table.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTablesSheet() {
    final totalCapacity = _getTotalCapacity();
    final bool capacityOk = totalCapacity >= widget.partySize;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Tables: ${_selectedTables.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  setState(() {
                    _selectedTables.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Table chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedTables.map((table) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text('Table ${table.tableNumber} (${table.capacity})'),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedTables.removeWhere((t) => t.id == table.id);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Capacity indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: capacityOk ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: capacityOk ? Colors.green : Colors.red),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  capacityOk ? Icons.check_circle : Icons.warning,
                  color: capacityOk ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Capacity: $totalCapacity / ${widget.partySize} needed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: capacityOk ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !capacityOk ? null : () {
                Navigator.pop(context, _selectedTables);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('CONFIRM SELECTION'),
            ),
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
}