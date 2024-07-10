import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:image_picker/image_picker.dart';

class AddNewReport extends StatefulWidget {
  const AddNewReport({super.key});

  @override
  State<AddNewReport> createState() => _AddNewReportState();
}

class _AddNewReportState extends State<AddNewReport> {
  var formKey = GlobalKey<FormState>();

  bool isLoading = false;

  var userUid = FirebaseAuth.instance.currentUser!.uid;
  var title = "";
  var place = "";
  var reportDescription = "";
  var nameOfUser = "";
  File? selectedImage;

  @override
  void initState() {
    getNameOfCurrentUser();
    super.initState();
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

  void closeView() {
    Navigator.of(context).pop();
  }

  String get currentDate {
    String now = DateFormat.yMMMd().add_Hm().format(DateTime.now());
    return now;
  }

  void selectPhotoFromLibrary() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void takePhotoWithCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  // Upload image on firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    final storage = FirebaseStorage.instance;
    final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final imageRef = storage.ref().child('reports/images/$imageName');
    final uploadTask = imageRef.putFile(imageFile);

    final snapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void submitReport() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    final user = FirebaseAuth.instance.currentUser;

    try {
      setState(() {
        isLoading = true;
      });

      // Upload image and get download url
      String imageUrl = "";
      if (selectedImage != null) {
        imageUrl = await _uploadImage(selectedImage!);
      }

      final Map<String, dynamic> newReport = {
        "title": title,
        "author": nameOfUser,
        "place": place,
        "description": reportDescription,
        "dateOfSubmission": currentDate,
        "imageUrl": imageUrl,
        "userUID": user!.uid,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "reportsList": FieldValue.arrayUnion([newReport])
      });
      closeView();
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      AlertDialogs().fatalErrorDialogMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final bool dark = isDarkMode(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          right: 12,
          left: 12,
          // avoid keyboard overflow
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ADD NEW REPORT",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Form(
              key: formKey,
              child: Column(
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
                        nameOfUser,
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      )),
                    ],
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Report Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Title required";
                      }
                      return null;
                    },
                    onSaved: (newValue) => title = newValue!,
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Place",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          AlertDialogs().notImplementedAlertCompiled(context);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Place required";
                      }
                      return null;
                    },
                    onSaved: (newValue) => place = newValue!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Report description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Description required";
                      }
                      return null;
                    },
                    onSaved: (newValue) => reportDescription = newValue!,
                  ),
                  // Box photo
                  if (selectedImage != null) const SizedBox(height: 12),
                  Stack(
                    children: [
                      if (selectedImage != null)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 0.1,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          height: 250,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      if (selectedImage != null)
                        Positioned(
                          top: 3,
                          right: 3,
                          child: Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(40)),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                              child: const Center(
                                child: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedImage == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              //padding: const EdgeInsets.symmetric(horizontal: 40),
                              side: BorderSide(
                                  width: 2,
                                  color: dark ? Colors.white : Colors.black),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            selectPhotoFromLibrary();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library,
                                  color: dark ? Colors.white : Colors.black),
                              const SizedBox(width: 3),
                              Text(
                                "Add Photo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              //padding: const EdgeInsets.symmetric(horizontal: 40),
                              side: BorderSide(
                                  width: 2,
                                  color: dark ? Colors.white : Colors.black),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            takePhotoWithCamera();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera,
                                  color: dark ? Colors.white : Colors.black),
                              const SizedBox(width: 3),
                              Text(
                                "Take Photo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark ? Colors.white : Colors.black),
                              ),
                              Text(
                                " (beta)",
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: dark ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 237, 207, 73),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: submitReport,
                          child: isLoading
                              ? const SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                    backgroundColor: Colors.black,
                                    valueColor: AlwaysStoppedAnimation(Colors.black),
                                  ),
                                )
                              : const Text("Submit Report"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!isLoading)
                    TextButton(
                      onPressed: closeView,
                      child: Text(
                        "Close",
                        style: TextStyle(
                            color: dark ? Colors.white : Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
