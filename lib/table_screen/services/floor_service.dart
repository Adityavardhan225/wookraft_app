import 'dart:convert';
import '../models/floor_model.dart';
import '../../http_client.dart';

class FloorService {
  // Get all floors
  Future<List<FloorModel>> getAllFloors() async {
    try {
      final response = await HttpClient.get('tables_management/floors');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> floorsJson = json.decode(response.body);
        return floorsJson.map((json) => FloorModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load floors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load floors: $e');
    }
  }

  // Get floor by ID
  Future<FloorModel> getFloorById(String floorId) async {
    try {
      final response = await HttpClient.get('tables_management/floors/$floorId');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FloorModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load floor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load floor: $e');
    }
  }

  // Create new floor
  Future<FloorModel> createFloor(FloorModel floor) async {
    try {
      final response = await HttpClient.post('tables_management/floors', body: floor.toJson());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FloorModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create floor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create floor: $e');
    }
  }

  // Update floor - using POST with _method parameter
  Future<FloorModel> updateFloor(String floorId, FloorModel floor) async {
    try {
      // Add _method field to the body to indicate PUT operation
      final data = floor.toJson();
      data['_method'] = 'PUT';
      
      final response = await HttpClient.post('tables_management/floors/$floorId', body: data);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FloorModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update floor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update floor: $e');
    }
  }

  // Delete floor - using POST with _method parameter
  Future<void> deleteFloor(String floorId) async {
    try {
      final response = await HttpClient.post(
        'tables_management/floors/$floorId',
        body: {'_method': 'DELETE'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete floor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete floor: $e');
    }
  }
}