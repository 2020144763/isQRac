import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/pages/approveAttendance2.dart';
import '../Models/class.dart';
import '../Models/student.dart';
import '../services/auth_service.dart';
import 'dart:async';

class ClassReport extends StatefulWidget {
  const ClassReport({Key? key}) : super(key: key);

  @override
  State<ClassReport> createState() => _Reports();
}
class Data {
  String label;
  Color color;

  Data(this.label, this.color);
}

class _Reports extends State<ClassReport> {

  List<Student> studentList= [];
  List<Class> classList= [];
  bool _searchBoolean = false;
  bool _sortAscending = true; // To keep track of sorting direction
  int? _sortColumnIndex=0; // Initially column 0 is sorted

  String emailTeacher = "";
  final searchController = TextEditingController();
  List<dynamic> filteredData = [];
  static const int rows = 10000;
  Duration? executionTime;
  List<int> _searchIndexList = [];

    @override
  void initState() {
    classList.clear();
    studentList.clear();
    emailTeacher = AuthService().getEmail();
    super.initState();
  }

  @override
  void dispose() {
    classList.clear();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

   Future<List<Class>> getClass() async {
    classList.clear();
    int n=0;
    await FirebaseFirestore.instance.collection('BD')
                                    .where("teacherEmail", isEqualTo: emailTeacher)
                                    .get().then(
    (snapshot) => snapshot.docs.forEach((document) async {
      classList.add(Class.fromJson(document.data()));

      await FirebaseFirestore.instance.collection("BD").doc(document.id).collection('Students').get().then(
        (snapshot) => snapshot.docs.forEach((element) {
          if (element.data().isEmpty) {
            //print(n.toString() + 'BD ' + classList[n].subject + "  - VAZIA");
          }
          else{
            studentList.add(Student.fromJson(element.data()));
            //print(n.toString() + 'BD ' + classList[n].subject);        
            if (studentList.length>0) {
              for (var i = 0; i < studentList.length; i++) {
                if (studentList[i].status=='Initial') {
                    classList[n].initialStudents++;
                  //print(i.toString() + 'Student ' + _studentList[i].status);
                }
                if (studentList[i].status=='Refused') {
                    classList[n].refusedStudents++;
                  //print(i.toString() + 'Student ' + _studentList[i].status);
                }else{
                    classList[n].approvedStudents++;
                  //print(i.toString() + 'Student ' + _studentList[i].status);
              }
              studentList.clear();
              }
              }
            }
        }));
      n=n+1;
      }
      
      ));
      classList=Class.sortClass(classList);
      await Future.delayed(const Duration(seconds: 1));
      return classList;    
  }

  void exportToExcel(){
    final stopWatch = Stopwatch()..start();
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    for (var row = 2; row < classList.length+2; row++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0,rowIndex: 1,)).value = "Nº Aula";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, 
        rowIndex: row)).value = classList[row-2].classNumber;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1,rowIndex: 1,)).value = "Disciplina";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, 
        rowIndex: row)).value = classList[row-2].subject;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = "TP";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, 
        rowIndex: row)).value = classList[row-2].tp.toString();

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = "Data";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, 
        rowIndex: row)).value =classList[row-2].time;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = "Por aprovar";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, 
        rowIndex: row)).value = classList[row-2].initialStudents;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value = "Recusados";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, 
        rowIndex: row)).value = classList[row-2].refusedStudents;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = "Aprovados";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, 
        rowIndex: row)).value = classList[row-2].approvedStudents;
    }
    excel.save(fileName: 'AsMinhasAulas.xlsx');
  }
  
   Widget _searchTextField() {
    return TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //Specify the action button on the keyboard
      decoration:const InputDecoration( //Style of TextField
        enabledBorder: UnderlineInputBorder( //Default TextField border
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //Borders when a TextField is in focus
          borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'Search', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle( //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
       onChanged: (String s) { //add
        setState(() {
          filteredData = [];
          for (int i = 0; i < classList.length; i++) {
            if (classList[i].subject.contains(s)) {
              filteredData.add(i);
              print(filteredData[i]);
            }
          }
        });
        });
    }

    Widget _searchListView() { //add
      return ListView.builder(
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          index=filteredData[index];
          return Card(
            child: ListTile(
              title:  Text(classList[index].subject),
              subtitle: Text(classList[index].time),
            )
          );
        }
      );
    }

    Color getColor(Set<MaterialState> states) {
    return Colors.grey;
    }

    Widget _defaultListView() { 
      final isSmallScreen = MediaQuery.of(context).size.width < 900;
      double textHeaderSize = 16;
      double textSize = 12;
      double columnSize = 20;
      if(isSmallScreen)
        {setState(() {
          textHeaderSize=12;
          textSize=9;
          columnSize=10;
        });}

    return
          SingleChildScrollView(
          child: 
            Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              SizedBox(height: 20),
              FutureBuilder<List<Class>>(
                future: getClass(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return 
                      DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        headingTextStyle: TextStyle(fontSize: textHeaderSize),
                        //border: TableBorder.all(width: 2),
                        headingRowColor: MaterialStateProperty.all(Colors.amber[200]),
                        columnSpacing: columnSize,
                        dataTextStyle: TextStyle(fontSize: textSize),
                        columns: [
                          DataColumn(
                            label: Text('NºAula'), 
                            onSort: (columnIndex, _) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                if (_sortAscending == true) {
                                  _sortAscending = false;
                                  
                                } else {
                                  _sortAscending = true;
                                }
                              });
                          }),
                          const DataColumn(label: Text('Disciplina')),
                          const DataColumn(
                              label: Text('TP'),),
                          const DataColumn(
                              label: Text('Data'),),
                          const DataColumn(
                              label: Text('Por aprovar'),
                              numeric: true),
                          const DataColumn(
                              label: Text('Recusados'),
                              numeric: true),
                          const DataColumn(
                              label: Text('Aprovados'),
                              numeric: true),
                        ],

                        rows: List.generate(
                          classList.length,
                          (index) {
                            var data = classList[index];
                            return DataRow(
                              color: index % 2 == 0
                              ? MaterialStateProperty.resolveWith(getColor)
                              : null,
                              cells: [
                              DataCell(
                                Text(data.classNumber.toString()),
                              ),
                              DataCell(
                                Text(data.subject),
                              ),
                              DataCell(
                                Text(data.tp.toString()),
                              ),
                              DataCell(
                                Text(data.time),
                              ),
                              DataCell(
                                Text(data.initialStudents.toString()),
                              ),
                              DataCell(
                                Text(data.refusedStudents.toString()),
                              ),
                              DataCell(
                                Text(data.approvedStudents.toString()),
                              ),
                            ]);
                          },
                        ).toList(),
                        showBottomBorder: true,
                        
              );
                    
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            // By default show a loading spinner.
            return const CircularProgressIndicator();
          },
        )
        ]));
    }

    @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: 
        AppBar(
          title: !_searchBoolean ? Text("As minhas aulas") : _searchTextField(),
          actions:
            !_searchBoolean
            ? [
              IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchBoolean = true;
                  _searchIndexList = [];
                });
              })
            ] 
            : [
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchBoolean = false;
                  });
                }
              )
            ],
            leading:
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {exportToExcel();},
                )),  
      body:
        !_searchBoolean ? _defaultListView() : _searchListView()

        
      ); 
    }
}
