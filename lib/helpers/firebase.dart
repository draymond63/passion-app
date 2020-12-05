import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDoc {
  List<String> items;
  Map<String, dynamic> feed;
  UserDoc({this.items, this.feed}) {
    if (items == null) items = [];
    if (feed == null) feed = {};
  }

  factory UserDoc.fromMap(Map data) {
    final _data = Map<String, dynamic>.from(data);
    final _items = List<String>.from(_data['items']);
    final _feed = Map<String, dynamic>.from(_data['feed']);
    return UserDoc(
      items: _items ?? [],
      feed: _feed ?? {},
    );
  }

  Map toMap() {
    return {'items': items, 'feed': feed};
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class DBService {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final functions = FirebaseFunctions.instance;

  // * READING
  User getUser(BuildContext context, {bool listen = true}) {
    return Provider.of<User>(context, listen: listen);
  }

  void login() async {
    await auth.signInAnonymously();
  }

  Stream<UserDoc> getUserData(BuildContext context) {
    final user = getUser(context, listen: false);
    // print('User ID: ${user.uid}');
    final query = _getDoc(user.uid).snapshots();
    return query.map((doc) => UserDoc.fromMap(doc.data()));
  }

  Future getSuggestions(BuildContext context) async {
    final user = getUser(context, listen: false);
    final request = functions.httpsCallable('suggest?uid=${user.uid}');
    print(request.toString());
    return (await request());
  }

  // * WRITING
  void writeItem(BuildContext context, String newItem) async {
    _updateData(context, {
      'items': FieldValue.arrayUnion([newItem]),
    });
  }

  void updateTime(BuildContext context, String item, int deciseconds) {
    _updateData(context, {
      'feed.$item': FieldValue.increment(deciseconds),
    });
  }

  void _updateData(BuildContext context, Map info) async {
    final user = getUser(context, listen: false);
    final doc = _getDoc(user.uid);
    // CHANGE THIS TO WRITE ALL ON APP CLOSE?
    if ((await doc.get()).exists)
      doc.update(Map.from(info));
    else
      _initUser(user, Map.from(info));
  }

  void _initUser(User user, Map initData) {
    db.collection('users').doc(user.uid).set(initData);
  }

  // * GENERAL
  DocumentReference _getDoc(String id) {
    return db.collection('users').doc(id);
  }
}
