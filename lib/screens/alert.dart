import 'package:flutter/material.dart';
import '../theme.dart';

class AlertOptions {
  final String? buttonText;
  final Function()? onPressed;

  AlertOptions({this.buttonText, this.onPressed});
}

class Error {
  static Future<void> show(BuildContext context, String errorMessage, [AlertOptions? options]) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error, size: 50, color: attention),
                const SizedBox(height: 20),
                Text(errorMessage, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: options?.onPressed ?? () {
                Navigator.of(context).pop();
              },
              child: Text(options?.buttonText ?? 'CLOSE'),
            ),
          ],
        );
      },
    );
  }
}

class Success {
  static Future<void> show(BuildContext context, String message, [AlertOptions? options]) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.check_circle, size: 50, color: accent),
                const SizedBox(height: 20),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: options?.onPressed ?? () {
                Navigator.of(context).pop();
              },
              child: Text(options?.buttonText ?? 'CLOSE'),
            ),
          ],
        );
      },
    );
  }
}
