import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/occurrence.dart';
import '../services/activity_storage_service.dart';
import '../widgets/edit_occurrence_dialog.dart';
import '../widgets/pool_activity_chart.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final List<Activity> allActivities;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    required this.allActivities,
  });

  @override
  ActivityDetailScreenState createState() => ActivityDetailScreenState();
}

class ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool get _isPiscina => widget.activity.name.toLowerCase() == 'piscina';
  bool showCalorie = true;

  Future<void> _editOccurrence(int index) async {
    final current = widget.activity.occurrences[index];

    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => EditOccurrenceDialog(
        initialOccurrence: current,
        showVasche: _isPiscina,
        showCalorie: _isPiscina,
      ),
    );

    if (result == null) return;

    if (result == 'delete') {
      setState(() {
        widget.activity.occurrences.removeAt(index);
      });
    } else if (result is Occurrence) {
      setState(() {
        widget.activity.occurrences[index] = result;
      });
    }

    _sortOccurrences();
    await _save();
  }

  void _sortOccurrences() {
    widget.activity.occurrences.sort(
      (a, b) => b.date.compareTo(a.date),
    );
  }

  Future<void> _save() async {
    await ActivityStorageService.instance
        .updateActivity(widget.activity, widget.allActivities);
  }

  @override
  void initState() {
    super.initState();
    _sortOccurrences();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && result == null) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dettagli "${widget.activity.name}"'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true); // <-- manual pop con risultato
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('Nome attività: ${widget.activity.name}',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),

              Text('Occorrenze (${widget.activity.count}):',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              // ⬇️ Lista delle occorrenze
              ...widget.activity.occurrences.asMap().entries.map((entry) {
                final index = entry.key;
                final o = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text("${o.date.day.toString().padLeft(2, '0')}/"
                        "${o.date.month.toString().padLeft(2, '0')}/"
                        "${o.date.year}"),
                    subtitle: _isPiscina &&
                            (o.vasche != null || o.calorie != null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (o.vasche != null) Text('Vasche: ${o.vasche}'),
                              if (o.calorie != null)
                                Text('Calorie: ${o.calorie}'),
                            ],
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editOccurrence(index),
                    ),
                  ),
                );
              }),

              // ⬇️ Divider e grafico a fondo pagina
              if (_isPiscina) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        showCalorie ? 'Attività: Calorie' : 'Attività: Vasche',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showCalorie = !showCalorie;
                          });
                        },
                        child: Text(
                          showCalorie ? 'Mostra Vasche' : 'Mostra Calorie',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: PoolActivityChart(
                    occurrences: widget.activity.occurrences,
                    showCalorie: showCalorie,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
