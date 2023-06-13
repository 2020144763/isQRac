import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../Models/Users.dart';

 
class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  
  bool saved=false;
  String _selectedSubject='';
  String _selectedDate='';
  String? _selectedTp='';
  List<String> dates = [];
  List<String> subjects = [];
  List<String> tps = [];
  final user = FirebaseAuth.instance.currentUser;
  String emailTeacher="";
  String studentEmail="";
  String studentName="";
  String doc="";
  final _formKey = GlobalKey<FormState>(); 
  final studentNumber = TextEditingController();


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

  void clear() {
    // Clean up the controller when save.
    setState(() {
      studentNumber.clear();
    });
    
  }

Future<List<String>> _getSubjects() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('BD')
      .where("teacherEmail", isEqualTo: emailTeacher)
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
  dates.sort((a, b){ //sorting in ascending order
    return DateTime.parse(a).compareTo(DateTime.parse(b));
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

   return Scaffold(
      body: 
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width *0.2,vertical: height*0.05),
          child:
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
///////////////////////////////////////////////////////////////////////////////DROPDOWN DISCIPLINA         
        FutureBuilder(
          future: _getSubjects(), 
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              subjects = snapshot.data;
             
              return DropdownButtonFormField<String>(
              decoration:const InputDecoration(
                border:  OutlineInputBorder(),
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
            } else {
              return CircularProgressIndicator();
            }
          },
        ),

        const SizedBox(height: 20),
        
              FutureBuilder(
          future: _getTpNumber(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              tps = snapshot.data;
              if (tps.isNotEmpty) {
              return DropdownButtonFormField<String>(
                decoration:const InputDecoration(
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
                hint:const Text('Selecionar nº tp'),
              );
            } else {
              return CircularProgressIndicator();
            }}else{
              return Container();
            }
          },
        ),

        const SizedBox(height: 20),

        _isLoading ? const CircularProgressIndicator():
        FutureBuilder(
          future: _getDateTime(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              dates = snapshot.data;

              if (dates.isNotEmpty) {
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
                    if (_selectedDate!=null || _selectedSubject!=null || _selectedTp!=null) {
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
                hint: Text('Selecionar data da aula'),
              );
              } else {
              return Container();
            }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        Form(
          key: _formKey,  
          child: Column(  
            crossAxisAlignment: CrossAxisAlignment.start,  
            children: <Widget>[ 
              SizedBox(height: 30),

              TextFormField(
                controller: studentNumber,
                keyboardType: TextInputType.number,  
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.text_fields),  
                  hintText: 'Introduzir número do aluno',  
                  labelText: 'Número do aluno', 
                  ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduzir número';
                    }
                    return null;
                  },  
              ),
              /*TextFormField(
                controller: studentName,
                keyboardType: TextInputType.name,  
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.numbers),  
                  hintText: 'Introduzir nome',  
                  labelText: 'Nome do aluno', 
                  ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduzir nome';
                    }
                    return null;
                  },  
              ),
              TextFormField(
                controller: studentEmail,
                keyboardType: TextInputType.emailAddress,  
                decoration: const InputDecoration(  
                  icon: const Icon(Icons.email),  
                  hintText: 'Introduzir email aluno',  
                  labelText: 'Email do aluno', 
                  ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduzir email';
                    }
                    return null;
                  },  
              ),*/ 
              

       const SizedBox(height: 20),
    
        ElevatedButton(
          onPressed: () async {
            if(doc==""){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                        title: Text("Erro!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"))
                             ],
                        content: const SizedBox(
                          width: 100,
                          height: 50,
                          child: Text("Erro na gravação"),
                          

                    ),
                    );
              },
            );  
            clear();
            }
            else{
                  await _getStudent(studentNumber.text);
                  print("Tenho: "+ studentName + studentEmail);
                  await _getStudentAttendance();
                  if (await _getStudentAttendance()!=0) {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Aviso!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"))
                             ],
                        content: const SizedBox(
                          width: 100,
                          height: 50,
                          child: Text("Aluno já registado nesta aula"),
                    ),
                    );});
                    clear();
                  }else{
                  await addStudent(studentName, studentEmail, studentNumber.text,doc);
                  saved?
                  (ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gravado')),
                  )) 
                  :
                  (ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro')),
                  ));
                  clear();
              }}
          },
          child: const Text('Inserir presença')
        ),
        
              
        ])
        )
        ])
        ])
        ));
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

        _getStudent(studentNumber) async {

          List<Users> studentList = [];
          var collection = FirebaseFirestore.instance.collection("Users").where("number", isEqualTo: studentNumber);
          List<Map<String, dynamic>> tempList =[];
    
          var data = await collection.get();
          data.docs.forEach((element) {
          studentList.add(Users.fromJson(element.data()));
          if (element.data() != "NULL") {
              studentEmail=studentList[0].email;
              studentName=studentList[0].nameFirst+" "+studentList[0].nameLast;
          }
          });
    }

        Future addStudent(name, email, studentNumber,doc) async{
          int time = DateTime.now().millisecondsSinceEpoch;
          Timestamp time1 = Timestamp.fromMillisecondsSinceEpoch(time);
           final databaseReference = FirebaseFirestore.instance;
           databaseReference.collection('BD').doc(doc).collection('Students').add({
            'email': email,  
            'name': name,
            'number': studentNumber,
            'status': "Approved",
            'time': time1,
          });
          saved=true; 
        }
        
          _getStudentAttendance() async{
            int d=0;
            var collect = FirebaseFirestore.instance.collection("BD").doc(doc).collection('Students').where("number", isEqualTo: studentNumber.text);
            List<Map<String, dynamic>> tempList =[];

            var data = await collect.get();
            data.docs.forEach((element) {
            tempList.add(element.data());
            });
            
            if (tempList.isNotEmpty) {
              d=1;
            }
            return d;
          }
}
