import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/occurrence.dart';
import '../models/activity.dart';

class OccurrenceDialog extends StatefulWidget {
  final Activity activity;

  const OccurrenceDialog({super.key, required this.activity});

  @override
  State<OccurrenceDialog> createState() => _OccurrenceDialogState();
}

class _OccurrenceDialogState extends State<OccurrenceDialog> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController vascheController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi occorrenza'),
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
                setState(() => selectedDate = picked);
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Numero di vasche completate',
              ),
            ),
          if (widget.activity.name.toLowerCase() == "piscina")
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Calorie consumate'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            int? parsedVasche;
            int? parsedCalorie;
            if (widget.activity.name.toLowerCase() == "piscina") {
              parsedVasche = int.tryParse(vascheController.text) ?? 0;
              parsedCalorie = int.tryParse(calorieController.text) ?? 0;
            }
            Navigator.of(context).pop(
              Occurrence(
                date: selectedDate,
                vasche: widget.activity.name.toLowerCase() == "piscina"
                    ? parsedVasche
                    : null,
                calorie: widget.activity.name.toLowerCase() == "piscina"
                    ? parsedCalorie
                    : null,
              ),
            );
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
