import 'package:flutter/material.dart';

class OneDeleteDialog extends StatelessWidget {
  final Function onDelete;
  final int index;

  OneDeleteDialog({required this.onDelete, required this.index});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,  // Background color set to black
      shape: RoundedRectangleBorder(  // Rounded borders
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Delete?',
        style: TextStyle(color: Colors.white),  // Text color set to white
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
              'Do you want to delete this file?',
              style: TextStyle(color: Colors.white),  // Text color set to white
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red),),  // Green text
          onPressed: () {
            onDelete(index);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),  // White text
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
