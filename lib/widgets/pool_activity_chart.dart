import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/occurrence.dart';

class PoolActivityChart extends StatelessWidget {
  final List<Occurrence> occurrences;
  final bool showCalorie;

  const PoolActivityChart({
    super.key,
    required this.occurrences,
    required this.showCalorie,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...occurrences]..sort((a, b) => a.date.compareTo(b.date));

    final points = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final value = showCalorie ? sorted[i].calorie : sorted[i].vasche;
      if (value != null) {
        points.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }

    if (points.isEmpty) {
      return const Center(child: Text("Nessun dato disponibile"));
    }

    // Trova il valore massimo sull'asse Y
    final maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final interval = maxY > 0 ? maxY / 4 : 1.0;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          maxY: maxY + interval, // per lasciare un po' di spazio sopra
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: showCalorie ? Colors.red : Colors.blue,
              barWidth: 3,
              spots: points,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // spazio per i valori Y
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < sorted.length) {
                    final date = sorted[index].date;
                    final formatted =
                        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                    return Text(formatted,
                        style: const TextStyle(fontSize: 10));
                  } else {
                    return const Text('');
                  }
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }
}
