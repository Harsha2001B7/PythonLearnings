import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/toast_notification.dart';

class BookingModal extends StatelessWidget {
  final String vehicleName;

  const BookingModal({
    super.key,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKING REQUEST',
                        style: AppTypography.eyebrow(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicleName,
                        style: AppTypography.headingLarge(color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This is a frontend prototype. In the full SAFRA product, this form would collect your dates, insurance preferences, delivery address, and payment details — all in under 90 seconds.',
              style: AppTypography.bodyMedium(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton.amber(
                    text: 'Confirm Request',
                    onPressed: () {
                      Navigator.of(context).pop();
                      ToastNotification.show(
                        context,
                        'Booking request submitted for $vehicleName',
                        type: 'success',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton.ghost(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
