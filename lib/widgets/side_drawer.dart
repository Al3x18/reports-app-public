import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({
    super.key,
    required this.nameOfUser,
    required this.loadedReports,
    required this.onItemTapped,
    required this.selectedIndex,
    required this.isAdmin,
  });

  final String nameOfUser;
  final int selectedIndex;
  final bool isAdmin;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedReports;

  final Function(int index) onItemTapped;

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  Color selectedColorForDrawer = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Material(
            elevation: 1,
            child: Container(
              decoration: const BoxDecoration(
                  //color: Color.fromARGB(255, 255, 247, 212),
                  ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            //color: Colors.black,
                            size: 32,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.nameOfUser,
                            style: const TextStyle(
                              //color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (widget.isAdmin)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 8.5),
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 12.8),
                            Text(
                              "Admin Mode Enabled",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.home),
                SizedBox(width: 5),
                Text("Home"),
              ],
            ),
            selected: widget.selectedIndex == 0,
            selectedColor: selectedColorForDrawer,
            onTap: () {
              widget.onItemTapped(0);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.report_outlined),
                SizedBox(width: 5),
                Text("My Reports"),
              ],
            ),
            selected: widget.selectedIndex == 1,
            selectedColor: selectedColorForDrawer,
            onTap: () {
              widget.onItemTapped(1);
              Navigator.of(context).pop();
            },
          ),
          if (widget.isAdmin)
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings),
                  SizedBox(width: 5),
                  Text("Admin Panel"),
                ],
              ),
              selectedColor: selectedColorForDrawer,
              selected: widget.selectedIndex == 2,
              onTap: () {
                widget.onItemTapped(2);
                Navigator.of(context).pop();
              },
            ),
          Visibility(
            visible: false,
            child: ListTile(
              title: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5),
                  Text("Settings"),
                ],
              ),
              selectedColor: selectedColorForDrawer,
              selected: widget.selectedIndex == 3,
              onTap: () {
                widget.onItemTapped(3);
              },
            
            ),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 5),
                Text("Info"),
              ],
            ),
            selectedColor: selectedColorForDrawer,
            selected: widget.selectedIndex == 4,
            onTap: () {
              widget.onItemTapped(4);
            },
          
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 5),
                Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            onTap: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog.adaptive(
                    title: const Text("Really want to logout?"),
                    content: const Text("Do you still remember your password?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cancel",
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Logout",
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
