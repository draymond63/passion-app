import 'package:PassionFruit/helpers/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDoc {
  List<String> items;
  Map feed;
  UserDoc({this.items, this.feed}) {
    if (items == null) items = [];
    if (feed == null) feed = {};
  }

  factory UserDoc.fromMap(Map data) {
    final _data = Map<String, dynamic>.from(data);
    final _items = List<String>.from(_data['items']);
    final _feed = Map.from(_data['feed']);
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

  // * READING
  Future<User> _getUser(BuildContext context, {bool listen = true}) async {
    User user = Provider.of<User>(context, listen: listen);
    if (user == null) user = await _login(context);
    return user;
  }

  Future<User> _login(BuildContext context) async {
    if (_doUpload(context))
      return auth.signInAnonymously().then((creds) => creds.user);
    else
      return null;
  }

  DocumentReference _getDoc(String id) {
    return db.collection('users').doc(id);
  }

  // * WRITING
  void syncData(BuildContext context) async {
    final data = Provider.of<Storage>(context, listen: false);
    _updateData(context, {
      'feed': data.feed,
      'items': data.items,
      'settings': data.settings.toMap(),
    });
  }

  void deleteData(BuildContext context) async {
    if (!_doUpload(context)) return;
    final user = await _getUser(context, listen: false);
    final doc = _getDoc(user.uid);
    doc.delete();
  }

  void _updateData(BuildContext context, Map info) async {
    if (!_doUpload(context)) return;
    final user = await _getUser(context, listen: false);
    final doc = _getDoc(user.uid);
    // CHANGE THIS TO WRITE ALL ON APP CLOSE?
    if ((await doc.get()).exists)
      doc.update(Map.from(info));
    else
      _initUser(user, Map.from(info));
  }

  void _initUser(User user, Map<String, dynamic> initData) {
    db.collection('users').doc(user.uid).set(initData);
  }

  // * GENERAL
  bool _doUpload(BuildContext context) {
    return Provider.of<Storage>(context, listen: false)
        .settings
        .data['send_data'];
  }

  void sendFlag(BuildContext context, String site, Map info) async {
    // Make sure the user has a uid
    if (!_doUpload(context)) throw Exception('User must enable firebase');
    // User uid == warning key
    final id = (await _getUser(context, listen: false)).uid;
    db.collection('errors').doc(site).set({id: info}, SetOptions(merge: true));
  }
}
