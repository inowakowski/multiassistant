import 'package:flutter/material.dart';

void showDiscardDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: const Text(
          "Discard Changes?",
        ),
        content: const Text(
          "Are you sure you want to discard changes?",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "No",
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              "Yes",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context, true);
            },
          ),
        ],
      );
    },
  );
}
