import 'dart:convert';

class FloorModel {
  final String id;
  final String name;
  final String? description;
  final int level;
  final bool isActive;

  FloorModel({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    required this.isActive,
  });

  // Create a copy of this floor model with modified fields
  FloorModel copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    bool? isActive,
  }) {
    return FloorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert JSON to FloorModel
  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      level: json['level'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  // Convert FloorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'is_active': isActive,
    };
  }

  // Parse a list of floor JSON objects
  static List<FloorModel> parseFloorList(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<FloorModel>((json) => FloorModel.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'Floor{id: $id, name: $name, level: $level, isActive: $isActive}';
  }
}