import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../main.dart';
import '../../utils/models/cart_item_model.dart';
import '../../utils/models/enquiry_model.dart';
import '../../utils/preference_keys/preference_keys.dart';
import 'enquiry_state.dart';

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryState()) {
    loadHistory();
  }

  void loadHistory() {
    emit(state.copyWith(isLoading: true, clearError: true));
    final jsonStr = sharedPreferences.getString(PreferenceKeys.enquiryHistory);
    if (jsonStr == null || jsonStr.isEmpty) {
      emit(state.copyWith(enquiries: [], isLoading: false));
      return;
    }
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final enquiries = list
          .map((item) => Enquiry.fromJson(item as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(enquiries: enquiries, isLoading: false));
    } catch (_) {
      emit(state.copyWith(enquiries: [], isLoading: false));
    }
  }

  Future<bool> submitEnquiry({
    required List<CartItem> items,
    required String buyerNote,
  }) async {
    if (items.isEmpty) {
      emit(state.copyWith(errorMessage: 'Cannot submit an empty enquiry cart.'));
      return false;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final randomId = 1000 + Random().nextInt(9000);
      final totalQty = items.fold(0, (sum, item) => sum + item.quantity);
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);

      final newEnquiry = Enquiry(
        id: '#ENQ-$randomId',
        items: List.from(items),
        createdAt: DateTime.now(),
        status: 'Submitted',
        buyerNote: buyerNote.trim().isEmpty
            ? 'Standard wholesale delivery requested.'
            : buyerNote.trim(),
        totalEstimatedAmount: double.parse(totalAmount.toStringAsFixed(2)),
        totalQuantity: totalQty,
      );

      final current = List<Enquiry>.from(state.enquiries);
      current.insert(0, newEnquiry);

      final list = current.map((e) => e.toJson()).toList();
      await sharedPreferences.setString(
          PreferenceKeys.enquiryHistory, jsonEncode(list));

      emit(state.copyWith(enquiries: current, isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit enquiry: ${e.toString()}',
      ));
      return false;
    }
  }
}
