import '../../utils/models/enquiry_model.dart';

class EnquiryState {
  final List<Enquiry> enquiries;
  final bool isLoading;
  final String? errorMessage;

  EnquiryState({
    this.enquiries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && enquiries.isEmpty;

  EnquiryState copyWith({
    List<Enquiry>? enquiries,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EnquiryState(
      enquiries: enquiries ?? this.enquiries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
