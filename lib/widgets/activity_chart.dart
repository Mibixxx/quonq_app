import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';

class ActivityChart extends StatelessWidget {
  final List<Activity> activities;

  const ActivityChart({required this.activities, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(Duration(days: 365));
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
            .where((o) => o.date.isAfter(oneYearAgo))
            .length
            .toDouble())
        .toList();

    final maxCount =
        counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount;

    // Calcolo intervallo per avere 5 tick sull'asse Y
    final interval = maxY > 0 ? maxY / 4 : 1.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + interval, // per avere spazio sopra l'ultimo tick
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final activityName = activities[groupIndex].name;
                return BarTooltipItem(
                  '$activityName\n',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} volte',
                      style: const TextStyle(color: Colors.yellowAccent),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < activities.length) {
                    return Text(activities[value.toInt()].name);
                  } else {
                    return const Text('');
                  }
                },
              ),
            ),
          ),
          barGroups: activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final count = activity.occurrences
                .where((o) => o.date.isAfter(oneYearAgo))
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
      ),
    );
  }
}
