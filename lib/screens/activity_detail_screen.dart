import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/activity.dart';
import '../models/occurrence.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final VoidCallback? onUpdate; // Per notificare modifiche al chiamante
  final void Function()? onSave;

  const ActivityDetailScreen(
      {Key? key, required this.activity, this.onUpdate, this.onSave})
      : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  void _editOccurrence(int index) async {
    Occurrence current = widget.activity.occurrences[index];
    DateTime selectedDate = current.date;
    int vasche = current.vasche ?? 0;

    final TextEditingController vascheController =
        TextEditingController(text: vasche.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Modifica occorrenza'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    'Data: ${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                  ),
                ),
                if (widget.activity.name.toLowerCase() == "piscina")
                  TextField(
                    controller: vascheController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(labelText: 'Numero di vasche'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  final updatedVasche =
                      int.tryParse(vascheController.text) ?? 0;

                  setState(() {
                    widget.activity.occurrences[index] = Occurrence(
                      date: selectedDate,
                      vasche: widget.activity.name.toLowerCase() == "piscina"
                          ? updatedVasche
                          : null,
                    );
                    _sortOccurrences();
                    _save();
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Salva'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.activity.occurrences.removeAt(index);
                    _save();
                  });
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Elimina'),
              ),
            ],
          );
        });
      },
    );
  }

  void _sortOccurrences() {
    widget.activity.occurrences.sort(
      (a, b) => b.date.compareTo(a.date),
    );
  }

  void _save() {
    widget.onSave?.call(); // salva le modifiche persistenti
    widget.onUpdate?.call(); // Per notificare il salvataggio
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
              SizedBox(height: 16),
              Text('Occorrenze (${widget.activity.count}):',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              ...widget.activity.occurrences.asMap().entries.map((entry) {
                final index = entry.key;
                final o = entry.value;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text("${o.date.day.toString().padLeft(2, '0')}/"
                        "${o.date.month.toString().padLeft(2, '0')}/"
                        "${o.date.year}"),
                    subtitle: widget.activity.name.toLowerCase() == "piscina" &&
                            o.vasche != null
                        ? Text('Vasche: ${o.vasche}')
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editOccurrence(index),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
