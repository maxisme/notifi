import 'package:flutter/material.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';

Future<void> showAlert(BuildContext context, String title, String description,
    {int duration, int gravity, VoidCallback onOkPressed}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: const Icon(
              Akaricons.triangleAlert,
              color: MyColour.red,
              size: 40,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.left,
          )
        ]),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: MyColour.grey),
            ),
          ),
          TextButton(
              onPressed: onOkPressed,
              child: const Text(
                'Ok',
                style: TextStyle(color: MyColour.black),
              )),
        ],
      );
    },
  );
}
