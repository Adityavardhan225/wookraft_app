import 'package:intl/intl.dart';
import 'reservation_status.dart';

/// Model class for a restaurant table
class TableInfo {
  final String id;
  final int tableNumber;
  final int capacity;
  final String section;
  final bool isAvailable;

  TableInfo({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.section,
    this.isAvailable = true,
  });

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      id: json['id'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
      section: json['section'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'section': section,
      'is_available': isAvailable,
    };
  }
}

/// Full reservation model with all details
class Reservation {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final int partySize;
  final DateTime reservationDate;
  final int expectedDurationMinutes;
  final String? specialRequests;
  final ReservationStatus status;
  final List<String> tableIds;
  final String? assignedEmployeeId;
  final String reservationCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TableInfo>? tables;

  // Formatting helpers
  String get formattedDate => DateFormat('EEE, MMM d, yyyy').format(reservationDate);
  String get formattedTime => DateFormat('h:mm a').format(reservationDate);
  String get durationText => '$expectedDurationMinutes minutes';
  
  Reservation({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.partySize,
    required this.reservationDate,
    required this.expectedDurationMinutes,
    this.specialRequests,
    required this.status,
    required this.tableIds,
    this.assignedEmployeeId,
    required this.reservationCode,
    required this.createdAt,
    required this.updatedAt,
    this.tables,
  });

  /// Creates a Reservation from JSON data
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      partySize: json['party_size'],
      reservationDate: DateTime.parse(json['reservation_date']),
      expectedDurationMinutes: json['expected_duration_minutes'],
      specialRequests: json['special_requests'],
      status: ReservationStatus.fromString(json['status']),
      tableIds: List<String>.from(json['table_ids'] ?? []),
      assignedEmployeeId: json['assigned_employee_id'],
      reservationCode: json['reservation_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tables: json['tables'] != null
          ? List<TableInfo>.from(
              json['tables'].map((table) => TableInfo.fromJson(table)))
          : null,
    );
  }

  /// Convert Reservation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'party_size': partySize,
      'reservation_date': reservationDate.toIso8601String(),
      'expected_duration_minutes': expectedDurationMinutes,
      'special_requests': specialRequests,
      'status': status.name,
      'table_ids': tableIds,
      'assigned_employee_id': assignedEmployeeId,
      'reservation_code': reservationCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tables': tables?.map((table) => table.toJson()).toList(),
    };
  }

  /// Creates a copy of this Reservation with the provided fields updated
  Reservation copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    int? partySize,
    DateTime? reservationDate,
    int? expectedDurationMinutes,
    String? specialRequests,
    ReservationStatus? status,
    List<String>? tableIds,
    String? assignedEmployeeId,
    String? reservationCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TableInfo>? tables,
  }) {
    return Reservation(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      partySize: partySize ?? this.partySize,
      reservationDate: reservationDate ?? this.reservationDate,
      expectedDurationMinutes: expectedDurationMinutes ?? this.expectedDurationMinutes,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      tableIds: tableIds ?? this.tableIds,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      reservationCode: reservationCode ?? this.reservationCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tables: tables ?? this.tables,
    );
  }
}

/// Model for creating a new reservation
class ReservationCreate {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final int partySize;
  final DateTime reservationDate;
  final int expectedDurationMinutes;
  final String? specialRequests;
  final String? tablePreference;

  ReservationCreate({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.partySize,
    required this.reservationDate,
    this.expectedDurationMinutes = 90,
    this.specialRequests,
    this.tablePreference,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'party_size': partySize,
      'reservation_date': reservationDate.toIso8601String(),
      'expected_duration_minutes': expectedDurationMinutes,
      'special_requests': specialRequests,
      'table_preference': tablePreference,
    };
  }
}

/// Model for updating an existing reservation
class ReservationUpdate {
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final int? partySize;
  final DateTime? reservationDate;
  final int? expectedDurationMinutes;
  final String? specialRequests;
  final ReservationStatus? status;
  final List<String>? tableIds;
  final String? assignedEmployeeId;

  ReservationUpdate({
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.partySize,
    this.reservationDate,
    this.expectedDurationMinutes,
    this.specialRequests,
    this.status,
    this.tableIds,
    this.assignedEmployeeId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (customerName != null) data['customer_name'] = customerName;
    if (customerPhone != null) data['customer_phone'] = customerPhone;
    if (customerEmail != null) data['customer_email'] = customerEmail;
    if (partySize != null) data['party_size'] = partySize;
    if (reservationDate != null) data['reservation_date'] = reservationDate?.toIso8601String();
    if (expectedDurationMinutes != null) data['expected_duration_minutes'] = expectedDurationMinutes;
    if (specialRequests != null) data['special_requests'] = specialRequests;
    if (status != null) data['status'] = status?.name;
    if (tableIds != null) data['table_ids'] = tableIds;
    if (assignedEmployeeId != null) data['assigned_employee_id'] = assignedEmployeeId;
    
    return data;
  }
}

/// Model for reservation search results
class ReservationSearchResults {
  final List<Reservation> reservations;
  final int totalCount;
  
  ReservationSearchResults({
    required this.reservations,
    required this.totalCount,
  });
  
  factory ReservationSearchResults.fromJson(Map<String, dynamic> json) {
    return ReservationSearchResults(
      reservations: (json['reservations'] as List)
          .map((item) => Reservation.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
    );
  }
}

/// Model for reservation statistics
class ReservationStats {
  final int totalReservations;
  final int confirmedCount;
  final int checkedInCount;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final double averagePartySize;
  final Map<String, int>? reservationsByDay;
  final Map<String, int>? reservationsByHour;
  
  ReservationStats({
    required this.totalReservations,
    required this.confirmedCount,
    required this.checkedInCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.averagePartySize,
    this.reservationsByDay,
    this.reservationsByHour,
  });
  
  factory ReservationStats.fromJson(Map<String, dynamic> json) {
    // Handle different naming conventions in API response
    return ReservationStats(
      totalReservations: json['total_reservations'] ?? json['total'] ?? 0,
      confirmedCount: json['confirmed_count'] ?? json['confirmed'] ?? 0,
      checkedInCount: json['checked_in_count'] ?? json['checked_in'] ?? 0,
      completedCount: json['completed_count'] ?? json['completed'] ?? 0,
      cancelledCount: json['cancelled_count'] ?? json['cancelled'] ?? 0,
      noShowCount: json['no_show_count'] ?? json['no_show'] ?? 0,
      averagePartySize: (json['average_party_size'] ?? 0).toDouble(),
      reservationsByDay: json['reservations_by_day'] != null 
          ? Map<String, int>.from(json['reservations_by_day']) 
          : null,
      reservationsByHour: json['reservations_by_hour'] != null 
          ? Map<String, int>.from(json['reservations_by_hour']) 
          : null,
    );
  }
  
  factory ReservationStats.empty() {
    return ReservationStats(
      totalReservations: 0,
      confirmedCount: 0,
      checkedInCount: 0,
      completedCount: 0,
      cancelledCount: 0,
      noShowCount: 0,
      averagePartySize: 0.0,
    );
  }
}