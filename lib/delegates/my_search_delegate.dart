import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reports/widgets/report_widget.dart';

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate({required this.reports, required this.openReportDetails});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> reports;

  final Function(String title, String author, String place, String date,
      String description, String imageUrl) openReportDetails;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme:
          AppBarTheme(color: Theme.of(context).appBarTheme.backgroundColor),
      inputDecorationTheme:
          const InputDecorationTheme(border: InputBorder.none),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
        },
        icon: const Icon(Icons.clear),
      ),
      if (query.isNotEmpty)
        IconButton(
            onPressed: () => showResults(context),
            icon: const Icon(Icons.search)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_ios, size: 20));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        List userReportsList = reports[index]["reportsList"];
        return ListView.builder(
          itemCount: userReportsList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Map<String, dynamic> report = userReportsList[index];
            String authorName = userReportsList[index]["author"];
            if (authorName.toLowerCase() == query.toLowerCase()) {
              return InkWell(
                onTap: () {
                  openReportDetails(
                      report["title"] ?? "No title",
                      report["author"],
                      report["place"],
                      report["dateOfSubmission"],
                      report["description"],
                      report["imageUrl"] ?? "");
                },
                child: ReportWidget(
                    title: report["title"] ?? "No title",
                    reportPlace: report["place"],
                    reportDate: report["dateOfSubmission"]),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        List<String> allUsersNames =
            List<String>.from(reports.map((name) => reports[index]["name"]));
        allUsersNames.sort();

        return ListTile(
          title: Text(allUsersNames[index]),
          onTap: () {
            query = allUsersNames[index];
            showResults(context);
          },
        );
      },
    );
  }
}
