import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

initConfiguration() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyBuK3BPRx1J8T6feKqTzQEakGoajaq0-uA",
      authDomain: "isqrac.firebaseapp.com",
      //databaseURL: "https://isqrac-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "isqrac",
      storageBucket: "isqrac.appspot.com",
      messagingSenderId: "1091379896396",
      appId: "1:1091379896396:web:2d2350fa4b933c33ead4e9",
      //measurementId: "G-DRV82CHXZF"),
  ),);
}