import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/local_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final activityName = activities[groupIndex].name;
              return BarTooltipItem(
                '$activityName\n',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.y.toInt()} volte',
                    style: TextStyle(color: Colors.yellowAccent),
                  )
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => activities[value.toInt()].name,
            getTextStyles: (context) =>
                TextStyle(fontSize: 10, color: Colors.black87),
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
                y: count.toDouble(),
                colors: [colors[index % colors.length]],
                borderRadius: BorderRadius.circular(6),
                width: 18,
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> activities = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      final loadedActivities = jsonData
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        activities.clear();
      });

      for (int i = 0; i < loadedActivities.length; i++) {
        activities.add(loadedActivities[i]);
        _listKey.currentState?.insertItem(i);
      }
    }
  }

  Future<void> _saveActivities() async {
    final file = await _localFile;
    final jsonData = activities.map((activity) => activity.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/activities.json');
  }

  void _addActivity() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        return AlertDialog(
          title: Text('Nuova Attività'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newName = value,
            decoration: InputDecoration(hintText: 'Es. Piscina'),
          ),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Aggiungi'),
              onPressed: () {
                if (newName.trim().isEmpty) return;
                final newActivity = Activity(name: newName.trim());
                setState(() {
                  activities.insert(0, newActivity);
                  _listKey.currentState?.insertItem(0);
                });
                _saveActivities();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _increment(Activity activity) {
    setState(() {
      activity.occurrences.add(DateTime.now());
    });
    _saveActivities();
  }

  void _decrement(Activity activity) {
    setState(() {
      if (activity.occurrences.isNotEmpty) activity.occurrences.removeLast();
    });
    _saveActivities();
  }

  void _options(Activity activity, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Opzioni "${activity.name}"'),
              content: TextButton(
                child: const Text('Elimina'),
                onPressed: () {
                  final removed = activities.removeAt(index);
                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) =>
                        _buildAnimatedItem(removed, index, animation),
                    duration: Duration(milliseconds: 300),
                  );
                  _saveActivities();
                  Navigator.of(context).pop();
                },
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: activities.length,
              itemBuilder: (context, index, animation) {
                final activity = activities[index];
                return _buildAnimatedItem(activity, index, animation);
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Attività ultimo mese",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: ActivityChart(activities: activities),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedItem(
      Activity activity, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _buildActivityCard(activity, index),
    );
  }

  Widget _buildActivityCard(Activity activity, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GestureDetector(
        onLongPress: () => _options(activity, index),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _decrement(activity),
                    ),
                    Text(
                      '${activity.count}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _increment(activity),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
