/// SharedPreferences storage keys for user session, cart, and enquiries.
class PreferenceKeys {
  PreferenceKeys._();

  static const String isLoggedIn = 'is_logged_in';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userSession = 'user_session_json';
  static const String cartItems = 'cart_items_json';
  static const String enquiryHistory = 'enquiry_history_json';
}
