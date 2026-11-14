import 'package:equatable/equatable.dart';

/// Represents the active user demo session.
class UserSession extends Equatable {
  final String displayName;
  final String email;
  final bool isLoggedIn;
  final DateTime createdAt;

  const UserSession({
    required this.displayName,
    required this.email,
    required this.isLoggedIn,
    required this.createdAt,
  });

  factory UserSession.demo() {
    return UserSession(
      displayName: 'Verified Buyer',
      email: 'buyer@vyapaarhub.com',
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      displayName: json['displayName'] as String? ?? 'Buyer',
      email: json['email'] as String? ?? '',
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'email': email,
    'isLoggedIn': isLoggedIn,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [displayName, email, isLoggedIn, createdAt];
}
