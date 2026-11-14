import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/preference_keys.dart';
import '../models/cart_item_model.dart';
import '../models/enquiry_model.dart';
import '../models/user_model.dart';

/// Service managing persistent local data via SharedPreferences.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ----------------------------------------------------
  // User Session Management
  // ----------------------------------------------------
  UserSession? getUserSession() {
    final jsonStr = _prefs.getString(PreferenceKeys.userSession);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserSession.fromJson(map);
      } catch (_) {
        return null;
      }
    }

    final isLoggedIn = _prefs.getBool(PreferenceKeys.isLoggedIn) ?? false;
    if (isLoggedIn) {
      final email = _prefs.getString(PreferenceKeys.userEmail) ?? 'buyer@vyapaarhub.com';
      final name = _prefs.getString(PreferenceKeys.userName) ?? 'Verified Buyer';
      return UserSession(
        displayName: name,
        email: email,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<void> saveUserSession(UserSession session) async {
    await _prefs.setBool(PreferenceKeys.isLoggedIn, session.isLoggedIn);
    await _prefs.setString(PreferenceKeys.userEmail, session.email);
    await _prefs.setString(PreferenceKeys.userName, session.displayName);
    await _prefs.setString(PreferenceKeys.userSession, jsonEncode(session.toJson()));
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(PreferenceKeys.isLoggedIn);
    await _prefs.remove(PreferenceKeys.userEmail);
    await _prefs.remove(PreferenceKeys.userName);
    await _prefs.remove(PreferenceKeys.userSession);
  }

  // ----------------------------------------------------
  // Enquiry Cart Management
  // ----------------------------------------------------
  List<CartItem> getCartItems() {
    final jsonStr = _prefs.getString(PreferenceKeys.cartItems);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(PreferenceKeys.cartItems, jsonStr);
  }

  Future<void> clearCart() async {
    await _prefs.remove(PreferenceKeys.cartItems);
  }

  // ----------------------------------------------------
  // Enquiry History Management
  // ----------------------------------------------------
  List<Enquiry> getEnquiries() {
    final jsonStr = _prefs.getString(PreferenceKeys.enquiryHistory);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => Enquiry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEnquiry(Enquiry enquiry) async {
    final existing = getEnquiries();
    final updated = [enquiry, ...existing];
    final jsonStr = jsonEncode(updated.map((e) => e.toJson()).toList());
    await _prefs.setString(PreferenceKeys.enquiryHistory, jsonStr);
  }
}
