import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputForm extends StatefulWidget {
  BuildContext _context;
  InputForm(this._context, {Key key}) : super(key: key);
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  String _name;
  String _usn;
  CollectionReference users = FirebaseFirestore.instance.collection('names');
  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'name': _name, // John Doe
          'usn': _usn, // Stokes and Sons
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
            onSaved: (str) => _name = str,
            decoration: InputDecoration(labelText: "Name"),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (!RegExp(r"[a-z A-Z]+").hasMatch(value)) {
                return 'Please enter a valid name';
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            onSaved: (str) => _usn = str,
            decoration: InputDecoration(labelText: "USN"),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (!RegExp(r"[0-9][A-Z][A-Z][0-9][0-9][A-Z][A-Z][0-9][0-9][0-9]")
                  .hasMatch(value)) {
                return 'Please enter a valid USN';
              }
              return null;
            },
          ),
          SizedBox(
            height: 30,
          ),
          RaisedButton(
            onPressed: () {
              // Validate returns true if the form is valid, otherwise false.
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();
              addUser();
              Navigator.of(widget._context).pop();
            },
            child: Text('Submit'),
          )
        ]));
  }
}
