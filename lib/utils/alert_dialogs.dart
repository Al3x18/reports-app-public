import 'package:flutter/material.dart';

class AlertDialogs {
  void notImplementedAlert(
      BuildContext context, String alertTitle, String alertContent) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(alertTitle),
          content: Text(alertContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }

  void notImplementedAlertCompiled(BuildContext context) {
    String alertTitle = "Work in progress...";
    String alertContent =
        "This feature has not been implemented yet, please try again in the future.";
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(alertTitle),
          content: Text(alertContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }

  void fatalErrorDialogMessage(BuildContext context, String alertContent) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("FATAL ERROR"),
          content: Text(alertContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }

  void infoDialog(BuildContext context, String infoTitle, String infoContent) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(infoTitle),
          content: Text(infoContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }

  void snackBarAlertNotImplementedFeature(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        dismissDirection: DismissDirection.endToStart,
        behavior: SnackBarBehavior.floating,
        content: Text("This feature has not been implemented yet.\nWork in progress..."),
        ),
    );
  }

  void snackBarAlertNotToCompile(BuildContext context, String alertText) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.endToStart,
        behavior: SnackBarBehavior.floating,
        content: Text(alertText),
        ),
    );
  }
}
