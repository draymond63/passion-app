import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
// import 'package:async/async.dart';

class User {
  List<String> items;
  User({this.items}) {
    if (items == null) items = [];
  }

  factory User.fromMap(Map data) {
    // ? Ready data['items'] directly freezes the function ?
    final vals =
        List<String>.generate(data['items'].length, (i) => data['items'][i]);
    final temp = User(items: vals ?? []);
    return temp;
  }

  @override
  String toString() {
    return '{items: $items}';
  }
}

class DBService {
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;

  FirebaseUser getUser(BuildContext context) {
    return Provider.of<FirebaseUser>(context);
  }

  void login() async {
    await auth.signInAnonymously();
  }

  Stream<User> getUserData(BuildContext context) {
    // print('User ID: ${user.uid}');
    final user = getUser(context);
    final query = _getDoc(user.uid).snapshots();
    return query.map((doc) => User.fromMap(doc.data));
  }

  void writeItem(BuildContext context, String newItem) {
    final user = getUser(context);
    final doc = _getDoc(user.uid);
    try {
      // CHANGE THIS TO WRITE ON ALL APP CLOSE?
      doc.updateData({
        'items': FieldValue.arrayUnion([newItem])
      });
      // CREATE USER DATA (if it failed to write)
    } catch (e) {
      initUser(doc, newItem);
    }
  }

  DocumentReference _getDoc(String id) {
    return db.collection('users').document(id);
  }

  void initUser(DocumentReference doc, String item) {
    doc.setData({
      'items': [item]
    });
  }

  // addUser(FirebaseUser user) {
  //   db.collection('user').add(user);
  // }
}
