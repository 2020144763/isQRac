import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/Models/class.dart';


class ClassService extends ChangeNotifier {

  final db = FirebaseFirestore.instance;
  List<Map<String,dynamic>> _classList = [];

  List<Map<String,dynamic>> getClass() {
    return _classList;
  }

   late List<Map<String, dynamic>> items ;
    _displayData() async {
      var collection = FirebaseFirestore.instance.collection("BD");
      List<Map<String, dynamic>> tempList =[];
      var data = await collection.get();
      data.docs.forEach((element) {
        _classList.add(element.data());
    });
    }
}