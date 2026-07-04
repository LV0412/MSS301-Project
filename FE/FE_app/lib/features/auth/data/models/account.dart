class Account {
  const Account({
    required this.accountId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.provider,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: (json['accountId'] as num).toInt(),
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      emailVerified: json['emailVerified'] == true,
      provider: json['provider']?.toString() ?? '',
    );
  }

  final int accountId;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final bool emailVerified;
  final String provider;
}
