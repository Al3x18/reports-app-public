import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reports/delegates/my_silver_app_bar_delegate.dart';
import 'package:reports/screens/general_loading.dart';
import 'package:reports/screens/manage_user.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  Widget build(BuildContext context) {
    //const Color bgColor = Color.fromARGB(255, 252, 245, 237);

    void gotToUserDetailsScreen(Map<String, dynamic> userDetails) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ManageUserScreen(userDetails: userDetails),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: bgColor,
        title: const Text("Registered Users"),
      ),
      //backgroundColor: bgColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GeneralLoadingScreen();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Data Found."),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong."),
            );
          }
          var usersSnapshot = snapshot.data!.docs;
          List usersList = [];

          for (var element in usersSnapshot) {
            usersList.add(element.data());
          }

          final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

          String getRegisteredUsers() {
            return usersList.length.toString();
          }

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: MySliverAppBarDelegate(
                    child: Center(
                      child: Text(
                          "[Number of currently Registered Users: ${getRegisteredUsers()}]",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ),
                  ),
                  floating: false,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        onTap: () {
                          gotToUserDetailsScreen(usersList[index]);
                        },
                        child: ListTile(
                          title: Text(usersList[index]["name"]),
                          subtitle: Text(usersList[index]["email"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentUserUid == usersList[index]["uid"])
                                const Text("It's you!"),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_ios, size: 19),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: usersSnapshot.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
