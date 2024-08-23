import 'package:firebas/picuplo.dart';
import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
//Import firestore database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    _incrementCounter();
  }

  List<String> id_ = <String>[];
  List<String> namel_ = <String>[];
  List<String> place_ = <String>[];

  Future<void> _incrementCounter() async {
    List<String> id = <String>[];
    List<String> name = <String>[];
    List<String> place = <String>[];

    CollectionReference firedb =
        FirebaseFirestore.instance.collection("firedb");
    QuerySnapshot querySnapshot = await firedb.get();
    final _doc = querySnapshot.docs;

    print(_doc);
    print(_doc.length);

    for (int i = 0; i < _doc.length; i++) {
      final d = _doc[i];
      id.add(d.id);
      name.add(d['name']);
      place.add(d['place']);
    }
    setState(() {
      id_ = id;
      namel_ = name;
      place_ = place;
    });
  }

  TextEditingController name = new TextEditingController();
  TextEditingController place = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Add section at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(),
                TextField(
                  controller: name,
                ),
                TextField(
                  controller: place,
                ),
                ElevatedButton(
                  onPressed: () {
                    String name_ = name.text.toString();
                    String place_ = place.text.toString();

                    CollectionReference firedb =
                        FirebaseFirestore.instance.collection('firedb');
                    firedb.add({"name": name_, "place": place_});

                    _incrementCounter();
                  },
                  child: Text("Add"),
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //    //  CollectionReference firedb = FirebaseFirestore.instance.collection('firedb');
                //    // QuerySnapshot Q= await firedb.where("name",isEqualTo: "ghh").get();
                //    // // QuerySnapshot Q= await firedb.where((document)).get();
                //    // for(QueryDocumentSnapshot d in Q.docs) {
                //    //   print(d.id);
                //    // //   print(d.data());
                //    // }
                //   Navigator.push(context, MaterialPageRoute(builder: (context)=>MyUploadFile(title: '',)));
                //
                //   },
                //   child: Text("search"),
                // ),
                ElevatedButton(
                  onPressed: () async {
                    //  CollectionReference firedb = FirebaseFirestore.instance.collection('firedb');
                    // // QuerySnapshot Q= await firedb.where("name",isEqualTo: "ggg").get();
                    // QuerySnapshot Q= await firedb.where((document)).get();
                    // for(QueryDocumentSnapshot d in Q.docs) {
                    //   print(d.id);
                    //   print(d.data());
                    // }

                    try {
                      // Get a reference to the Firestore collection you want to query
                      CollectionReference users =
                          FirebaseFirestore.instance.collection('firedb');

                      // Perform the query
                      QuerySnapshot querySnapshot = await users.get();

                      // Process the query results with a partial match
                      List<QueryDocumentSnapshot> matchingDocuments =
                          querySnapshot.docs.where((document) {
                        return true;
                      }).toList();

                      // Print or use matchingDocuments
                      for (QueryDocumentSnapshot document
                          in matchingDocuments) {
                        print('Document ID: ${document.id}');
                        // print('Name: ${document.data()['name']}');
                        // print('Age: ${document.data()['age']}');
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  child: Text("search"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: id_.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(namel_[index]),
                  subtitle: Text(place_[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          CollectionReference firedb =
                              FirebaseFirestore.instance.collection('firedb');

                          firedb.doc(id_[index]).set({
                            'name': name.text.toString(),
                            'place': place.text.toString()
                          });
                          _incrementCounter();
                        },
                        child: Text("Edit"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          CollectionReference firedb =
                              FirebaseFirestore.instance.collection('firedb');

                          firedb.doc(id_[index]).delete();
                          _incrementCounter();
                        },
                        child: Text("Delete"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences sh =
                              await SharedPreferences.getInstance();
                          sh.setString("fid", id_[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyUploadFile(
                                        title: '',
                                      )));
                        },
                        child: Text("file"),
                      )
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
}
