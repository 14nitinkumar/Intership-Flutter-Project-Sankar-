import '../../utils/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? errorMessage;
  final UserSession? user;

  AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
    bool clearError = false,
    UserSession? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }
}
