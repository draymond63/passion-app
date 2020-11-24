// import 'package:flutter/material.dart';
// import '../firebase.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import '../globals.dart';
// // import '../firebase.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final DBService db = DBService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Welcome to PassionFruit!'),
//         ),
//         body: Center(
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.all(10.0),
//                   child: Text("Meet Up",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 30,
//                           fontFamily: 'Roboto')),
//                 ),
//                 Padding(
//                     padding: EdgeInsets.all(10.0),
//                     child: IconButton(
//                       icon: Icon(Icons.terrain),
//                       onPressed: () => DBService.createUser(),
//                     )),
//               ]),
//         ));
//   }
// }
