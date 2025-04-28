import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../table_screen/models/table_model.dart';
import '../../http_client.dart';

class TableSelectionReservationScreen extends StatefulWidget {
  final DateTime reservationDateTime;
  final int partySize;
  final int durationMinutes;
  final List<String> initialSelectedTableIds;

  const TableSelectionReservationScreen({
    super.key,
    required this.reservationDateTime,
    required this.partySize,
    this.durationMinutes = 90,
    this.initialSelectedTableIds = const [],
  });

  @override
  _TableSelectionReservationScreenState createState() => _TableSelectionReservationScreenState();
}

class _TableSelectionReservationScreenState extends State<TableSelectionReservationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  List<dynamic> _floorPlans = [];
  int _selectedFloorIndex = 0;
  List<TableModel> _selectedTables = [];
  List<TableModel> _availableTables = [];
  Map<String, List<TableModel>> _tablesByFloor = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadAvailableTables();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

Future<void> _loadAvailableTables() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Format date to ISO string for API
    final String isoDateTime = widget.reservationDateTime.toUtc().toIso8601String();
    
    // Use the getWithQueryParams method instead of building URL manually
    final response = await HttpClient.getWithQueryParams(
      'tables_management/tables_management/reserved_table/available',  
      {  
        'reservation_time': isoDateTime,
        'party_size': widget.partySize.toString(),
        'duration_minutes': widget.durationMinutes.toString(),
      },
    );
    
    print('API response status: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load available tables: ${response.body}');
    }
    
      // Parse table data
      final List<dynamic> tablesJson = json.decode(response.body);
      final List<TableModel> tables = tablesJson
          .map((json) => TableModel.fromJson(json))
          .toList();
      
      // Load floors to organize tables by floor
      final floorResponse = await HttpClient.get('tables_management/floors');
      if (floorResponse.statusCode != 200) {
        throw Exception('Failed to load floors');
      }
      
      final List<dynamic> floorsJson = json.decode(floorResponse.body);
      final floors = floorsJson;
      
      // Organize tables by floor
      final tablesByFloor = <String, List<TableModel>>{};
      for (final floor in floors) {
        tablesByFloor[floor['id']] = [];
      }
      
      // Assign tables to floors
      for (final table in tables) {
        final floorId = table.floorId;
        if (tablesByFloor.containsKey(floorId)) {
          tablesByFloor[floorId]!.add(table);
        }
      }
      
      // Remove floors with no available tables
      final floorsWithTables = floors.where((floor) => 
          tablesByFloor[floor['id']]?.isNotEmpty ?? false).toList();
      
      // Add tables to each floor
      for (int i = 0; i < floorsWithTables.length; i++) {
        final floorId = floorsWithTables[i]['id'];
        floorsWithTables[i]['tables'] = tablesByFloor[floorId] ?? [];
      }
      
      setState(() {
        _availableTables = tables;
        _tablesByFloor = tablesByFloor;
        _floorPlans = floorsWithTables;
        _isLoading = false;
        
        // Initialize from selected IDs if any
        if (widget.initialSelectedTableIds.isNotEmpty) {
          _initializeSelectedTables();
        }
      });
      
      _animationController.forward(from: 0.0);
      
      // Debug info
      print('Available tables for reservation: ${tables.length}');
      print('Tables by floor: $_tablesByFloor');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available tables: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
    
  void _initializeSelectedTables() {
    if (widget.initialSelectedTableIds.isEmpty) return;
    
    final selectedTables = <TableModel>[];
    
    for (final table in _availableTables) {
      if (widget.initialSelectedTableIds.contains(table.id)) {
        selectedTables.add(table);
      }
    }
    
    setState(() {
      _selectedTables = selectedTables;
    });
  }
  
  void _toggleTableSelection(TableModel table) {
    // If table is already selected, just remove it
    if (_selectedTables.any((t) => t.id == table.id)) {
      setState(() {
        _selectedTables.removeWhere((t) => t.id == table.id);
      });
      return;
    }
    
    // Check if table has enough capacity
    if (table.capacity < widget.partySize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.tableNumber} is too small for your party size of ${widget.partySize}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Add the table to selection
    setState(() {
      _selectedTables.add(table);
    });
  }

  int _getTotalCapacity() {
    return _selectedTables.fold(0, (sum, table) => sum + table.capacity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Tables for Reservation',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${DateFormat('MMM d, h:mm a').format(widget.reservationDateTime)} • ${widget.durationMinutes} mins',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
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
            'Finding available tables for your reservation...',
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
              'Error Loading Available Tables',
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
              onPressed: _loadAvailableTables,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAvailableTablesView() {
    final formatter = DateFormat('MMM d, h:mm a');
    final endTime = widget.reservationDateTime.add(Duration(minutes: widget.durationMinutes));
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'No Tables Available',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${formatter.format(widget.reservationDateTime)} - ${formatter.format(endTime)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Party Size: ${widget.partySize}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'There are no tables available for the selected time and party size. Please try a different time or adjust your party size.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loadAvailableTables,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorPlanView() {
    if (_floorPlans.isEmpty || _availableTables.isEmpty) {
      return _buildNoAvailableTablesView();
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
              if (_floorPlans.length > 1)
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
              
              // Reservation info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(widget.reservationDateTime),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('h:mm a').format(widget.reservationDateTime) + 
                                    ' - ' + 
                                    DateFormat('h:mm a').format(
                                      widget.reservationDateTime.add(Duration(minutes: widget.durationMinutes))
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Party Size: ${widget.partySize}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Available Tables: ${_availableTables.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
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
                              'No available tables on this floor',
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
    final bool capacityOk = table.capacity >= widget.partySize;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.green,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.green.withOpacity(0.05),
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
                      color: (isSelected ? Theme.of(context).primaryColor : Colors.green).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                  Text(
                    '${table.tableNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.green,
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
                    isSelected ? Icons.check_circle : Icons.check_circle_outline,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSelected ? 'Selected' : 'Available',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.green,
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONFIRM SELECTION',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}