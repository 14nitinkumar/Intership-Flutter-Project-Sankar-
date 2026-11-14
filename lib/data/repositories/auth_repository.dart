import '../models/user_model.dart';
import '../services/storage_service.dart';

/// Repository managing user authentication and local session persistence.
class AuthRepository {
  final StorageService _storageService;

  AuthRepository(this._storageService);

  UserSession? getCurrentSession() {
    return _storageService.getUserSession();
  }

  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    // Artificial delay to mimic network request
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }
    if (trimmedPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    // Extract pleasant display name from email or default
    final localPart = trimmedEmail.split('@').first;
    final displayName = localPart.isNotEmpty
        ? '${localPart[0].toUpperCase()}${localPart.substring(1)}'
        : 'Buyer';

    final session = UserSession(
      displayName: displayName,
      email: trimmedEmail,
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );

    await _storageService.saveUserSession(session);
    return session;
  }

  Future<UserSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedName.isEmpty) {
      throw const AuthException('Please enter your full name or business title.');
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }
    if (trimmedPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final session = UserSession(
      displayName: trimmedName,
      email: trimmedEmail,
      isLoggedIn: true,
      createdAt: DateTime.now(),
    );

    await _storageService.saveUserSession(session);
    return session;
  }

  Future<void> logout() async {
    await _storageService.clearUserSession();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
