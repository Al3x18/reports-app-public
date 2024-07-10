import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reports/screens/general_loading.dart';
import 'package:reports/widgets/report_widget.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.openReportDetails});

  final Function(String title, String author, String place, String date,
      String description, String imageUrl) openReportDetails;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  var currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference firestoreData =
      FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestoreData.doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GeneralLoadingScreen();
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text("No Data Found"),
          );
        }

        List loadedData = snapshot.data!.get("reportsList");

        if (loadedData.isEmpty) {
          return const Center(
            child: Text("No Reports Found for Current User."),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            itemCount: loadedData.length,
            itemBuilder: (context, index) {
              var report = loadedData[index];
              return Dismissible(
                key: ValueKey(report),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(22)),
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
                        title: const Text(
                            "Do You Really Want to Delete this Report?"),
                        content: const Text(
                            "Warning: This action cannot be undone!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUserUid)
                                  .update({
                                "reportsList": FieldValue.arrayRemove([report])
                              });

                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: InkWell(
                  onTap: () {
                    String reportTitle = report["title"] ?? "No title";
                    String reportAuthor = report["author"];
                    String place = report["place"];
                    String description = report["description"];
                    String date = report["dateOfSubmission"];
                    String imageUrl = report["imageUrl"] ?? "";
                    widget.openReportDetails(reportTitle, reportAuthor, place,
                        date, description, imageUrl);
                  },
                  child: ReportWidget(
                      title: report["title"] ?? "No title",
                      reportPlace: report["place"],
                      reportDate: report["dateOfSubmission"]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
