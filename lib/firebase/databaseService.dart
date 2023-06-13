import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/Models/attendance.dart';

class DatabaseService with ChangeNotifier{

  
  DatabaseService();

  // collection reference
  final CollectionReference attCollection = FirebaseFirestore.instance.collection("TP").doc('1').collection('Lecture').doc('1').collection('Attendance');
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateAttData(String status) async {
    return await attCollection.doc().set({
      'status': status,
    });
  }

  // attendance list from snapshot
  List<Attendance> _attListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((document){
      //print(doc.data);
      return Attendance(
        email: document['email'] ?? '',
        timeAtt: document['timeAtt'] ?? '',
        status: document['status'] ?? ''
      );
    }).toList();
  }

  Future<List<Attendance>> retrieveAttendance() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("TP").doc('1').collection('Lecture').doc('1').collection('Attendance').get();
    return snapshot.docs
        .map((docSnapshot) => Attendance.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  // get attendance stream
  Stream<List<Attendance>> get attendance {
    return attCollection.snapshots()
      .map(_attListFromSnapshot);
  }
  }

