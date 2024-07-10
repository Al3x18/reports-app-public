import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/utils/app_version_control.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String version = "";
  String latestVersionAvailable = "";
  final String devName = "DEV_NAME_HERE";
  final String devEmailAddress = "DEV_EMAIL_HERE";

  @override
  void initState() {
    getAppVersion();
    getLatestAppVersionAvailable();
    super.initState();
  }

  void getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentAppVersion = packageInfo.version;
    // [if (mounted)] is needed to avoid errors if setState is called when the screen is no longer visible
    if (mounted) {
      setState(() {
      version = currentAppVersion;
    });
    }
  }

  void getLatestAppVersionAvailable() async {
    String lv = await AppVersionControl().latestVersionAvailable;
    // [if (mounted)] is needed to avoid errors if setState is called when the screen is no longer visible
    if (mounted) {
          setState(() {
      latestVersionAvailable = lv;
    });
    }
  }

  dynamic launchEmail(String emailAddress) async {
    try {
      Uri email = Uri(
        scheme: 'mailto',
        path: emailAddress,
      );

      await launchUrl(email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    "Reports App",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                  Text("Version: $version")
                ],
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              child: const ListTile(
                title: Text(
                  "Report a Bug",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("Send an email to developers"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mail_outlined),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
              onTap: () => launchEmail(devEmailAddress),
            ),
            InkWell(
              child: ListTile(
                title: const Text(
                  "Download Latest Version",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text("Latest version available: $latestVersionAvailable"),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
              onTap: () {
                if (Platform.isAndroid) {
                  AppVersionControl().downloadNewVersion(context);
                }

                if (Platform.isIOS) {
                  const String infoContent = "This feature is only available for Android devices.";
                  AlertDialogs().snackBarAlertNotToCompile(context, infoContent);
                }
              },
            ),
            const Spacer(),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    "Developed By:",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Center(
                    child: Text(
                      devName,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
