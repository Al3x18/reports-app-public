import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// link to access to file json data on the private repo on GitHub
const String privateRepoGitHubToken =
    'YOUR_TOKEN_HERE';
const String gitHubUser = "YOUR_GITHUB_USER_HERE";
const String repoName = "YOUR_GITHUB_REPO_NAME_HERE";
const String jsonFileName = "YOUR_JSON_FILE_NAME_HERE";
const String urlGitHubRepo =
    'https://api.github.com/repos/$gitHubUser/$repoName/contents/$jsonFileName';

const String minRequiredVersionJsonDocKey = "appMinimumRequiredVersion";
const String latestVersionJsonDocKey = "latestVersionAvailable";
const String downloadLinkJsonDocKey = "latestVersionApkDownloadLink";

class AppVersionControl {
  void downloadNewVersion(BuildContext context) async {
    // Get the raw file download link from reports_latest_app_version.json data
    final url = Uri.parse(urlGitHubRepo);
    final response = await http
        .get(url, headers: {'Authorization': 'token $privateRepoGitHubToken'});
    final data = jsonDecode(response.body);
    final gitHubRawUrl = data["download_url"];

    // Access to the data in file .json downloaded
    final jsonUrl = Uri.parse(gitHubRawUrl);
    final responseRawUrl = await http.get(jsonUrl);
    final dataFromRawLink = jsonDecode(responseRawUrl.body);

    final String downloadUrl = dataFromRawLink[downloadLinkJsonDocKey];

    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            right: 18,
            left: 18,
          ),
          content: Text(
            "An error occurred. Please try again later.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }

  String _compareVersions(
      String currentAppVersion, String minAppVersionRequired) {
    List<int> v1 = currentAppVersion.split(".").map(int.parse).toList();
    List<int> v2 = minAppVersionRequired.split(".").map(int.parse).toList();

    // Add zeros to make the two lists equal in length
    while (v1.length < v2.length) {
      v1.add(0);
    }
    while (v2.length < v1.length) {
      v2.add(0);
    }
    //Compare the components of the versions in an orderly manner
    for (int i = 0; i < v1.length; i++) {
      if (v1[i] < v2[i]) {
        return "currentIsLess"; // currentAppVersion is less than minAppVersionRequired
      } else if (v1[i] > v2[i]) {
        return "currentIsHigher"; // currentAppVersion is higher than minAppVersionRequired
      }
    }
    return "sameVersion"; // The versions are the same
  }

  Future<String> get latestVersionAvailable async {
    String latestVersionAvailable = "";
    // Get the raw file download link from reports_latest_app_version.json data
    final url = Uri.parse(urlGitHubRepo);
    final response = await http
        .get(url, headers: {'Authorization': 'token $privateRepoGitHubToken'});
    final data = jsonDecode(response.body);
    final gitHubRawUrl = data["download_url"];

    // Access to the data in file .json downloaded
    final jsonUrl = Uri.parse(gitHubRawUrl);
    final responseRawUrl = await http.get(jsonUrl);
    final dataFromRawLink = jsonDecode(responseRawUrl.body);

    latestVersionAvailable =
        dataFromRawLink[latestVersionJsonDocKey].toString();
    return latestVersionAvailable;
  }

  void checkAppVersion(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;

      // Get the raw file download link from reports_latest_app_version.json data
      final url = Uri.parse(urlGitHubRepo);
      final response = await http.get(url,
          headers: {'Authorization': 'token $privateRepoGitHubToken'});
      final data = jsonDecode(response.body);
      final gitHubRawUrl = data["download_url"];

      // Access to the data in file .json downloaded
      final jsonUrl = Uri.parse(gitHubRawUrl);
      final responseRawUrl = await http.get(jsonUrl);
      final dataFromRawLink = jsonDecode(responseRawUrl.body);

      final String appMinimumRequiredVersion =
          dataFromRawLink[minRequiredVersionJsonDocKey].toString();

      final String iOSdialogMessage =
          "The minimum required version is: $appMinimumRequiredVersion\nYour actual version is: $currentAppVersion\n\nYou need to update the App to continue using it.\n\nThe application will be close.";
      final String androidDialogMessage =
          "The minimum required version is: $appMinimumRequiredVersion\nYour actual version is: $currentAppVersion\n\nYou need to update the App to continue using it.\n\nPress 'Update' to download the latest version.";

      switch (_compareVersions(currentAppVersion, appMinimumRequiredVersion)) {
        case "currentIsLess":
          if (!context.mounted) {
            return;
          }
          showAdaptiveDialog(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text("A new version of the app is Available"),
                content: Platform.isIOS
                    ? Text(iOSdialogMessage)
                    : Text(androidDialogMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (Platform.isIOS) {
                        Navigator.of(context).pop();
                        exit(0);
                      }

                      if (Platform.isAndroid) {
                        downloadNewVersion(context);
                      }
                    },
                    child: Platform.isAndroid
                        ? const Text("UPDATE")
                        : const Text("CLOSE"),
                  ),
                ],
              );
            },
          );
          break;
        default:
      }
    } catch (e) {
      // ...
    }
  }
}
