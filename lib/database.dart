import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<void> addStudent(String documentName) async {
  final userEmail = FirebaseAuth.instance.currentUser?.email;
  DocumentSnapshot? userDoc;

  if (userEmail != null) {
    userDoc = await _db
        .collection('Users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);
  }

  if (userDoc != null && userDoc.exists) {
    final nameFirst = userDoc['nameFirst'];
    final nameLast = userDoc['nameLast'];
    final name = '$nameFirst $nameLast';
    final number = userDoc['number'];

    await _db
        .collection('BD')
        .doc(documentName)
        .collection('Students')
        .add({
      'email': userEmail,
      'name': name,
      'number': number,
      'status': 'initial',
      'time': FieldValue.serverTimestamp(),
    });
  } else {
    print('User not found or email is null');
  }
}

  Future<bool> studentExists(String documentName, String email) async {
    bool exists = false;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('BD')
          .doc(documentName)
          .collection('Students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        exists = true;
      }
    } catch (error) {
      print("Erro a verificar estudante: $error");
    }

    return exists;
  }
}