import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/occurrence.dart';
import '../widgets/animated_activity_card.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/add_occurrence_dialog.dart';
import '../widgets/options_dialog.dart';
import '../screens/activity_detail_screen.dart';
import '../services/activity_storage_service.dart';
import '../widgets/activity_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> activities = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ActivityStorageService _storageService =
      ActivityStorageService.instance;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final loadedActivities = await _storageService.loadActivities();
    setState(() {
      activities = loadedActivities;
    });
    for (int i = 0; i < loadedActivities.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
  }

  Future<void> _saveActivities() async {
    await _storageService.saveActivities(activities);
  }

  Future<void> _showAddActivityDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const AddActivityDialog(),
    );

    if (name != null && name.trim().isNotEmpty) {
      final newActivity = Activity(name: name.trim());
      setState(() {
        activities.insert(0, newActivity);
        _listKey.currentState?.insertItem(0);
      });
      _saveActivities();
    }
  }

  Future<void> _showOccurrenceDialog(Activity activity) async {
    final occurrence = await showDialog<Occurrence>(
      context: context,
      builder: (context) => OccurrenceDialog(activity: activity),
    );

    if (occurrence != null) {
      setState(() {
        activity.occurrences.add(occurrence);
        activity.occurrences.sort((a, b) => b.date.compareTo(a.date));
      });
      await _saveActivities();
    }
  }

  Future<void> _decrement(Activity activity) async {
    if (activity.occurrences.isEmpty) return;

    setState(() {
      activity.occurrences.removeLast();
    });

    await _saveActivities();
  }

  Future<void> _showOptionsDialog(Activity activity, int index) async {
    await showDialog(
      context: context,
      builder: (context) => OptionsDialog(
        activity: activity,
        onViewDetails: () async {
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(
                activity: activity,
                allActivities: activities,
              ),
            ),
          );
          if (updated == true) {
            setState(() {});
          }
        },
        onDelete: () async {
          final removed = activities.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) =>
                _buildAnimatedItem(removed, index, animation),
            duration: const Duration(milliseconds: 300),
          );
          await _saveActivities();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività quonquettinose'),
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
              "Attività ultimo anno",
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
        onPressed: _showAddActivityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedItem(
      Activity activity, int index, Animation<double> animation) {
    return AnimatedActivityCard(
      activity: activity,
      index: index,
      animation: animation,
      onIncrement: () => _showOccurrenceDialog(activity),
      onDecrement: () => _decrement(activity),
      onLongPress: () => _showOptionsDialog(activity, index),
    );
  }
}
