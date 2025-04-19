import 'dart:convert';
import '../models/table_model.dart';
import '../models/table_status_update.dart';
import '../../http_client.dart';
import 'websocket_service.dart';

class TableService {
  final WebSocketService _websocketService;

  TableService(this._websocketService);

  // Get all tables
  Future<List<TableModel>> getAllTables() async {
    try {
      final response = await HttpClient.get('tables_management/tables');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> tablesJson = json.decode(response.body);
        return tablesJson.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  // Get table by ID
  Future<TableModel> getTableById(String tableId) async {
    try {
      final response = await HttpClient.get('tables_management/tables/$tableId');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TableModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load table: $e');
    }
  }

  // Get tables by floor
  Future<List<TableModel>> getTablesByFloor(String floorId) async {
    try {
      final response = await HttpClient.get('tables_management/tables/floor/$floorId');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> tablesJson = json.decode(response.body);
        return tablesJson.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  // Get tables by status
  Future<List<TableModel>> getTablesByStatus(TableStatus status) async {
    try {
      // Convert enum to string for query parameter
      final response = await HttpClient.get('tables_management/tables', 
          queryParams: {'status': status.name});
          
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> tablesJson = json.decode(response.body);
        return tablesJson.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  // Get tables by section
  Future<List<TableModel>> getTablesBySection(TableSection section) async {
    try {
      final response = await HttpClient.get('tables_management/tables', 
          queryParams: {'section': section.name});
          
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> tablesJson = json.decode(response.body);
        return tablesJson.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  // Update table status using WebSocket
  void updateTableStatus(String tableId, TableStatusUpdate statusUpdate) {
    _websocketService.updateTableStatus(tableId, statusUpdate.toJson());
  }

  // Create new table
  Future<TableModel> createTable(TableModel table) async {
    try {
      final response = await HttpClient.post('tables_management/tables', body: table.toJson());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TableModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  // Update table - using POST with _method parameter
  Future<TableModel> updateTable(String tableId, TableModel table) async {
    try {
      final data = table.toJson();
      data['_method'] = 'PUT';
      
      final response = await HttpClient.post('tables_management/tables/$tableId', body: data);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TableModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  // Delete table - using POST with _method parameter
  Future<void> deleteTable(String tableId) async {
    try {
      final response = await HttpClient.post(
        'tables_management/tables/$tableId',
        body: {'_method': 'DELETE'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  // Request data refresh
  void requestDataRefresh() {
    _websocketService.requestRefresh();
  }

  // Listen for table updates
  Stream<Map<String, dynamic>> get tableUpdates => 
      _websocketService.messageStream.where((event) => 
          event['type'] == 'table_status_updated' || 
          event['type'] == 'initial_data' ||
          event['type'] == 'refresh_data');
}