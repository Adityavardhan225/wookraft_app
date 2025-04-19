class User {
  final String name;
  final List<String> roles;
  final Map<String, List<String>> resources;

  User({required this.name, required this.roles, required this.resources});

  factory User.fromJson(Map<String, dynamic> json) {
    // Manually parse the resources field
    Map<String, List<String>> parsedResources = {};
    (json['resources'] as Map<String, dynamic>).forEach((key, value) {
      parsedResources[key] = List<String>.from(value);
    });

    return User(
      name: json['name'],
      roles: List<String>.from(json['roles']),
      resources: parsedResources,
    );
  }
}