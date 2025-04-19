import 'dart:convert';

// Table status enum
enum TableStatus {
  VACANT,
  OCCUPIED,
  RESERVED,
  MAINTENANCE,
  CLEANING;

  String get displayName {
    return name.substring(0, 1).toUpperCase() + 
           name.substring(1).toLowerCase();
  }

  static TableStatus fromString(String status) {
    return TableStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TableStatus.VACANT,
    );
  }
}

// Table section enum
enum TableSection {
  MAIN,
  OUTDOOR,
  PRIVATE,
  BAR,
  ROOFTOP;

  String get displayName {
    return name.substring(0, 1).toUpperCase() + 
           name.substring(1).toLowerCase();
  }

  static TableSection fromString(String section) {
    return TableSection.values.firstWhere(
      (e) => e.name == section,
      orElse: () => TableSection.MAIN,
    );
  }
}

// Table shape enum
enum TableShape {
  SQUARE,
  ROUND,
  RECTANGULAR,
  OVAL;

  String get displayName {
    return name.substring(0, 1).toUpperCase() + 
           name.substring(1).toLowerCase();
  }

  static TableShape fromString(String shape) {
    return TableShape.values.firstWhere(
      (e) => e.name == shape,
      orElse: () => TableShape.SQUARE,
    );
  }
}

class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final TableSection section;
  final TableShape shape;
  final double positionX;
  final double positionY;
  final TableStatus status;
  final String? floorId;
  final String? description;
  final String? employeeId;
  final String? orderId;
  final int? customerCount;
  final String? notes;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.section,
    required this.shape,
    required this.positionX,
    required this.positionY,
    required this.status,
    this.floorId,
    this.description,
    this.employeeId,
    this.orderId,
    this.customerCount,
    this.notes,
  });

  // Create a copy of this table model with modified fields
  TableModel copyWith({
    String? id,
    int? tableNumber,
    int? capacity,
    TableSection? section,
    TableShape? shape,
    double? positionX,
    double? positionY,
    TableStatus? status,
    String? floorId,
    String? description,
    String? employeeId,
    String? orderId,
    int? customerCount,
    String? notes,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      section: section ?? this.section,
      shape: shape ?? this.shape,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      status: status ?? this.status,
      floorId: floorId ?? this.floorId,
      description: description ?? this.description,
      employeeId: employeeId ?? this.employeeId,
      orderId: orderId ?? this.orderId,
      customerCount: customerCount ?? this.customerCount,
      notes: notes ?? this.notes,
    );
  }

  // Convert JSON to TableModel
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? '',
      tableNumber: json['table_number'] ?? 0,
      capacity: json['capacity'] ?? 0,
      section: json['section'] != null 
        ? TableSection.fromString(json['section'])
        : TableSection.MAIN,
      shape: json['shape'] != null 
        ? TableShape.fromString(json['shape'])
        : TableShape.SQUARE,
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] != null 
        ? TableStatus.fromString(json['status'])
        : TableStatus.VACANT,
      floorId: json['floor_id'],
      description: json['description'],
      employeeId: json['employee_id'],
      orderId: json['order_id'],
      customerCount: json['customer_count'],
      notes: json['notes'],
    );
  }

  // Convert TableModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'section': section.name,
      'shape': shape.name,
      'position_x': positionX,
      'position_y': positionY,
      'status': status.name,
      'floor_id': floorId,
      'description': description,
      'employee_id': employeeId,
      'order_id': orderId,
      'customer_count': customerCount,
      'notes': notes,
    };
  }

  // Parse a list of table JSON objects
  static List<TableModel> parseTableList(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<TableModel>((json) => TableModel.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'Table{id: $id, number: $tableNumber, status: ${status.name}, section: ${section.name}}';
  }
}