import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/occurrence.dart';

class EditOccurrenceDialog extends StatefulWidget {
  final Occurrence initialOccurrence;
  final bool showVasche;
  final bool showCalorie;

  const EditOccurrenceDialog({
    super.key,
    required this.initialOccurrence,
    required this.showVasche,
    required this.showCalorie,
  });

  @override
  State<EditOccurrenceDialog> createState() => _EditOccurrenceDialogState();
}

class _EditOccurrenceDialogState extends State<EditOccurrenceDialog> {
  late DateTime _selectedDate;
  late TextEditingController _vascheController;
  late TextEditingController _calorieController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialOccurrence.date;
    _vascheController = TextEditingController(
      text: widget.initialOccurrence.vasche?.toString() ?? '',
    );
    _calorieController = TextEditingController(
      text: widget.initialOccurrence.calorie?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _vascheController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica occorrenza'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Text(
              'Data: ${_selectedDate.day.toString().padLeft(2, '0')}/'
              '${_selectedDate.month.toString().padLeft(2, '0')}/'
              '${_selectedDate.year}',
            ),
          ),
          if (widget.showVasche)
            TextField(
              controller: _vascheController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Numero di vasche'),
            ),
          if (widget.showCalorie)
            TextField(
              controller: _calorieController,
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
            int? parseInput(TextEditingController controller, bool enabled) {
              return enabled ? int.tryParse(controller.text) : null;
            }

            int? vasche = parseInput(_vascheController, widget.showVasche);
            int? calorie = parseInput(_calorieController, widget.showCalorie);

            Navigator.of(context).pop(
              Occurrence(
                date: _selectedDate,
                vasche: vasche,
                calorie: calorie,
              ),
            );
          },
          child: const Text('Salva'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Elimina'),
        ),
      ],
    );
  }
}
