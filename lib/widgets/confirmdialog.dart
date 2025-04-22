import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => ConfirmDialog(
                title: title,
                content: content,
                onConfirm: onConfirm,
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
