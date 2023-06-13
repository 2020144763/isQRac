import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, List<Map<String, dynamic>>> attendedClassesMap = {};

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    fetchClassData();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> fetchClassData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    String userEmail = currentUser.email ?? '';

    QuerySnapshot classSnapshot =
        await FirebaseFirestore.instance.collection('BD').get();

    Map<String, List<Map<String, dynamic>>> classDataMap = {};

    for (var doc in classSnapshot.docs) {
      String id = doc.id;
      String date = id.substring(0, 10);
      String subjectModule = id.substring(10);
      String tp = doc['tp'];

      String subject = doc['subject'];
      int? moduleNumber = int.tryParse(tp);

      QuerySnapshot studentSnapshot = await doc.reference
          .collection('Students')
          .where('email', isEqualTo: userEmail)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> attendedClasses =
            classDataMap.containsKey(subject)
                ? classDataMap[subject]!
                : [];

        Timestamp timestamp = doc['time'];
        DateTime time = timestamp.toDate();

        attendedClasses.add({
          'subject': subject,
          'moduleNumber': moduleNumber,
          'time': time,
        });

        classDataMap[subject] = attendedClasses;
      }
    }

    setState(() {
      attendedClassesMap = classDataMap;
    });
  }

  Future<int> getTotalClassCount(String subject) async {
    int totalClasses = await FirebaseFirestore.instance
        .collection('BD')
        .where('subject', isEqualTo: subject)
        .get()
        .then((snapshot) => snapshot.size);

    return totalClasses;
  }

  Widget _buildClassList() {
    if (attendedClassesMap.isEmpty) {
      return Text('Nenhuma aula frequentada.');
    }

    return ListView.builder(
      itemCount: attendedClassesMap.length,
      itemBuilder: (context, index) {
        String subject = attendedClassesMap.keys.elementAt(index);
        List<Map<String, dynamic>> attendedClasses =
            attendedClassesMap[subject] ?? [];

        return ExpansionTile(
          title: Text('$subject'),
          subtitle: FutureBuilder<int>(
            future: getTotalClassCount(subject),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int totalClasses = snapshot.data ?? 0;
                int presentClasses = attendedClasses.length;
                int missedClasses = totalClasses - presentClasses;
                return Text('Total: $totalClasses');
              } else if (snapshot.hasError) {
                return Text('Erro ao obter contagem total de aulas.');
              } else {
                return Text('A carregar...');
              }
            },
          ),
          trailing: Icon(Icons.arrow_drop_down),
          children: [
            ListTile(
              title: Text('Aulas Frequentadas'),
              subtitle: Text('Total: ${attendedClasses.length}'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('$subject - Aulas Frequentadas'),
                      content: Column(
                        children: [
                          for (var classInfo in attendedClasses)
                            ListTile(
                              leading: Icon(Icons.check, color: Colors.green),
                              title: Text('Tp ${classInfo['moduleNumber']}'),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(classInfo['time']),
                              ),
                            ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Fechar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _buildClassList(),
      ),
    );
  }
}
