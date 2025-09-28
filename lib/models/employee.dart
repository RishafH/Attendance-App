class Employee {
  final String id;
  final String username;
  final String name;
  final String? email;
  final String? phone;
  final DateTime createdAt;

  Employee({
    required this.id,
    required this.username,
    required this.name,
    this.email,
    this.phone,
    required this.createdAt,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON response
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy with updated fields
  Employee copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}