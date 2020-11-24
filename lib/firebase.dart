import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  List items;
  User({this.items}) {
    if (items == null) items = [];
  }

  factory User.fromMap(Map data) {
    return User(items: data['items'] ?? []);
  }
}

class DBService {
  final Firestore db = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  login() async {
    final result = await auth.signInAnonymously();
    print(result);
    // final result = await auth.signInWithEmailAndPassword(
    //     email: 'dan@raymond.ch', password: '123456');
  }

  // user = Provider.of<FirebaseUser>(context)
  Stream<User> getUserData(FirebaseUser user) {
    final query = db.collection('users').document(user.uid).snapshots();
    return query.map((doc) => User.fromMap(doc.data));
  }

  writeItems(FirebaseUser user, List<String> items) {
    db.collection('user').document(user.uid).updateData({'items': items});
  }

  // addUser(FirebaseUser user) {
  //   db.collection('user').add(user);
  // }
}
