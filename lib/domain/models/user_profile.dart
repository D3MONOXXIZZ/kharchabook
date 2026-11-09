/// User profile entity representing a student account.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final double monthlyBudget;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.monthlyBudget = 15000.0,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyBudget,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Student User',
      email: json['email'] as String? ?? '',
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 15000.0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'monthly_budget': monthlyBudget,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
