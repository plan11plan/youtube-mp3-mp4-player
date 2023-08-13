import 'package:flutter/material.dart';

class OneDeleteDialog extends StatelessWidget {
  final Function(String, String) onDelete;
  final String title;
  final String fileType;

  OneDeleteDialog({required this.onDelete, required this.title, required this.fileType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete?',
        style: TextStyle(
            color: Colors.black,
            fontSize: 45,
            fontFamily: 'font1'),
      ),
      contentPadding: EdgeInsets.all(15.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      backgroundColor: Colors.grey[800],
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Do you want to delete this file?',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16)),
          onPressed: () {
            onDelete(title, fileType);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
