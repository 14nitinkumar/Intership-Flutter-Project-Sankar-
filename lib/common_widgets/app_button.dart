import 'package:flutter/material.dart';
import '../core/app_colors.dart';

enum ButtonType { primary, secondary, destructive }

/// Standard reusable button for the VyapaarHub application.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, height),
          side: const BorderSide(color: AppColors.primaryNavy, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildChild(AppColors.primaryNavy),
      );
    }

    if (type == ButtonType.destructive) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          minimumSize: Size(double.infinity, height),
          side: const BorderSide(color: AppColors.error, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildChild(AppColors.error),
      );
    }

    // Default: Primary (Action Teal)
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.actionTeal,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.actionTeal.withValues(alpha: 0.6),
        minimumSize: Size(double.infinity, height),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildChild(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: contentColor,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}
