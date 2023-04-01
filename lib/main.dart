import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ImageEditorExample(),
    ),
  );
}

class ImageEditorExample extends StatefulWidget {
  const ImageEditorExample({
    Key? key,
  }) : super(key: key);

  @override
  _ImageEditorExampleState createState() => _ImageEditorExampleState();
}

class _ImageEditorExampleState extends State<ImageEditorExample> {
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    loadAsset("amarjeet.jpg");
  }

  void loadAsset(String name) async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
    var data = await rootBundle.load('assets/$name');
    print(data);
    setState(() {
      setState(() => imageData = data.buffer.asUint8List());
      //print(imageData);
    });
  }

  final picker = ImagePicker();
  File? images;
  getedit() async {
    var changeProfile = await picker.pickImage(source: ImageSource.gallery);

    images = File(changeProfile!.path);
    imageData = images!.readAsBytesSync().buffer.asUint8List();
    setState(() {});
    //  print(imageData);
    // imageData = images!.path.codeUnits as Uint8List;
    await Saveimageback();
  }

  Saveimageback() async {
    var editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: imageData,
        ),
      ),
    );

    // replace with edited image
    if (editedImage != null) {
      setState(() {
        imageData = editedImage;
      });
      String dir = (await getApplicationDocumentsDirectory()).path;
      Random random = new Random();
      int randomNumber = random.nextInt(1000000);
      String fullPath = '$dir/$randomNumber.png';
      var snackBar = SnackBar(
        content: Text('Your file path $fullPath'),
      );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("local file full path ${fullPath}");
      File file = File(fullPath);
      await file.writeAsBytes(imageData!);
      print(file.path);

      final result = await ImageGallerySaver.saveImage(imageData!);
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amarjeet Task"),
        centerTitle: true,
      ),
      body: ListView(
        //  mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageData != null) Image.memory(imageData!),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text("Select image"),
            onPressed: () async {
              getedit();
            },
          ),
          // ElevatedButton(
          //   child: const Text("Multiple image editor"),
          //   onPressed: () async {
          //     var editedImage = await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ImageEditor(
          //           images: [
          //             imageData,
          //             imageData,
          //           ],
          //           allowMultiple: true,
          //           allowCamera: true,
          //           allowGallery: true,
          //         ),
          //       ),
          //     );
          //
          //     // replace with edited image
          //     if (editedImage != null) {
          //       imageData = editedImage;
          //       setState(() {});
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
