import 'package:flutter/material.dart';

class ReportWidget extends StatelessWidget {
  const ReportWidget({
    super.key,
    this.author = "",
    required this.title,
    required this.reportPlace,
    required this.reportDate,
  });

  final String author;
  final String? reportPlace;
  final String? reportDate;
  final String? title;

  @override
  Widget build(BuildContext context) {
    List<String> completeDate = reportDate!.split(" ");
    // ignore: unused_local_variable
    String shortDateWithYear =
        "${completeDate[0]} ${completeDate[1]} ${completeDate[2]}";
    String shortDateWithHour =
        "${completeDate[0]} ${completeDate[1]} ${completeDate[3]}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.5),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 13, top: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (author.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        author,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(title!,
                          overflow: TextOverflow.ellipsis, softWrap: false)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_outlined),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(reportPlace!,
                          overflow: TextOverflow.ellipsis, softWrap: false)),
                  const Spacer(),
                  Text(
                    shortDateWithHour,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(decoration: TextDecoration.overline),
                  ),
                  const SizedBox(width: 4.5),
                  const Icon(Icons.date_range_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
