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
      accountId: json['accountId'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      emailVerified: json['emailVerified'] as bool,
      provider: json['provider'] as String,
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
