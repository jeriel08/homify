import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportTrendChart extends StatelessWidget {
  final Map<String, int> dailyData;

  const ReportTrendChart({super.key, required this.dailyData});

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    // Convert daily data to chart data
    final chartData = dailyData.entries
        .map((entry) => _ChartData(entry.key, entry.value.toDouble()))
        .toList();

    // If no data, show placeholder
    if (chartData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Reports (This Week)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const Gap(20),
            const SizedBox(
              height: 250,
              child: Center(child: Text('No data available')),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Reports (This Week)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: textSecondary),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: textSecondary),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.shade200,
                  dashArray: const [5, 5],
                ),
                axisLine: const AxisLine(width: 0),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: primary,
                textStyle: const TextStyle(color: Colors.white),
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.3),
                      primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  color: primary,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 8,
                    width: 8,
                    borderWidth: 3,
                    borderColor: primary,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chart Data Model
class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}
