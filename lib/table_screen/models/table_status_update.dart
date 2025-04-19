import 'table_model.dart';

class TableStatusUpdate {
  final TableStatus status;
  final String? employeeId;
  final String? orderId;
  final int? customerCount;
  final String? notes;

  TableStatusUpdate({
    required this.status,
    this.employeeId,
    this.orderId,
    this.customerCount,
    this.notes,
  });

  // Create a copy of this status update with modified fields
  TableStatusUpdate copyWith({
    TableStatus? status,
    String? employeeId,
    String? orderId,
    int? customerCount,
    String? notes,
  }) {
    return TableStatusUpdate(
      status: status ?? this.status,
      employeeId: employeeId ?? this.employeeId,
      orderId: orderId ?? this.orderId,
      customerCount: customerCount ?? this.customerCount,
      notes: notes ?? this.notes,
    );
  }

  // Convert TableStatusUpdate to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'status': status.name,
    };
    
    if (employeeId != null) data['employee_id'] = employeeId;
    if (orderId != null) data['order_id'] = orderId;
    if (customerCount != null) data['customer_count'] = customerCount;
    if (notes != null) data['notes'] = notes;
    
    return data;
  }

  // Create a status update from a table model
  factory TableStatusUpdate.fromTableModel(TableModel table) {
    return TableStatusUpdate(
      status: table.status,
      employeeId: table.employeeId,
      orderId: table.orderId,
      customerCount: table.customerCount,
      notes: table.notes,
    );
  }

  // Create a new table status update for setting a table as occupied
  static TableStatusUpdate occupied({
    required String employeeId,
    String? orderId,
    required int customerCount,
    String? notes,
  }) {
    return TableStatusUpdate(
      status: TableStatus.OCCUPIED,
      employeeId: employeeId,
      orderId: orderId,
      customerCount: customerCount,
      notes: notes,
    );
  }

  // Create a new table status update for setting a table as vacant
  static TableStatusUpdate vacant({String? notes}) {
    return TableStatusUpdate(
      status: TableStatus.VACANT,
      notes: notes,
    );
  }

  // Create a new table status update for setting a table as reserved
  static TableStatusUpdate reserved({
    required String employeeId,
    int? customerCount,
    String? notes,
  }) {
    return TableStatusUpdate(
      status: TableStatus.RESERVED,
      employeeId: employeeId,
      customerCount: customerCount,
      notes: notes,
    );
  }
  
  // Create a new table status update for setting a table as in maintenance
  static TableStatusUpdate maintenance({String? notes}) {
    return TableStatusUpdate(
      status: TableStatus.MAINTENANCE,
      notes: notes,
    );
  }

  // Create a new table status update for setting a table as being cleaned
  static TableStatusUpdate cleaning({String? notes}) {
    return TableStatusUpdate(
      status: TableStatus.CLEANING,
      notes: notes,
    );
  }

  @override
  String toString() {
    return 'TableStatusUpdate{status: ${status.name}, employeeId: $employeeId, customerCount: $customerCount}';
  }
}