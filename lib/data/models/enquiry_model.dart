import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

/// Represents a submitted wholesale trade enquiry saved locally on the device.
class Enquiry extends Equatable {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final String status;
  final String buyerNote;
  final double totalEstimatedAmount;
  final int totalQuantity;

  const Enquiry({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.buyerNote,
    required this.totalEstimatedAmount,
    required this.totalQuantity,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'Submitted',
      buyerNote: json['buyerNote'] as String? ?? '',
      totalEstimatedAmount: (json['totalEstimatedAmount'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: json['totalQuantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'status': status,
    'buyerNote': buyerNote,
    'totalEstimatedAmount': totalEstimatedAmount,
    'totalQuantity': totalQuantity,
  };

  @override
  List<Object?> get props => [
    id,
    items,
    createdAt,
    status,
    buyerNote,
    totalEstimatedAmount,
    totalQuantity,
  ];
}
