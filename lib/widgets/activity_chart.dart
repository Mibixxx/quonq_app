import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';

class ActivityChart extends StatelessWidget {
  final List<Activity> activities;

  ActivityChart({required this.activities});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(Duration(days: 30));
    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.red,
    ];

    final counts = activities
        .map((activity) => activity.occurrences
            .where((d) => d.isAfter(oneMonthAgo))
            .length
            .toDouble())
        .toList();

    final maxCount =
        counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final activityName = activities[groupIndex].name;
              return BarTooltipItem(
                '$activityName\n',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} volte',
                    style: TextStyle(color: Colors.yellowAccent),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  Text(activities[value.toInt()].name),
            ),
          ),
        ),
        barGroups: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final count = activity.occurrences
              .where(
                  (d) => d.isAfter(DateTime.now().subtract(Duration(days: 30))))
              .length;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(6),
                width: 18,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
