


import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
//Import firestore database
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const edit());
}

class edit extends StatelessWidget {
  const edit({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Myedit(title: 'Flutter Demo Home Page'),
    );
  }
}

class Myedit extends StatefulWidget {
  const Myedit({super.key, required this.title});

  final String title;

  @override
  State<Myedit> createState() => _MyeditState();
}

class _MyeditState extends State<Myedit> {
  _MyeditState(){
  }


  TextEditingController name= new TextEditingController();
  TextEditingController place=new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body:Column(
        children: [
          // Add section at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: name,
                ),
                TextField(
                  controller: place,
                ),
                ElevatedButton(
                  onPressed: () {
                    CollectionReference firedb = FirebaseFirestore.instance.collection('firedb');
                    firedb.doc(id_[index]).set({'name': name.text.toString(), 'place': place.text.toString()});
                    _incrementCounter();
                  },
                  child: Text("Edit"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
