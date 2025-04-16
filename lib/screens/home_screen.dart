import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../widgets/activity_chart.dart';
import '../widgets/activity_card.dart';
import '../services/local_storage.dart';

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
    _loadAndInsertActivities();
  }

  Future<void> _loadAndInsertActivities() async {
    final loadedActivities = await loadActivities();

    setState(() {
      activities.clear();
    });

    for (int i = 0; i < loadedActivities.length; i++) {
      activities.add(loadedActivities[i]);
      _listKey.currentState?.insertItem(i);
    }
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
                saveActivities(activities);
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
    saveActivities(activities);
  }

  void _decrement(Activity activity) {
    setState(() {
      if (activity.occurrences.isNotEmpty) activity.occurrences.removeLast();
    });
    saveActivities(activities);
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
                  saveActivities(activities);
                  Navigator.of(context).pop();
                },
              ));
        });
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
      child: ActivityCard(
        activity: activity,
        onIncrement: () => _increment(activity),
        onDecrement: () => _decrement(activity),
        onLongPress: () => _options(activity, index),
      ),
    );
  }
}
