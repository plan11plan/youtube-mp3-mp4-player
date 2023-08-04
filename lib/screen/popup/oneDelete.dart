import 'package:flutter/material.dart';

class OneDeleteDialog extends StatelessWidget {
  final Function onDelete;
  final int index;

  OneDeleteDialog({required this.onDelete, required this.index});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete?'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text('Do you want to delete this video?', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            onDelete(index);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
