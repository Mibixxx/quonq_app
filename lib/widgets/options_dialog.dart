import 'package:flutter/material.dart';
import '../models/activity.dart';

typedef DetailCallback = Future<void> Function();
typedef DeleteCallback = Future<void> Function();

class OptionsDialog extends StatelessWidget {
  final Activity activity;
  final DetailCallback onViewDetails;
  final DeleteCallback onDelete;

  const OptionsDialog({
    super.key,
    required this.activity,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Opzioni "${activity.name}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: const Text('Visualizza dettagli'),
            onPressed: () async {
              Navigator.of(context).pop();
              await onViewDetails();
            },
          ),
          TextButton(
            child: const Text('Elimina'),
            onPressed: () async {
              Navigator.of(context).pop();
              await onDelete();
            },
          ),
        ],
      ),
    );
  }
}
