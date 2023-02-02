import 'package:flutter/material.dart';

showEmptyNameDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: const Text(
          "Name is empty!",
        ),
        content: const Text(
          'The name of the note cannot be empty.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "Okay",
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
