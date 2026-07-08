import 'package:flutter/material.dart';
import '../constants/app_dimens.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimens.spacingSm),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
