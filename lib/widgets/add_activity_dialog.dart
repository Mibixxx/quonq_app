import 'package:flutter/material.dart';

class AddActivityDialog extends StatelessWidget {
  const AddActivityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('Nuova Attività'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Es. Piscina'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(name);
          },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}
