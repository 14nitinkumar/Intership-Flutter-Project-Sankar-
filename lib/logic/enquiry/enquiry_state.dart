import 'package:equatable/equatable.dart';
import '../../data/models/enquiry_model.dart';

abstract class EnquiryState extends Equatable {
  const EnquiryState();

  @override
  List<Object?> get props => [];
}

class EnquiryInitial extends EnquiryState {
  const EnquiryInitial();
}

class EnquiryLoading extends EnquiryState {
  const EnquiryLoading();
}

class EnquiryLoaded extends EnquiryState {
  final List<Enquiry> enquiries;

  const EnquiryLoaded(this.enquiries);

  @override
  List<Object?> get props => [enquiries];
}

class EnquirySubmitted extends EnquiryState {
  final Enquiry enquiry;

  const EnquirySubmitted(this.enquiry);

  @override
  List<Object?> get props => [enquiry];
}

class EnquiryFailure extends EnquiryState {
  final String message;

  const EnquiryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
