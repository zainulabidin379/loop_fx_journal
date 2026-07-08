import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.accent,
      AppButtonVariant.secondary => AppColors.surfaceElevated,
      AppButtonVariant.danger => AppColors.loss,
    };
    final foregroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.background,
      AppButtonVariant.secondary => AppColors.textPrimary,
      AppButtonVariant.danger => AppColors.textPrimary,
    };

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            side: variant == AppButtonVariant.secondary
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: AppDimens.iconMd,
                height: AppDimens.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimens.iconSm),
                    const SizedBox(width: AppDimens.spacingSm),
                  ],
                  Text(label, style: AppTextStyles.titleMedium.copyWith(color: foregroundColor)),
                ],
              ),
      ),
    );
  }
}
