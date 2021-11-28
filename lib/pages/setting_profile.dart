import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udemy_20211031/model/user.dart';
import 'package:udemy_20211031/utils/firebase.dart';

class SettingsProfilePage extends StatefulWidget {
  //const SettingsProfilePage({Key? key}) : super(key: key);

  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  File? image;
  ImagePicker picker = ImagePicker();
  String imagePath = "";
  TextEditingController controller = TextEditingController();

  Future<void> getImageFromGallery() async {
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadImage();
      setState(() {});
    }
  }

  Future<String> uploadImage() async {
    final ref = FirebaseStorage.instance.ref("test_pic.png");
    final storedImage = await ref.putFile(image!);
    imagePath = await loadImage(storedImage);

    return imagePath;
  }

  Future<String> loadImage(TaskSnapshot storedImage) async {
    String downloadUrl = await storedImage.ref.getDownloadURL();
    return downloadUrl;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("プロフィール編集"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 100, child: Text("名前")),
                Expanded(child: TextField(
                  controller: controller,
                ))
              ],
            ),
            SizedBox(height: 50,),
            Row(
              children: [
                Container(width: 100, child: Text("サムネイル")),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150, height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            getImageFromGallery();
                      }, child: Text("画像を選択")),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            image == null ? Container() :
            Container(
              width: 200,
              height: 200,
              child: Image.file(image!, fit: BoxFit.cover),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
                onPressed: () {
                  User newProfile = User(
                      name: controller.text,
                      imagePath: imagePath
                  );
                  Firestore.updateProfile(newProfile);
                },
                child: Text("編集")
            )
          ],
        ),
      ),
    );
  }
}
