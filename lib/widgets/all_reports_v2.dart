import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/widgets/dismissible_report_widget.dart';
import 'package:reports/widgets/report_widget.dart';

class AllReportsV2 extends StatefulWidget {
  const AllReportsV2(
      {super.key,
      required this.loadedReports,
      required this.openReportDetails});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedReports;
  final Function(String title, String author, String place, String date,
      String description, String imageUrl) openReportDetails;

  @override
  State<AllReportsV2> createState() => _AllReportsV2State();
}

class _AllReportsV2State extends State<AllReportsV2> {
  bool isMasterDeletingEnabled = false;

  @override
  void didChangeDependencies() {
    checkMasterDeletingState();
    super.didChangeDependencies();
  }

  void checkMasterDeletingState() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get();

      bool masterDeleting = userDataSnapshot.data()!["isMasterDeletingActive"];

      setState(() {
        isMasterDeletingEnabled = masterDeleting;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      AlertDialogs().fatalErrorDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasReports =
        widget.loadedReports.any((user) => user["reportsList"].isNotEmpty);

    if (!hasReports) {
      return const Center(
        child: Text(
          'No Reports Found.',
        ),
      );
    }

    List usersDataJQDS = [];
    List usersDetails = [];

    for (var index = 0; index < widget.loadedReports.length; index++) {
      usersDataJQDS.add(widget.loadedReports[index]);
    }
    for (var snapshot in usersDataJQDS) {
      usersDetails.add(snapshot.data());
    }

    final DateFormat dateFormat = DateFormat.yMMMd().add_Hm();

    // Ordina la lista per mettere al primo posto gli utenti con i report più recenti
    usersDetails.sort((a, b) {
      if (a['reportsList'].isEmpty && b['reportsList'].isNotEmpty) {
        return 1;
      } else if (a['reportsList'].isNotEmpty && b['reportsList'].isEmpty) {
        return -1;
      } else if (a['reportsList'].isEmpty && b['reportsList'].isEmpty) {
        return 0;
      } else {
        var lastReportA =
            dateFormat.parse(a['reportsList'].last['dateOfSubmission']);
        var lastReportB =
            dateFormat.parse(b['reportsList'].last['dateOfSubmission']);
        return lastReportB.compareTo(lastReportA);
      }
    });

    List<Map<String, dynamic>> usersReports = [];

    for (var index = 0; index < widget.loadedReports.length; index++) {
      List userReportsList = usersDetails[index]["reportsList"];
      bool isReportListEmpty = userReportsList.isEmpty;
      bool isUserBlocked = usersDetails[index]["isBlocked"];
      if (!isReportListEmpty && !isUserBlocked) {
        for (Map<String, dynamic> report in userReportsList) {
          usersReports.add(report);
        }
      }
    }

    // Order the reports by date from latest to oldest
    usersReports.sort((a, b) {
      DateTime dateA =
          DateFormat('MMM dd, yyyy HH:mm').parse(a['dateOfSubmission']);
      DateTime dateB =
          DateFormat('MMM dd, yyyy HH:mm').parse(b['dateOfSubmission']);
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      itemCount: usersReports.length,
      itemBuilder: (context, reportIndex) {
        Map<String, dynamic> report = usersReports[reportIndex];
        String author = usersReports[reportIndex]["author"];
        String userUID = usersReports[reportIndex]["userUID"];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            String reportTitle = report["title"] ?? "No title";
            String reportAuthor = report["author"];
            String place = report["place"];
            String description = report["description"];
            String date = report["dateOfSubmission"];
            String imageUrl = report["imageUrl"] ?? "";
            widget.openReportDetails(
                reportTitle, reportAuthor, place, date, description, imageUrl);
          },
          child: isMasterDeletingEnabled
              ? DismissibleReportWidget(
                  author: author,
                  report: report,
                  title: report["title"] ?? "No title",
                  reportPlace: report["place"],
                  reportDate: report["dateOfSubmission"] ?? "No Date",
                  userUid: userUID,
                )
              : ReportWidget(
                  author: author,
                  title: report["title"] ?? "No title",
                  reportPlace: report["place"],
                  reportDate: report["dateOfSubmission"] ?? "No Date",
                ),
        );
      },
    );
  }
}
