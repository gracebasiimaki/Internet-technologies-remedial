class UserModel {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String? dateOfBirth;
  final String? ageGroup;
  final String? country;
  final String? gender;
  final String? photoUrl;
  final String? bio;
  final String subscriptionTier;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.dateOfBirth,
    this.ageGroup,
    this.country,
    this.gender,
    this.photoUrl,
    this.bio,
    this.subscriptionTier = 'SEEDLING',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      ageGroup: json['ageGroup'] as String?,
      country: json['country'] as String?,
      gender: json['gender'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      subscriptionTier: (json['subscriptionTier'] as String?) ?? 'SEEDLING',
    );
  }

  bool get isPremium =>
      subscriptionTier == 'BLOOMING' || subscriptionTier == 'FLOURISHING';
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
