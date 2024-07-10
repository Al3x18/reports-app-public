import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reports/screens/full_screen_image.dart';
import 'package:reports/utils/alert_dialogs.dart';

class ReportDetailsImageContainer extends StatelessWidget {
  const ReportDetailsImageContainer({super.key, required this.imageUrl});

  final String imageUrl;

  void saveImageToTheLibrary(String imageUrl, BuildContext context) async {
    void saveNetworkImage(String imageUrl) async {
      var response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: DateTime.now().millisecondsSinceEpoch.toString());

      if (result["isSuccess"] != true) {
        final String alertContent =
            "Unexpected error the photo has not been saved.\n$result";
        if (!context.mounted) {
          return;
        }
        AlertDialogs().fatalErrorDialogMessage(context, alertContent);
      }

      if (result["isSuccess"] == true) {
        const String infoTitle = "SAVED!";
        const String infoContent = "The photo has been saved into the library";
        if (!context.mounted) {
          return;
        }
        AlertDialogs().infoDialog(context, infoTitle, infoContent);
      }
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("Save image"),
          content: const Text("Do you want to save this image in library?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("SAVE"),
              onPressed: () async {
                var status = await Permission.photos.request();
                if (status.isGranted) {
                  saveNetworkImage(imageUrl);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullScreenImage(imageUrl: imageUrl),
          ),
        );
      },
      child: Stack(
        children: [
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
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation(Colors.grey),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () {},
              child: IconButton(
                onPressed: () => saveImageToTheLibrary(imageUrl, context),
                icon: const Icon(
                  Icons.save_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
