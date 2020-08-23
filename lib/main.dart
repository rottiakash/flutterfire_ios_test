import 'package:flutter/cupertino.dart';
import 'package:ios_hello/form.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(home: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      // ignore: missing_return
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        } else
          return Text("Gone");
      },
    );
  }
}

showAlertDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Student'),
        content: SingleChildScrollView(child: InputForm(context)),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

CollectionReference users = FirebaseFirestore.instance.collection('names');

Future<void> deleteUser(usn) async {
  QuerySnapshot doc = await users.where("usn", isEqualTo: usn).get();
  DocumentReference ref = doc.docs[0].reference;
  ref
      .delete()
      .then((value) => print("Deleted"))
      .catchError((error) => print("Failed to delete user: $error"));
}

showDeleteAlert(BuildContext context, String name, String usn) {
  showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Student?'),
        content: Text("Are you sure you want to delete $name"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              deleteUser(usn);
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAlertDialog(context);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("FlutterFire Demo"),
      ),
      body: Center(child: DisplayList()),
    );
  }
}

class DisplayList extends StatelessWidget {
  const DisplayList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('names');

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        if (snapshot.data.docs.length == 0)
          return Center(
            child: Text("No Data Present"),
          );
        return ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return Card(
              child: new ListTile(
                onTap: () {
                  showDeleteAlert(
                      context, document.data()['name'], document.data()['usn']);
                },
                title: new Text("Name: " + document.data()['name']),
                subtitle: new Text("USN: " + document.data()['usn']),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
