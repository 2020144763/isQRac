import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
  
// Create a Form widget.  
class AddClass extends StatefulWidget {  
  @override  
  AddClassState createState() {  
    return AddClassState();  
  }  
}  
// Create a corresponding State class. This class holds data related to the form.  
class AddClassState extends State<AddClass> {  
  // Create a global key that uniquely identifies the Form widget  
  // and allows validation of the form.  
  final _formKey = GlobalKey<FormState>(); 
  String emailTeacher = "";
  final _classNumber = TextEditingController();
  final _subject = TextEditingController();
  final _teacher = TextEditingController();
  final _tp = TextEditingController();
  var _dateController = TextEditingController();
  DateTime dateTime = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  bool saved=false;

  @override
  void initState() {
    super.initState();
    emailTeacher = AuthService().getEmail();
  }

  Future pickDateTime() async{
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      this.dateTime = dateTime;
      timeStamp = dateTime.millisecondsSinceEpoch;
      _dateController.text = dateTime.toString();
    });
  }

  
  void clear() {
    // Clean up the controller when save.
    setState(() {
      _classNumber.clear();
    _dateController.clear();
    _subject.clear();
    _teacher.clear();
    _tp.clear();
    });
    
  }

  Future<DateTime?> pickDate() => showDatePicker(
    context: context,
        initialDate: dateTime,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2023),
        lastDate: DateTime(2101));
  
  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
  );
    
  // Create a CollectionReference called Class that references the firestore collection
  CollectionReference bd = FirebaseFirestore.instance.collection('BD');
  
  @override  
  Widget build(BuildContext context) {  
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final hours = dateTime.hour.toString().padLeft(2,'0');
    final minutes = dateTime.minute.toString().padLeft(2,'0');
    
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: width *0.2,vertical: height*0.01),
          child:
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
        Form(
      key: _formKey,  
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,    
        children: <Widget>[ 
          TextFormField(
            controller: _classNumber,
            keyboardType: TextInputType.name,  
            decoration: const InputDecoration(  
              icon: const Icon(Icons.text_fields),  
              hintText: 'Introduzir número da aula',  
              labelText: 'Número da aula', 
              ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir número';
                }
                return null;
              },  
          ),  
          TextFormField(
            controller: _subject,
            keyboardType: TextInputType.text,  
            decoration: const InputDecoration(  
            icon: const Icon(Icons.subject),  
            hintText: 'Introduzir nome da disciplina',  
            labelText: 'Nome da disciplina',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir nome';
                }
                return null;
              },   
          ),  
          /*TextFormField(
            controller: _teacher,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(  
            icon: const Icon(Icons.person),  
            hintText: 'Professor',  
            labelText: 'Nome do professor',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir nome';
                }
                return null;
              },
            
           ),*/

           TextFormField(
            onTap: () {
              pickDateTime ();
            },
            controller: _dateController,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(  
            icon: const Icon(Icons.calendar_month),  
            hintText: 'Data',  
            labelText: 'Data', 
            ),
            validator: (value) {
              value= (dateTime.year.toString()+ dateTime.month.toString()+dateTime.day.toString()+ hours.toString()+minutes.toString());
                if (value.isEmpty) {
                  return 'Introduzir data';
                }
                return null;
              },
            
           ),
           
           TextFormField(
            controller: _tp,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(  
            icon: const Icon(Icons.numbers),  
            hintText: 'Número da TP',  
            labelText: 'TP',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir tp';
                }
                return null;
              },
            
           ),
            Padding(
              padding:EdgeInsets.all(50),  
              child: ElevatedButton(  
                child: const Text('Gravar'),  
                onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.

                if (_formKey.currentState!.validate()) {
                  await addClass(_classNumber.text,_subject.text,_teacher.text,emailTeacher, timeStamp, _tp.text, dateTime.year.toString());
                  saved?
                  (ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gravado')),
                  )) 
                  :
                  (ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro')),
                  ));
                }
                clear();
              },  
              ))
                
        ],  
      ),  
    )]));  
  }  

  Future<void> addClass(classNumber, subject, teacher, teacherEmail, time, tp, year) {
    // Vamos adicionar uma aula de uma disciplina

    Timestamp time1 = Timestamp.fromMillisecondsSinceEpoch(time);
    String id = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')}"+subject+tp;
    
    return bd
        .add({
          'id': id,
          'classNumber': classNumber, 
          'subject': subject, 
          'teacher': teacher,
          'teacherEmail': teacherEmail,
          'time': time1,
          'tp': tp,
          'year': year,
        })
        .then((value) => setState(() {
          saved=true;
        }));
    
  }
}