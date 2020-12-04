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
    print(data);
    print(data['viewed']);
    // ? Ready data['items'] directly freezes the function ?
    final _items = List<String>.generate(
      data['items'].length,
      (i) => data['items'][i],
    );
    return User(items: _items ?? []);
  }

  Map toMap() {
    return {'items': items};
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class DBService {
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;

  FirebaseUser getUser(BuildContext context, {bool listen = true}) {
    return Provider.of<FirebaseUser>(context, listen: listen);
  }

  void login() async {
    await auth.signInAnonymously();
  }

  Stream<User> getUserData(BuildContext context) {
    final user = getUser(context, listen: false);
    // print('User ID: ${user.uid}');
    final query = _getDoc(user.uid).snapshots();
    return query.map((doc) => User.fromMap(doc.data));
  }

  void writeItem(BuildContext context, String newItem) async {
    final user = Provider.of<FirebaseUser>(context, listen: false);
    final doc = _getDoc(user.uid);

    if ((await doc.get()).exists) {
      // CHANGE THIS TO WRITE ON ALL APP CLOSE?
      doc.updateData({
        'items': FieldValue.arrayUnion([newItem])
      });
    } else
      initUser(user, newItem);
  }

  DocumentReference _getDoc(String id) {
    return db.collection('users').document(id);
  }

  void initUser(FirebaseUser user, String item) {
    db.collection('users').document(user.uid).setData(
          User(items: [item]).toMap(),
        );
  }

  // addUser(FirebaseUser user) {
  //   db.collection('user').add(user);
  // }
}
