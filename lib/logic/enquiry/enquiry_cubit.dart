import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/enquiry_model.dart';
import '../../data/repositories/enquiry_repository.dart';
import 'enquiry_state.dart';

/// Cubit managing wholesale trade enquiry submission and local history tracking.
class EnquiryCubit extends Cubit<EnquiryState> {
  final EnquiryRepository _repository;

  EnquiryCubit(this._repository) : super(const EnquiryInitial()) {
    loadHistory();
  }

  /// Loads locally stored enquiry records.
  void loadHistory() {
    emit(const EnquiryLoading());
    try {
      final enquiries = _repository.loadEnquiries();
      emit(EnquiryLoaded(enquiries));
    } catch (e) {
      emit(EnquiryFailure('Failed to load enquiry records: ${e.toString()}'));
    }
  }

  /// Submits an enquiry for the given cart items.
  Future<bool> submitEnquiry({
    required List<CartItem> items,
    required String buyerNote,
  }) async {
    if (items.isEmpty) {
      emit(const EnquiryFailure('Cannot submit an empty enquiry cart.'));
      return false;
    }

    emit(const EnquiryLoading());
    try {
      // Simulate network submission delay
      await Future.delayed(const Duration(milliseconds: 600));

      final randomId = 1000 + Random().nextInt(9000);
      final totalQty = items.fold(0, (sum, item) => sum + item.quantity);
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);

      final newEnquiry = Enquiry(
        id: '#ENQ-$randomId',
        items: List.from(items),
        createdAt: DateTime.now(),
        status: 'Submitted',
        buyerNote: buyerNote.trim().isEmpty ? 'Standard wholesale delivery requested.' : buyerNote.trim(),
        totalEstimatedAmount: double.parse(totalAmount.toStringAsFixed(2)),
        totalQuantity: totalQty,
      );

      await _repository.saveEnquiry(newEnquiry);
      emit(EnquirySubmitted(newEnquiry));

      // Automatically reload updated history
      final updatedList = _repository.loadEnquiries();
      emit(EnquiryLoaded(updatedList));
      return true;
    } catch (e) {
      emit(EnquiryFailure('Failed to submit enquiry: ${e.toString()}'));
      return false;
    }
  }
}
