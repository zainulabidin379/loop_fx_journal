import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../domain/entities/dashboard_entities.dart';

class EquityChart extends StatelessWidget {
  const EquityChart({super.key, required this.points});

  final List<EquityPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: AppDimens.chartHeight,
        child: Center(child: Text(AppStrings.noTradesYet, style: AppTextStyles.bodySmall)),
      );
    }

    return SizedBox(
      height: AppDimens.chartHeight,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    NumberFormatter.format(spot.y),
                    AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].cumulativePnl),
              ],
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WinLossDonutChart extends StatelessWidget {
  const WinLossDonutChart({super.key, required this.data});

  final List<ChartBreakdown> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, e) => sum + e.value);
    if (total == 0) {
      return SizedBox(
        height: AppDimens.chartHeight,
        child: Center(child: Text(AppStrings.noTradesYet, style: AppTextStyles.bodySmall)),
      );
    }

    final colors = [AppColors.profit, AppColors.loss, AppColors.breakeven];
    return SizedBox(
      height: AppDimens.chartHeight,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            for (var i = 0; i < data.length; i++)
              if (data[i].value > 0)
                PieChartSectionData(
                  value: data[i].value,
                  color: colors[i % colors.length],
                  title: '${data[i].count}',
                  radius: 50,
                  titleStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
          ],
        ),
      ),
    );
  }
}

class BreakdownBarChart extends StatelessWidget {
  const BreakdownBarChart({super.key, required this.data, required this.title});

  final List<ChartBreakdown> data;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = data.map((e) => e.value.abs()).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimens.spacingMd),
        SizedBox(
          height: AppDimens.chartHeight,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal == 0 ? 1 : maxVal * 1.2,
              minY: data.any((e) => e.value < 0) ? -maxVal * 1.2 : 0,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[index].label,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final color = rod.toY >= 0 ? AppColors.profit : AppColors.loss;
                    return BarTooltipItem(
                      NumberFormatter.format(rod.toY),
                      AppTextStyles.bodyMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].value,
                        color: data[i].value >= 0 ? AppColors.profit : AppColors.loss,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
