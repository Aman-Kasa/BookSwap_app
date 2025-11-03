class UserModel {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
    };
  }
}