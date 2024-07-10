import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/widgets/report_widget.dart';

class DismissibleReportWidget extends StatefulWidget {
  const DismissibleReportWidget(
      {super.key,
      this.author = "",
      required this.report,
      required this.title,
      required this.reportPlace,
      required this.reportDate,
      required this.userUid});

  final Map<String, dynamic> report;
  final String author;
  final String title;
  final String reportPlace;
  final String reportDate;
  final String userUid;

  @override
  State<DismissibleReportWidget> createState() =>
      _DismissibleReportWidgetState();
}

class _DismissibleReportWidgetState extends State<DismissibleReportWidget> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(widget.report),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 14.5, top: 6, right: 3.5, left: 3.5),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(22)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                CupertinoIcons.trash,
                color: Colors.white,
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showAdaptiveDialog(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text("Do you really want to delete this report?"),
                content: const Text("WARNING: This action cannot be undone!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      try {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.userUid)
                            .update({
                          "reportsList": FieldValue.arrayRemove([widget.report])
                        });
                      } catch (e) {
                        AlertDialogs()
                            .fatalErrorDialogMessage(context, e.toString());
                      }

                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: ReportWidget(
            author: widget.author,
            title: widget.title,
            reportPlace: widget.reportPlace,
            reportDate: widget.reportDate));
  }
}
