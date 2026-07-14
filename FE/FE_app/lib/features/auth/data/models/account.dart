class Account {
  const Account({
    required this.accountId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.provider,
    required this.googleLinked,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: (json['accountId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      emailVerified: json['emailVerified'] == true,
      provider: json['provider']?.toString() ?? '',
      googleLinked: json['googleLinked'] == true,
    );
  }

  final int accountId;
  final int userId;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final bool emailVerified;
  final String provider;
  final bool googleLinked;
}
