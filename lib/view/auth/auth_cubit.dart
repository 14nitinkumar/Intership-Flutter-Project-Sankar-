import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../main.dart';
import '../../utils/models/user_model.dart';
import '../../utils/preference_keys/preference_keys.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState()) {
    checkSession();
  }

  void checkSession() {
    final bool loggedIn = sharedPreferences.getBool(PreferenceKeys.isLoggedIn) ?? false;
    final String? sessionStr = sharedPreferences.getString(PreferenceKeys.userSession);
    UserSession? session;
    if (sessionStr != null && sessionStr.isNotEmpty) {
      try {
        session = UserSession.fromJson(jsonDecode(sessionStr) as Map<String, dynamic>);
      } catch (_) {}
    } else if (loggedIn) {
      final email = sharedPreferences.getString(PreferenceKeys.userEmail) ?? 'buyer@vyapaarhub.com';
      final name = sharedPreferences.getString(PreferenceKeys.userName) ?? 'Verified Buyer';
      session = UserSession(
        displayName: name,
        email: email,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
    }

    if (loggedIn && session != null) {
      emit(state.copyWith(isLoggedIn: true, user: session));
    } else {
      emit(state.copyWith(isLoggedIn: false));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      if (trimmedEmail.isEmpty || !trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Please enter a valid email address.'));
        return;
      }
      if (trimmedPassword.length < 6) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Password must be at least 6 characters.'));
        return;
      }

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

      await _persistSession(session);
      emit(state.copyWith(isLoading: false, isLoggedIn: true, user: session));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final trimmedName = name.trim();
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      if (trimmedName.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Please enter your full name or business title.'));
        return;
      }
      if (trimmedEmail.isEmpty || !trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Please enter a valid email address.'));
        return;
      }
      if (trimmedPassword.length < 6) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Password must be at least 6 characters.'));
        return;
      }

      final session = UserSession(
        displayName: trimmedName,
        email: trimmedEmail,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      await _persistSession(session);
      emit(state.copyWith(isLoading: false, isLoggedIn: true, user: session));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Sign up failed: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));
    await sharedPreferences.remove(PreferenceKeys.isLoggedIn);
    await sharedPreferences.remove(PreferenceKeys.userEmail);
    await sharedPreferences.remove(PreferenceKeys.userName);
    await sharedPreferences.remove(PreferenceKeys.userSession);
    await sharedPreferences.remove(PreferenceKeys.tokenKey);
    emit(state.copyWith(isLoading: false, isLoggedIn: false, user: null));
  }

  Future<void> _persistSession(UserSession session) async {
    await sharedPreferences.setBool(PreferenceKeys.isLoggedIn, session.isLoggedIn);
    await sharedPreferences.setString(PreferenceKeys.userEmail, session.email);
    await sharedPreferences.setString(PreferenceKeys.userName, session.displayName);
    await sharedPreferences.setString(PreferenceKeys.userSession, jsonEncode(session.toJson()));
  }
}
