import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../http_client.dart';
import '../models/reservation_model.dart';
import '../models/reservation_status.dart';
import './websocket_service.dart';

/// Service for handling reservation-related API operations
class ReservationService {
  final ReservationWebSocketService _websocketService;
  
  ReservationService(this._websocketService);

  /// Create a new reservation in the system
  Future<Reservation> createReservation(ReservationCreate reservationData) async {
    try {
      final response = await HttpClient.post(
        '/tables_management/reservations', 
        body: reservationData.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get a reservation by its ID
  Future<Reservation> getReservationById(String id) async {
    try {
      final response = await HttpClient.get('/tables_management/reservations/$id');
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get a reservation by its code
  Future<Reservation> getReservationByCode(String code) async {
    try {
      final response = await HttpClient.get('/tables_management/reservations_code/$code');
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to find reservation with code: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching reservation by code: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get reservations for a specific date
  Future<List<Reservation>> getReservationsByDate(DateTime date, {bool includeCompleted = false}) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final response = await HttpClient.get(
        '/tables_management/reservations',
        queryParams: {
          'date': dateString,
          'include_completed': includeCompleted.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Reservation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get upcoming reservations for the next X hours
  Future<List<Reservation>> getUpcomingReservations(int hours) async {
    try {
      final response = await HttpClient.get('/tables_management/reservations_upcoming/$hours');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Reservation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load upcoming reservations: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching upcoming reservations: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Search reservations by name, phone, or code
  Future<List<Reservation>> searchReservations(String query) async {
    try {
      final response = await HttpClient.get('/tables_management/reservations_search/$query');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Reservation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search reservations: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error searching reservations: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Update an existing reservation
  Future<Reservation> updateReservation(String id, ReservationUpdate updateData) async {
    try {
      final response = await HttpClient.put(
        '/tables_management/reservations/$id',
        body: updateData.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Cancel a reservation
  Future<Reservation> cancelReservation(String id, {String? reason}) async {
    try {
      final response = await HttpClient.put(
        '/tables_management/reservations/$id/cancel',
        body: reason != null ? {'reason': reason} : null,
      );
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to cancel reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error cancelling reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Check in a reservation
  Future<Reservation> checkInReservation(String id, {
    required List<String> tableIds,
    required String employeeId,
  }) async {
    try {
      final response = await HttpClient.put(
        '/tables_management/reservations/$id/check-in',
        body: {
          'table_ids': tableIds,
          'employee_id': employeeId,
        },
      );
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to check in reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error checking in reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Mark a reservation as completed
  Future<Reservation> completeReservation(String id) async {
    try {
      final response = await HttpClient.put('/tables_management/reservations/$id/complete');
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to complete reservation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error completing reservation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Mark a reservation as no-show
  Future<Reservation> markNoShow(String id) async {
    try {
      final response = await HttpClient.put('/tables_management/reservations/$id/no-show');
      
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to mark reservation as no-show: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking reservation as no-show: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Send a confirmation email for a reservation
  Future<bool> sendConfirmationEmail(String id) async {
    try {
      final response = await HttpClient.post('/tables_management/reservations/$id/send-confirmation');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] as bool;
      } else {
        throw Exception('Failed to send confirmation email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending confirmation email: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Send a reminder email for a reservation
  Future<bool> sendReminderEmail(String id) async {
    try {
      final response = await HttpClient.post('/tables_management/reservations/$id/send-reminder');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] as bool;
      } else {
        throw Exception('Failed to send reminder email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending reminder email: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get reservation statistics for a date range
Future<ReservationStats> getReservationStats(DateTime startDate, DateTime endDate) async {
  try {
    // Format dates as ISO strings
    final startDateFormatted = startDate.toIso8601String().split('T')[0];
    final endDateFormatted = endDate.toIso8601String().split('T')[0];
    
    // final response = await HttpClient.get(
    //   '/tables_management/reservations_stats',
    //   queryParams: {
    //     'start_date': startDateFormatted,
    //     'end_date': endDateFormatted,
    //   },
    // );
        final response = await HttpClient.get(
      'tables_management/reservations_stats/$startDateFormatted/$endDateFormatted'
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) {
        debugPrint('Server returned null stats data');
        return ReservationStats.empty();
      }
      return ReservationStats.fromJson(data);
    } else {
      debugPrint('Failed to get reservation stats: ${response.body}');
      return ReservationStats.empty(); // Return empty stats instead of throwing
    }
  } catch (e) {
    debugPrint('Error getting reservation stats: $e');
    return ReservationStats.empty(); // Return empty stats instead of throwing
  }
}

  // WebSocket methods for real-time updates
  void updateReservationStatus(String reservationId, ReservationStatus status) {
    _websocketService.sendMessage({
      'type': 'update_reservation_status',
      'reservation_id': reservationId,
      'status': status.name,
    });
  }
}