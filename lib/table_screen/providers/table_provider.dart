import 'package:flutter/foundation.dart';
import '../models/table_model.dart';
import '../models/table_status_update.dart';
import '../services/table_service.dart';

class TableProvider extends ChangeNotifier {
  final TableService _tableService;
  Map<String, List<TableModel>> _tablesByFloor = {};
  List<TableModel> _allTables = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Constructor
  TableProvider({required TableService tableService}) 
      : _tableService = tableService {
    _initializeData();
    _listenToWebSocketUpdates();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TableModel> get allTables => _allTables;
  
  // Get tables by floor ID
  List<TableModel> getTablesForFloor(String floorId) {
    return _tablesByFloor[floorId] ?? [];
  }
  
  // Get tables filtered by status
  List<TableModel> getTablesByStatus(TableStatus status) {
    return _allTables.where((table) => table.status == status).toList();
  }
  
  // Get tables filtered by section
  List<TableModel> getTablesBySection(TableSection section) {
    return _allTables.where((table) => table.section == section).toList();
  }
  
  // Initialize data
  Future<void> _initializeData() async {
    await _loadTables();
  }
  
  // Load tables from service
  Future<void> _loadTables() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final tables = await _tableService.getAllTables();
      _updateTablesState(tables);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load tables: $e';
      notifyListeners();
    }
  }
  
  // Update internal state with new tables
  void _updateTablesState(List<TableModel> tables) {
    _allTables = tables;
    
    // Group tables by floor
    _tablesByFloor = {};
    for (final table in tables) {
      if (table.floorId != null) {
        if (!_tablesByFloor.containsKey(table.floorId)) {
          _tablesByFloor[table.floorId!] = [];
        }
        _tablesByFloor[table.floorId]!.add(table);
      }
    }
  }
  
  // Listen to WebSocket updates
  void _listenToWebSocketUpdates() {
    _tableService.tableUpdates.listen((message) {
      if (message['type'] == 'table_status_updated') {
        final updatedTable = TableModel.fromJson(message['data']);
        _updateSingleTable(updatedTable);
      } else if (message['type'] == 'initial_data' || message['type'] == 'refresh_data') {
        if (message.containsKey('tables')) {
          final tables = (message['tables'] as List)
              .map((table) => TableModel.fromJson(table))
              .toList();
          _updateTablesState(tables);
          notifyListeners();
        }
      }
    });
  }
  
  // Update a single table in the state
  void _updateSingleTable(TableModel updatedTable) {
    // Update in allTables
    final index = _allTables.indexWhere((t) => t.id == updatedTable.id);
    if (index >= 0) {
      _allTables[index] = updatedTable;
    } else {
      _allTables.add(updatedTable);
    }
    
    // Update in tablesByFloor
    if (updatedTable.floorId != null) {
      if (!_tablesByFloor.containsKey(updatedTable.floorId)) {
        _tablesByFloor[updatedTable.floorId!] = [];
      }
      
      final floorTableIndex = _tablesByFloor[updatedTable.floorId]!
          .indexWhere((t) => t.id == updatedTable.id);
          
      if (floorTableIndex >= 0) {
        if (_tablesByFloor[updatedTable.floorId!] != null) {
          _tablesByFloor[updatedTable.floorId!]![floorTableIndex] = updatedTable;
        }
      } else {
        _tablesByFloor[updatedTable.floorId!]?.add(updatedTable);
      }
    }
    
    notifyListeners();
  }
  
  // Update table status
  Future<void> updateTableStatus(String tableId, TableStatusUpdate statusUpdate) async {
    try {
      _tableService.updateTableStatus(tableId, statusUpdate);
      // The update will come through the WebSocket
    } catch (e) {
      _errorMessage = 'Failed to update table status: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // Refresh data
  Future<void> refreshTables() async {
    _tableService.requestDataRefresh();
    await _loadTables();
  }
}