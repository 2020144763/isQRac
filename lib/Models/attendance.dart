import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {

    String email;
    String status;
    Timestamp timeAtt;
    final List<String>? attendanceList;
  Attendance( {
        required this.email,
        required this.status,
        required this.timeAtt,
        this.attendanceList
    });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'status': status,
      'timeAtt': timeAtt,
      'attendanceList': attendanceList
    };
  }

  Attendance.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : 
        email = doc.data()!["email"],
        status = doc.data()!["status"],
        timeAtt = doc.data()!["timeAtt"],
        attendanceList = doc.data()?["attendance"] == null
            ? null
            : doc.data()?["employeeTraits"].cast<String>();

  
  static List<Attendance> tabela = [];

  factory Attendance.fromJson(Map<String, dynamic> attendace) {
    return Attendance(
      email: attendace['name'],
      status: attendace['email'],
      timeAtt: attendace['age'],
    );
  }

  toJson() {
    return {
      "email": email,
      "status": status,
      "timeAtt": timeAtt,
    };
  }

 final CollectionReference attCollection =
    FirebaseFirestore.instance.collection("TP").doc('1')
                                .collection('Lecture').doc('1')
                                .collection('Attendance');

  /*Future<List<Attendance>> getAttendance() async {
  List<Attendance> attendace = [];
  
  QuerySnapshot querySnapshot = await attCollection.get();

  querySnapshot.docs.forEach((document) {
    attendace.add(Attendance.fromJson(document.data()));
  });*/ 
}

