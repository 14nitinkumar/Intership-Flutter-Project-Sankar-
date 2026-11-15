import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../utils/common_widgets/empty_state_view.dart';
import 'enquiry_cubit.dart';
import 'enquiry_state.dart';

class EnquiryScreen extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const EnquiryScreen({
    super.key,
    this.onBrowseProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trade Enquiries History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<EnquiryCubit>().loadHistory(),
          ),
        ],
      ),
      body: BlocBuilder<EnquiryCubit, EnquiryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.actionTeal),
              ),
            );
          }

          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.history_edu_rounded,
              title: 'No Trade Enquiries Submitted',
              message: 'When you submit a quote request from your Enquiry Cart, it will appear here for status tracking.',
              buttonText: 'Discover Products',
              onButtonPressed: onBrowseProducts ?? () => Navigator.maybePop(context),
            );
          }

          final formatter = DateFormat('dd MMM yyyy, hh:mm a');

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.enquiries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final enquiry = state.enquiries[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          enquiry.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            enquiry.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.actionTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatter.format(enquiry.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const Divider(height: 20),
                    ...enquiry.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x ',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.actionTeal,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Total Quote:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                        Text(
                          '\$${enquiry.totalEstimatedAmount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    if (enquiry.buyerNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Note: ${enquiry.buyerNote}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
