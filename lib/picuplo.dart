import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
//Import firestore database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UploadFile());
}
class UploadFile extends StatelessWidget {
  const UploadFile({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyUploadFile(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyUploadFile extends StatefulWidget {
  const MyUploadFile({super.key, required this.title});

  final String title;

  @override
  State<MyUploadFile> createState() => _MyUploadFileState();
}

class _MyUploadFileState extends State<MyUploadFile> {
  _MyUploadFileState(){
    _upload();
  }


  // List<String> id_ = <String>[];
  // List<String> photo_= <String>[];
  // List<String> names_= <String>[];
  
  String photo="";
  String title="";

  Future<void> _upload() async {
    SharedPreferences sh=await SharedPreferences.getInstance();
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection(
        'uplodfile').doc(sh.getString("fid")).get();
    if (docSnapshot.exists) {
      setState(() {
        photo = docSnapshot['phot'];
        title = docSnapshot['name'];
      });

      // List<String> id = <String>[];
      // List<String> photo= <String>[];
      // List<String> names= <String>[];
      //
      // CollectionReference uplodfile=FirebaseFirestore.instance.collection("uplodfile");
      // QuerySnapshot querySnapshot=await uplodfile.get();
      // final _doc=querySnapshot.docs;
      //
      //
      // print(_doc);
      // print(_doc.length);
      //
      //
      // for(int i=0;i<_doc.length;i++){
      //   final d=_doc[i];
      //   DocumentReference firedbDocRef = d['fid'];
      //   DocumentSnapshot firedbDoc = await firedbDocRef.get();
      //   String name = firedbDoc['name'].toString();
      //
      //   id.add(d.id);
      //   photo.add(d['file'].toString());
      //   names.add(name); // Add the name to the list
      // }
      // setState(() {
      //   id_=id;
      //   photo_=photo;
      //   names_=names;
      // });
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body:Column(
        children: [
          if (_selectedImage != null) ...{
            InkWell(
              child: CircleAvatar(
                radius: 70.0, // Adjust the radius as needed
                backgroundImage: FileImage(_selectedImage!),
              ),

              onTap: _checkPermissionAndChooseImage,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          } else ...{
            InkWell(
              onTap: _checkPermissionAndChooseImage,
              child: Column(

                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://cdn.pixabay.com/photo/2017/11/10/05/24/select-2935439_1280.png'),
                      radius: 70,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 90),
                        child: Text('Select Image'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          },
          // Add section at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                ElevatedButton(
                  onPressed: () async {
                    final pref =await SharedPreferences.getInstance();

                    DocumentReference firedbDocRef = FirebaseFirestore.instance.collection('firedb').doc( pref.getString("fid"));
                    CollectionReference uplodfile = FirebaseFirestore.instance.collection('uplodfile');
                    uplodfile.add({"file": pref.getString("photo").toString(),"fid":firedbDocRef});

                    _upload();

                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: id_.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(names_[index]),
                  subtitle: Image(image: NetworkImage(
                    photo_[index]
                  )),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pref =await SharedPreferences.getInstance();
                          CollectionReference uplodfile = FirebaseFirestore.instance.collection('uplodfile');

                          uplodfile.doc(id_[index]).set({'file': pref.getString("photo").toString()});
                          _upload();
                        },
                        child: Text("Edit"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          CollectionReference firedb = FirebaseFirestore.instance.collection('uplodfile');

                          firedb.doc(id_[index]).delete();
                          _upload();
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<void> uploadFile(File file) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference = storage.ref().child('image/${DateTime.now()}.jpg');

      UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() async {
        print('File uploaded successfully');
        String downloadURL = await storageReference.getDownloadURL();
        final pref =await SharedPreferences.getInstance();
        pref.setString("photo", downloadURL);

        print('Download URL: $downloadURL');
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }


  File? _selectedImage;
  String? _encodedImage;
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        // photo = _encodedImage.toString();

        uploadFile(File(pickedImage.path));
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

}
