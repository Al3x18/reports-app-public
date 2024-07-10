import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reports/screens/users_list.dart';
import 'package:reports/utils/alert_dialogs.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    checkMasterDeletingState();
    super.initState();
  }

  bool isLoading = false;
  bool masterDeletingState = false;

  final user = FirebaseAuth.instance.currentUser;

  void checkMasterDeletingState() async {
    try {
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get();

      bool masterDeleting = userDataSnapshot.data()!["isMasterDeletingActive"];

      setState(() {
        masterDeletingState = masterDeleting;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      AlertDialogs().fatalErrorDialogMessage(context, e.toString());
    }
  }

  void changeMasterDeletingStatus(bool status) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"isMasterDeletingActive": status});

      setState(() {
        isLoading = false;
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
    bool isDarkMode(BuildContext context) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final dark = isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoading)
            SwitchListTile.adaptive(
              value: masterDeletingState,
              title: const Text("Enable Master Deleting"),
              subtitle:
                  const Text("Allow the admin account to delete all reports"),
              onChanged: (value) {
                changeMasterDeletingStatus(value);
                setState(() {
                  checkMasterDeletingState();
                });
              },
            ),
          const SizedBox(height: 2.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: dark ? Colors.white : Colors.black, 
                    side: BorderSide(
                      width: 2,
                      color: dark ? Colors.white : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UsersListScreen()));
                },
                child: const Text(
                  "Manage Users",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
