class UserModel {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final String university;
  final String location;
  final String profileImageUrl;
  final String phoneNumber;
  final String bio;
  final DateTime joinedDate;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    this.university = '',
    this.location = '',
    this.profileImageUrl = '',
    this.phoneNumber = '',
    this.bio = '',
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      university: map['university'] ?? '',
      location: map['location'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      joinedDate: map['joinedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['joinedDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'emailVerified': emailVerified,
      'university': university,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'joinedDate': joinedDate.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? emailVerified,
    String? university,
    String? location,
    String? profileImageUrl,
    String? phoneNumber,
    String? bio,
    DateTime? joinedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      emailVerified: emailVerified ?? this.emailVerified,
      university: university ?? this.university,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}