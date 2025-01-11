import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  //this is used to check if the widget is mounted or not.
  //mounted means the widget is visible on the screen
  //and exception occur because we were trying to access an ancestor widget (e.g.,via context) from a widget that has been deactivated
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}

Future<FilePickerResult?> pickImage() async{
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}