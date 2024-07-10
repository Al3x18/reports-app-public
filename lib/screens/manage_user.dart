import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key, required this.userDetails});

  final Map<String, dynamic> userDetails;

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  /*
  To activate delete button you need to configure account deletion when a doc in
  a collection no longer exists from the Firebase console functions, and then delete
  the user uid that referred to that doc.
  Without this the user can still log in but without data it creates a serious bug.
  */
  final bool deactivateDeleteUser = true; //false to activate button

  late bool isAdmin;
  late bool isBlocked;

  @override
  void initState() {
    isAdmin = widget.userDetails["isAdmin"];
    isBlocked = widget.userDetails["isBlocked"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //const Color bgColor = Color.fromARGB(255, 252, 245, 237);

    bool itsYourUser = currentUserUid == widget.userDetails["uid"];
    int reportsListLength = widget.userDetails["reportsList"].length;

    void updateFirestoreIsBlocked(bool status) async {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userDetails["uid"])
            .update({
          "isBlocked": status,
        });
      } catch (e) {
        if (!context.mounted) {
          return;
        }
        AlertDialogs().fatalErrorDialogMessage(context, e.toString());
      }
    }

    void updateFirestoreIsAdmin(bool status) async {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userDetails["uid"])
            .update({
          "isAdmin": status,
        });
      } catch (e) {
        if (!context.mounted) {
          return;
        }
        AlertDialogs().fatalErrorDialogMessage(context, e.toString());
      }
    }

    void forceMasterDeletingToFalse() async {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userDetails["uid"])
            .update({
          "isMasterDeletingActive": false,
        });
      } catch (e) {
        if (!context.mounted) {
          return;
        }
        AlertDialogs().fatalErrorDialogMessage(context, e.toString());
      }
    }

    // void forceAdminStatusToFalse() async {
    //   try {
    //     await FirebaseFirestore.instance
    //         .collection("users")
    //         .doc(widget.userDetails["uid"])
    //         .update({
    //       "isAdmin": false,
    //     });
    //   } catch (e) {
    //     //...
    //   }
    // }

    void deleteUserAndAllHisData() async {
      if (itsYourUser) {
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: const Text(
                "CANNOT DELETE YOUR CURRENT USER",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("CONFIRM",
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
        return;
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userDetails["uid"])
          .delete();
    }

    void showDeleteDialog() {
      showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            title: const Text("Do you want to delete the user?"),
            content: const Text(
                "This action will remove the user and all his data."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteUserAndAllHisData();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "CONFIRM",
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),
            ],
          );
        },
      );
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

    return Scaffold(
      //backgroundColor: bgColor,
      appBar: AppBar(
        //backgroundColor: bgColor,
        title: const Text("Manage User"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text(
              "UID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.userDetails["uid"]),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              "NAME",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.userDetails["name"]),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text(
              "EMAIL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.userDetails["email"]),
            trailing: IconButton(
              onPressed: () {
                launchEmail(widget.userDetails["email"]);
              },
              icon: const Icon(Icons.mail_outline_outlined),
            ),
          ),
          ListTile(
              leading: isBlocked
                  ? const Icon(
                      Icons.lock,
                    )
                  : const Icon(Icons.lock_open),
              title: const Text(
                "USER BLOCKED",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: isBlocked
                  ? const Text(
                      "YES",
                      style: TextStyle(color: Colors.red),
                    )
                  : const Text("NO")),
          ListTile(
              leading: isAdmin
                  ? const Icon(Icons.admin_panel_settings)
                  : const Icon(Icons.admin_panel_settings_outlined),
              title: const Text(
                "IS ADMIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: isAdmin
                  ? const Text(
                      "YES",
                      style: TextStyle(color: Colors.red),
                    )
                  : const Text("NO")),
          ListTile(
              leading: widget.userDetails["isMasterDeletingActive"]
                  ? const Icon(Icons.warning)
                  : const Icon(Icons.warning_amber_outlined),
              title: const Text(
                "MASTER DELETING ACTIVE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: widget.userDetails["isMasterDeletingActive"]
                  ? const Text(
                      "YES",
                      style: TextStyle(color: Colors.red),
                    )
                  : const Text("NO")),
          //TODO: open list of user report
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text(
              "REPORTS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Number of reports registered: $reportsListLength"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () {
              AlertDialogs().snackBarAlertNotImplementedFeature(context);
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isBlocked = !isBlocked;
                    updateFirestoreIsBlocked(isBlocked);
                  });
                },
                child: Row(
                  children: [
                    !isBlocked
                        ? const Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.red,
                          )
                        : const Icon(Icons.lock_open_outlined, size: 14),
                    const SizedBox(width: 3),
                    !isBlocked
                        ? const Text(
                            "BLOCK USER",
                            style: TextStyle(color: Colors.red),
                          )
                        : const Text(
                            "UNLOCK USER",
                            style: TextStyle(color: Colors.blue),
                          ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isAdmin = !isAdmin;
                    updateFirestoreIsAdmin(isAdmin);
                    if (isAdmin == false) {
                      forceMasterDeletingToFalse();
                    }
                  });
                },
                child: Row(
                  children: [
                    !isAdmin
                        ? const Icon(Icons.admin_panel_settings_outlined,
                            size: 14)
                        : const Icon(Icons.admin_panel_settings, size: 14),
                    const SizedBox(width: 3),
                    !isAdmin
                        ? const Text(
                            "MAKE ADMIN",
                            style: TextStyle(color: Colors.blue),
                          )
                        : const Text(
                            "REMOVE ADMIN STATUS",
                            style: TextStyle(color: Colors.blue),
                          ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!deactivateDeleteUser)
            TextButton(
              onPressed: () {
                showDeleteDialog();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_outlined,
                      size: 18, color: Colors.redAccent),
                  SizedBox(width: 2),
                  Text(
                    "DELETE USER",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
