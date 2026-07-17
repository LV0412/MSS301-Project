class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    this.dob,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] as num).toInt(),
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  final int userId;
  final String email;
  final String fullName;
  final String? dob;
  final String? gender;
}
