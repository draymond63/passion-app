import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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

  // ! SHOULD THIS BE CALLED IN THE GET/WRITE FUNCTIONS?
  FirebaseUser getUser(context) {
    return Provider.of<FirebaseUser>(context);
  }

  void login() async {
    await auth.signInAnonymously();
  }

  Stream<User> getUserData(FirebaseUser user) {
    print('User ID: ${user.uid}');
    final query = _getDoc(user.uid).snapshots();
    return query.map((doc) => User.fromMap(doc.data));
    // return users
    //     .snapshots()
    //     .map((doc) => doc.documents.map((d) => {d.documentID: d.data}));
  }

  void writeItem(FirebaseUser user, String newItem) {
    final doc = _getDoc(user.uid);
    try {
      // CHANGE THIS TO RIGHT ON ALL APP CLOSE?
      doc.updateData({
        'items': FieldValue.arrayUnion([newItem])
      });
      // CREATE USER DATA
    } catch (e) {
      initUser(doc, newItem);
    }
  }

  DocumentReference _getDoc(String id) {
    return db.collection('users').document(id);
  }

  void initUser(doc, String item) {
    doc.setData({
      'items': [item]
    });
  }

  // addUser(FirebaseUser user) {
  //   db.collection('user').add(user);
  // }
}
