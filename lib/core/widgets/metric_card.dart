import 'package:flutter/material.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: AppDimens.metricCardHeight,
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.metricLabel),
            const SizedBox(height: AppDimens.spacingXs),
            Text(
              value,
              style: AppTextStyles.metricValue.copyWith(color: valueColor),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimens.spacingXs),
              Text(subtitle!, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
