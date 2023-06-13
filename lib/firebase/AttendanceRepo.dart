import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/firebase/db_firestore.dart';
import 'package:menu_teste/services/auth_service.dart';
import '../Models/attendance.dart';

class AttendanceRepo extends ChangeNotifier {

final List<Attendance> _lista = [];

late FirebaseFirestore db;
late AuthService auth;


AttendanceRepo(){

}

 final CollectionReference attCollection =
    FirebaseFirestore.instance.collection("TP").doc('1')
                                .collection('Lecture').doc('1')
                                .collection('Attendance');


 saveAll(List<Attendance> attendances) {
    attendances.forEach((attendance) async {
      if (!_lista.any((atual) => atual.email == attendance.email)) {
        _lista.add(attendance);
        await db.collection("TP").doc('1')
                .collection('Lecture').doc('1')
                .collection('Attendance')
            .doc(attendance.email)
            .set({
          'email': attendance.email,
          'status': attendance.status,
          'timeAtt': attendance.timeAtt,
        });
      }
    });
    notifyListeners();
  }

}
   
