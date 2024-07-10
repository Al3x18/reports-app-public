import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reports/utils/app_version_control.dart';
import 'package:reports/screens/admin_panel.dart';
import 'package:reports/screens/general_loading.dart';
import 'package:reports/screens/info.dart';
import 'package:reports/screens/my_reports.dart';
import 'package:reports/screens/settings.dart';
import 'package:reports/delegates/my_search_delegate.dart';
import 'package:reports/widgets/add_new_report.dart';
import 'package:reports/widgets/all_reports_v2.dart';
import 'package:reports/widgets/report_details.dart';
import 'package:reports/widgets/side_drawer.dart';
import 'package:reports/widgets/theme_mode_modal_sheet.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  var userUid = FirebaseAuth.instance.currentUser!.uid;
  String nameOfUser = "";
  int selectedIndex = 0;
  bool isUserAdmin = false;
  bool isUserBlocked = false;

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool isConnected = true;

  @override
  void initState() {
    AppVersionControl().checkAppVersion(context);
    getNameOfCurrentUser();
    checkUserAdminState();
    checkUserBlockState();
    super.initState();
  }

  /// Updates the state of the widget when the dependencies change.
  ///
  /// This method is called after the widget's dependencies have changed and
  /// immediately before the framework calls the build method. It is typically
  /// used to update the state of the widget based on the new dependencies.
  ///
  /// The [checkConnectivity] method is called to check the current network
  /// connectivity status.
  ///
  /// The [super.didChangeDependencies] method is called to invoke the
  /// corresponding method in the superclass.
  @override
  void didChangeDependencies() {
    checkConnectivity();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void checkConnectivity() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      for (var elem in result) {
        if (elem == ConnectivityResult.none) {
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isConnected = true;
            });
          }
        }
      }
    });
  }

  void onTappedItem(int index) {
    if (mounted) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  void getNameOfCurrentUser() async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userUid).get();

    String name = userDataSnapshot.data()!["name"];
    if (mounted) {
      setState(() {
        nameOfUser = name;
      });
    }
  }

  void checkUserAdminState() async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userUid).get();

    bool isAdmin = userDataSnapshot.data()!["isAdmin"];
    if (mounted) {
      setState(() {
        isUserAdmin = isAdmin;
      });
    }
  }

  void checkUserBlockState() async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userUid).get();

    bool isBlocked = userDataSnapshot.data()!["isBlocked"];
    if (mounted) {
      setState(() {
        isUserBlocked = isBlocked;
      });
    }
  }

  void logOutUser() {
    FirebaseAuth.instance.signOut();
  }

  void openReportDetails(String title, String author, String place, String date,
      String desc, String imageUrl) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (ctx) => SingleChildScrollView(
        child: ReportDetails(
          title: title,
          author: author,
          place: place,
          date: date,
          description: desc,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  void addReport() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (ctx) => const SingleChildScrollView(child: AddNewReport()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final dark = isDarkMode(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!isConnected) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      "No connection available.\nCheck your internet connection and try again."),
                  const SizedBox(height: 28),
                  TextButton(
                      onPressed: () {
                        checkConnectivity();
                      },
                      child: const Text("Refresh")),
                ],
              )),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GeneralLoadingScreen();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 252, 245, 237),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 252, 245, 237),
              title: const Text("Reports List"),
              actions: [
                IconButton(onPressed: addReport, icon: const Icon(Icons.add)),
                IconButton(
                    onPressed: logOutUser,
                    icon: const Icon(Icons.logout_outlined)),
              ],
            ),
            body: const Center(
              child: Text("No reports found."),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 252, 245, 237),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 252, 245, 237),
              title: const Text("Error Page"),
            ),
            body: Center(
              child: Column(
                children: [
                  const Text("Something went wrong."),
                  ElevatedButton(
                      onPressed: logOutUser, child: const Text("Logout")),
                ],
              ),
            ),
          );
        }
        final loadedReports = snapshot.data!.docs;

        return Scaffold(
          // backgroundColor: const Color.fromARGB(255, 252, 245, 237),
          appBar: AppBar(
            //backgroundColor: const Color.fromARGB(255, 252, 245, 237),
            title: selectedIndex == 0
                ? const Text("Reports List")
                : selectedIndex == 1
                    ? const Text("My Reports")
                    : selectedIndex == 2
                        ? const Text("Admin Panel")
                        : selectedIndex == 3
                            ? const Text("Settings")
                            : const Text("Info"),
            actions: [
              IconButton(
                onPressed: () => showThemeModeModalSheet(context),
                icon: const Icon(Icons.tune_outlined),
              ),
              if (selectedIndex == 0)
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: MySearchDelegate(
                        reports: loadedReports,
                        openReportDetails: openReportDetails,
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
            ],
          ),
          floatingActionButton: selectedIndex == 0 || selectedIndex == 1
              ? FloatingActionButton(
                  tooltip: "Add new report",
                  backgroundColor: dark ? Colors.white : Colors.blue,
                  foregroundColor: dark ? Colors.black : Colors.white,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    addReport();
                  },
                  child: const Icon(Icons.add, size: 25),
                )
              : null,
          drawer: SideDrawer(
            nameOfUser: nameOfUser,
            isAdmin: isUserAdmin,
            loadedReports: loadedReports,
            onItemTapped: onTappedItem,
            selectedIndex: selectedIndex,
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: [
              AllReportsV2(
                  loadedReports: loadedReports,
                  openReportDetails: openReportDetails),
              MyReportsScreen(openReportDetails: openReportDetails),
              const AdminPanelScreen(),
              const SettingsScreen(),
              const InfoScreen()
            ],
          ),
        );
      },
    );
  }
}
