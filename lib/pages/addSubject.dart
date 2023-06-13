import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  
// Create a Form widget.  
class AddSubject extends StatefulWidget {  
  @override  
  AddSubjectState createState() {  
    return AddSubjectState();  
  }  
}  
// Create a corresponding State class. This class holds data related to the form.  
class AddSubjectState extends State<AddSubject> {  
  // Create a global key that uniquely identifies the Form widget  
  // and allows validation of the form.  
  final _formKey = GlobalKey<FormState>(); 
  
  final name = TextEditingController();
  final teacher = TextEditingController();
  final totalClass = TextEditingController();
  final tp = TextEditingController();

  
  // Create a CollectionReference called Class that references the firestore collection
  CollectionReference bd = FirebaseFirestore.instance.collection('Subjects');
  
  @override  
  Widget build(BuildContext context) {  
    // Build a Form widget using the _formKey created above.
    //
    //
    AppBar(
        title: Text("Adicionar Disciplinas"),
        backgroundColor: Color.fromRGBO(139, 139, 139, 1),
        //actions: [],
      );  
    return Form(
       
      key: _formKey,  
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,  
        children: <Widget>[  
          TextFormField(
            controller: name,
            keyboardType: TextInputType.name,  
            decoration: const InputDecoration(  
              icon: const Icon(Icons.school),  
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
          TextFormField(
            controller: teacher,
            keyboardType: TextInputType.text,  
            decoration: const InputDecoration(  
            icon: const Icon(Icons.school_outlined),  
            hintText: 'Introduzir nome do professor',  
            labelText: 'Nome do professor',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir nome';
                }
                return null;
              },   
          ),  
          TextFormField(
            controller: teacher,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(  
            icon: const Icon(Icons.class_),  
            hintText: 'Número total de aulas',  
            labelText: 'Número total de aulas',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir numero';
                }
                return null;
              },
            
           ),
           TextFormField(
            controller: tp,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(  
            icon: const Icon(Icons.numbers),  
            hintText: 'Número da TP',  
            labelText: 'Número da TP',  
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduzir número';
                }
                return null;
              },
            
           ),
           TextFormField(
            controller: tp,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(  
            icon: const Icon(Icons.calendar_month),  
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
              padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
              child: ElevatedButton(  
                child: const Text('Gravar'),  
                onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  addClass(name.text,teacher.text,totalClass.text,tp.text);
                  //ScaffoldMessenger.of(context).showSnackBar(
                    //const SnackBar(content: Text('Disciplina processar')),
                    AlertDialog(
                      title: Text('Aula inserida'),           
                      content: Text(name.text),   
                    );
                }
              },  
              ))
                
        ],  
      ),  
    );  
  }  

  Future<void> addClass(name, teacher, totalClass, tp) {
    // Vamos adicionar uma aula de uma disciplina
    return bd
        .add({
          'name': name,  
          'teacher': teacher,
          'totalClass': totalClass,
          'tp': tp,
        });
        
  }
}