import 'package:flutter/material.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/widgets/image_container_reports_details.dart';

class ReportDetails extends StatelessWidget {
  const ReportDetails({
    super.key,
    required this.author,
    required this.title,
    required this.place,
    required this.date,
    required this.description,
    required this.imageUrl,
  });

  final String author;
  final String title;
  final String place;
  final String description;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    void closeDetails() {
      Navigator.of(context).pop();
    }

    void openPlaceInMap() {
      // TODO: open place in maps
      AlertDialogs().notImplementedAlertCompiled(context);
    }

    final bool dark = isDarkMode(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "REPORT DETAILS",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Author:',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        author,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Title:',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(title),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Place:',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(place)),
                    IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: openPlaceInMap,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Date of Submission:',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(date)),
                  ],
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(description),
                  ],
                ),
                // image container
                if (imageUrl.isNotEmpty) const SizedBox(height: 10),
                if (imageUrl.isNotEmpty)
                  ReportDetailsImageContainer(imageUrl: imageUrl),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              width: 0.6,
                              color: dark ? Colors.white : Colors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: closeDetails,
                      child: Text(
                        "Close Details",
                        style: TextStyle(
                            color: dark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
