import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_teste/pages/approveAttendance2.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/services/auth_service.dart';
 
class ApproveAtt extends StatefulWidget {
  const ApproveAtt({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApproveAttState createState() => _ApproveAttState();
}

class _ApproveAttState extends State<ApproveAtt> {
  
  String _selectedSubject='';
  String _selectedDate='';
  String? _selectedTp='';
  bool classSelected = false;
  bool isLoaded = false;
  List <String> selectedStudentList = [];
  String doc="";
  String emailTeacher = "";
  List<String> dates = [];
  List<String> subjects = [];
  List<String> tps = [];
  bool _isLoading = true;

@override
  void initState() {
    super.initState();
  
  emailTeacher = AuthService().getEmail();
  //1º Escolher disciplina da BD com base no professor
  
    _getSubjects().then((subj) {
      _selectedSubject = subj.first;
        });
        _getTpNumber().then((subj) {
        _selectedTp = subj.first;
        }); 
  }

   
Future<List<String>> _getSubjects() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('BD')
      .where("teacherEmail", isEqualTo: emailTeacher)
      //.orderBy('subject', descending: false)
      .get();
  subjects = [];
  snapshot.docs.forEach((doc) {
    if (!subjects.contains(doc['subject'])) {
      subjects.add(doc['subject']);
    }
  });
  return subjects;
}
Future<List<String>> _getTpNumber() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('BD')
      .where("teacherEmail", isEqualTo: emailTeacher)
      //.orderBy('tp', descending: false)
      .get();
  tps = [];
  snapshot.docs.forEach((doc) {
    if (!tps.contains(doc['tp'])) {
      tps.add(doc['tp']);
    }
  });
  
  return tps;
}


Future<List<String>> _getDateTime() async {
  dates.clear();
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('BD')
      .where("teacherEmail", isEqualTo: emailTeacher)
      //.orderBy('time', descending: false)
      .get();
  
  snapshot.docs.forEach((doc) {
    if (!dates.contains(doc['time'])) {
      if (doc['tp']==_selectedTp) {
        final Timestamp timestamp = doc['time'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        String date = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')}";
        dates.add(date.toString());
      }
    }
  });
  
  return dates;
}

  void _onSelectedState(String ?value) async {
    setState(() {
      _selectedTp = value;
      _isLoading = false;
    });

    await _getDateTime();
    _selectedDate=dates.first;

    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    

   return Scaffold(
      body: 
        Padding(
          padding: EdgeInsets.all(100),
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
              ///////////////////////////////////////////////////////////////////////////////DROPDOWN DISCIPLINA         
                FutureBuilder(
                  future: _getSubjects(), 
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<String> subjects = snapshot.data;
                    if (subjects.isEmpty) {
                      return CircularProgressIndicator();
                      }
                      else{
                      return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 247, 235, 200),
                        labelText: 'Disciplina',
                        ),
                      value: _selectedSubject?? "Disciplina",
                      items: subjects
                            .map((String subject) => DropdownMenuItem<String>(
                                  value: subject,
                                  child: Text(subject),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() async{
                            _selectedSubject = value!;
                            doc="";
                            if (_selectedDate!=null || _selectedSubject!=null || _selectedTp!=null) {
                              doc = await _getDoc(_selectedTp, _selectedSubject, _selectedDate);
                          }
                          });
                        },
                        hint: Text('Selecionar disciplina'),
                      );
                    }
                  } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),

                SizedBox(height: 20),
        
                FutureBuilder(
                  future: _getTpNumber(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<String> tps = snapshot.data;
                      if (tps.isEmpty) {
                      return CircularProgressIndicator();
                      }
                      else{
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color.fromARGB(255, 247, 235, 200),
                          labelText: 'Nº da TP',
                        ),
                        value: _selectedTp?? "TP",
                        onChanged: (value) => _onSelectedState(value),
                        items: tps
                            .map((String tpname) => DropdownMenuItem<String>(
                                  value: tpname,
                                  child: Text(tpname),
                                ))
                            .toList(),
                        hint: Text('Selecionar nº tp'),
                      );
                    } 
                    }else{
                      return Container();
                    }
                  },
                ),

                SizedBox(height: 20),

                _isLoading ? const CircularProgressIndicator():
                FutureBuilder(
                  future: _getDateTime(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<String> dates = snapshot.data;
                      if (dates.isEmpty) {
                      return const CircularProgressIndicator();
                      }
                      else{
                      return DropdownButtonFormField<String>(
                      decoration:const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 247, 235, 200),
                        labelText: 'Data da aula',
                      ),
                        value: _selectedDate?? "Data",
                        onChanged: (String? value) {
                          setState(() async{
                            _selectedDate = value!;
                            doc="";
                            if (_selectedDate.isNotEmpty || _selectedSubject.isNotEmpty ) {
                              doc = await _getDoc(_selectedTp, _selectedSubject, _selectedDate);
                          }
                          });
                        },
                        items: dates
                            .map((String name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ))
                            .toList(),
                        hint: const Text('Selecionar data da aula'),
                      );
                      } 
                    }
                   else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),

                const SizedBox(height: 20),
    
                ElevatedButton(
                  onPressed: () async {
                    if(doc==""){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: SizedBox(
                              width: 100,
                              height: 50,
                              child: Text("Escolha sem dados"),
                            ),
                        );
                      },
                    );  
                    }else{
                      secondScreen(doc);
                      }
                  },
                  child: const Text('Listagem')
                ),         
        ])
        )
        );
        }


        Future<String> _getDoc(_selectedTp, _selectedSubject, _selectedDate) async {

            String concaString = _selectedDate+_selectedSubject+_selectedTp;
            
            var documents = FirebaseFirestore.instance.collection("BD").where("id", isEqualTo: concaString).get().then((value) {
              value.docs.forEach((element) {   
              doc=element.id;
              doc.toString();
              });
          });
          return doc;
        }

        secondScreen(String doc){
          
          Navigator.push(context,MaterialPageRoute(
            builder: (context) => ApproveAtt2(selectedDoc: doc),
        ));
        
        }
  }
