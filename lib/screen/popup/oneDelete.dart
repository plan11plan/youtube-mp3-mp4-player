import 'package:flutter/material.dart';

class OneDeleteDialog extends StatelessWidget {
  final Function(String, String) onDelete; // 수정된 부분
  final String title;
  final String fileType;

  OneDeleteDialog({required this.onDelete, required this.title, required this.fileType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Delete?',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
              'Do you want to delete this file?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () {
            onDelete(title, fileType); // 수정된 부분
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
