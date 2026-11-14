import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit managing session state, authentication, and user sign-out.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  /// Checks whether an existing session is persisted.
  Future<void> checkSession() async {
    final session = _authRepository.getCurrentSession();
    if (session != null && session.isLoggedIn) {
      emit(AuthAuthenticated(session));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Authenticates using email and password.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.login(email: email, password: password);
      emit(AuthAuthenticated(session));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  /// Registers a new demo user account.
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.signup(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(session));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Sign up failed: ${e.toString()}'));
    }
  }

  /// Clears active user session.
  Future<void> logout() async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
