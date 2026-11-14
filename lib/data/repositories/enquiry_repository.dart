import '../models/enquiry_model.dart';
import '../services/storage_service.dart';

/// Repository abstracting submitted wholesale enquiries.
class EnquiryRepository {
  final StorageService _storageService;

  EnquiryRepository(this._storageService);

  List<Enquiry> loadEnquiries() {
    return _storageService.getEnquiries();
  }

  Future<void> saveEnquiry(Enquiry enquiry) async {
    await _storageService.saveEnquiry(enquiry);
  }
}
