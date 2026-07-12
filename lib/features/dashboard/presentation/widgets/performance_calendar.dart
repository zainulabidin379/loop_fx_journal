import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../trade/domain/entities/trade.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/utils/dashboard_analytics.dart';
import 'day_trades_sheet.dart';

class _CalendarCell {
  const _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
    this.summary,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final DailyTradeSummary? summary;
}

class PerformanceCalendar extends StatefulWidget {
  const PerformanceCalendar({super.key, required this.trades});

  final List<Trade> trades;

  @override
  State<PerformanceCalendar> createState() => _PerformanceCalendarState();
}

class _PerformanceCalendarState extends State<PerformanceCalendar> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  List<_CalendarCell> _buildCells(Map<DateTime, DailyTradeSummary> summaries) {
    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingDays = firstOfMonth.weekday - 1;

    final cells = <_CalendarCell>[];

    for (var i = leadingDays; i > 0; i--) {
      final date = firstOfMonth.subtract(Duration(days: i));
      cells.add(_CalendarCell(date: date, isCurrentMonth: false));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      cells.add(
        _CalendarCell(
          date: date,
          isCurrentMonth: true,
          summary: summaries[date],
        ),
      );
    }

    final trailingDays = (7 - (cells.length % 7)) % 7;
    final lastOfMonth = DateTime(year, month, daysInMonth);
    for (var i = 1; i <= trailingDays; i++) {
      final date = lastOfMonth.add(Duration(days: i));
      cells.add(_CalendarCell(date: date, isCurrentMonth: false));
    }

    return cells;
  }

  void _onDayTap(_CalendarCell cell) {
    if (!cell.isCurrentMonth || cell.summary == null || cell.summary!.tradeCount == 0) {
      return;
    }
    final trades = DashboardAnalytics.tradesForDay(widget.trades, cell.date);
    DayTradesSheet.show(context, date: cell.date, trades: trades);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = DashboardAnalytics.earliestTradeMonth(widget.trades);
    final canGoPrev = earliest != null &&
        (_visibleMonth.year > earliest.year ||
            (_visibleMonth.year == earliest.year && _visibleMonth.month > earliest.month));
    final canGoNext = _visibleMonth.year < now.year ||
        (_visibleMonth.year == now.year && _visibleMonth.month < now.month);

    final summaries = DashboardAnalytics.dailySummariesForMonth(
      widget.trades,
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final cells = _buildCells(summaries);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.performanceCalendar, style: AppTextStyles.titleMedium),
              ),
              IconButton(
                onPressed: canGoPrev ? _goToPreviousMonth : null,
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                DateFormatter.formatMonthYear(_visibleMonth),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: canGoNext ? _goToNextMonth : null,
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingMd),
          Row(
            children: AppStrings.calendarWeekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(day, style: AppTextStyles.labelMedium),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimens.spacingSm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: AppDimens.spacingXs,
              crossAxisSpacing: AppDimens.spacingXs,
              childAspectRatio: 0.85,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final cell = cells[index];
              return _DayCell(
                cell: cell,
                isToday: cell.date == today,
                onTap: () => _onDayTap(cell),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.cell,
    required this.isToday,
    required this.onTap,
  });

  final _CalendarCell cell;
  final bool isToday;
  final VoidCallback onTap;

  Color? _borderColor() {
    final summary = cell.summary;
    if (summary == null || summary.tradeCount == 0) {
      return isToday ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border;
    }
    if (summary.pnl > 0) return AppColors.profit;
    if (summary.pnl < 0) return AppColors.loss;
    return AppColors.breakeven;
  }

  Color? _dotColor() {
    final summary = cell.summary;
    if (summary == null || summary.tradeCount == 0) return null;
    if (summary.pnl > 0) return AppColors.profit;
    if (summary.pnl < 0) return AppColors.loss;
    return AppColors.breakeven;
  }

  Color _pnlColor(double pnl) {
    if (pnl > 0) return AppColors.profit;
    if (pnl < 0) return AppColors.loss;
    return AppColors.breakeven;
  }

  @override
  Widget build(BuildContext context) {
    final summary = cell.summary;
    final hasTrades = summary != null && summary.tradeCount > 0;
    final dotColor = _dotColor();
    final borderColor = _borderColor()!;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: InkWell(
        onTap: hasTrades && cell.isCurrentMonth ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(AppDimens.spacingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateBadge(
                    day: cell.date.day,
                    isToday: isToday && cell.isCurrentMonth,
                    isCurrentMonth: cell.isCurrentMonth,
                  ),
                  if (dotColor != null && cell.isCurrentMonth)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    )
                  else
                    const SizedBox(width: 6),
                ],
              ),
              if (hasTrades && cell.isCurrentMonth) ...[
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(summary.pnl),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _pnlColor(summary.pnl),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${summary.tradeCount} ${AppStrings.calendarTrades}',
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.day,
    required this.isToday,
    required this.isCurrentMonth,
  });

  final int day;
  final bool isToday;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.labelMedium.copyWith(
      color: isCurrentMonth ? AppColors.textPrimary : AppColors.textMuted,
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
    );

    if (isToday) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$day',
          style: textStyle.copyWith(color: AppColors.background, fontSize: 11),
        ),
      );
    }

    return Text('$day', style: textStyle.copyWith(fontSize: 11));
  }
}
