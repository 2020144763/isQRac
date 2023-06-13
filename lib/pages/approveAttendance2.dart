import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/Models/student.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';


 
class ApproveAtt2 extends StatefulWidget {
    String selectedDoc;

    ApproveAtt2({super.key, required this.selectedDoc});
  
  @override
  _ApproveAtt2State createState() => _ApproveAtt2State();
  }
  class _ApproveAtt2State extends State<ApproveAtt2>{
 
  List <String> selectedStudentList = [];
  final MultiSelectController<String> _controller = MultiSelectController();
  List<Student> _studentList= [];

@override
  void initState() {
    super.initState();
    displayData();
  }  
   @override
  void dispose() {
    _studentList=[];
    selectedStudentList=[];
    widget.selectedDoc="";
    print('Dispose used');
    super.dispose();
  }

  displayData() async {
    clearStudentList(_studentList);
    var collect = FirebaseFirestore.instance.collection("BD").doc(widget.selectedDoc).collection('Students');
    List<Map<String, dynamic>> tempList =[];

    var data = await collect.get();
    data.docs.forEach((element) {
    tempList.add(element.data());
    if (element.data().isNotEmpty) {
      setState((){
      _studentList.add(Student.fromJson(element.data()));
      });
    }
    });
}
  
  @override
  Widget build(BuildContext context) {

   return Scaffold(
      appBar: PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child:  
                AppBar(
                  backgroundColor: Color.fromARGB(255, 217, 217, 223),
                  leading:
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () => Navigator. of(context).pop(),
                    ), 
            )),
      body: 
SingleChildScrollView(child: 
  Wrap(children:[
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
          Center(
            child:
            
          Container(
            margin: EdgeInsets.all(50),
            decoration: BoxDecoration(
            border: Border.all(color: Colors.grey)
            
          ),
          child:
            //======================================= Students List selection
            
              MultiSelectCheckList(
                key: UniqueKey(),
                maxSelectableCount: 40,
                textStyles: const MultiSelectTextStyles(
                selectedTextStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
                itemsDecoration: MultiSelectDecorations(
                selectedDecoration:
                  BoxDecoration(color: Colors.grey.withOpacity(0.5))),
                listViewSettings: ListViewSettings(
                separatorBuilder: (context, index) => const Divider(
                height: 0,
                        )),
                controller: _controller,
                items: List.generate(
                    _studentList.length,
                    (index) => CheckListCard(
                        value: _studentList[index].name,
                        title: Text(_studentList[index].name,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children:[
                          Text(_studentList[index].status,style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                          const SizedBox(width: 10),
                          Text(_studentList[index].time.toString())
                          ]),
                        selectedColor: Color.fromARGB(255, 112, 87, 87),
                        checkColor: Colors.grey,
                        //selected: index == 3,
                        //enabled: !(index == 5),
                        checkBoxBorderSide:
                            const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                onChange: (allSelectedItems, selectedItem) {
                  selectedStudentList = allSelectedItems;
                  print(selectedStudentList);
                },
                onMaximumSelected: (allSelectedItems, selectedItem) {
                  /*CustomSnackBar.showInSnackBar(
                      'The limit has been reached', context);*/
                },
              )
              ),
      
   )]
   )
   ])
   ),
        
//=========================================================================== Footer buttons  
        persistentFooterButtons: [
        Container(
          padding: EdgeInsets.all(15),
          //color: Color.fromARGB(255, 208, 206, 206),
          child:  
          Row(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[ 
              ElevatedButton(
                onPressed: ()async {
                  print(selectedStudentList);
                  await updateStudentStatus(selectedStudentList, widget.selectedDoc);
                  await Future.delayed(const Duration(seconds: 1));
                  displayData();
                },
                child: const Text('Aprovar')
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: ()async {
                  print(selectedStudentList);
                  await refuseStudentStatus(selectedStudentList, widget.selectedDoc);
                  await Future.delayed(const Duration(seconds: 1));
                  displayData();
                },
                child: const Text('Recusar')
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () {
                  _controller.deselectAll();
                  print(selectedStudentList);
                },
                child: const Text('Desselecionar tudo')
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () {
                  _controller.selectAll();
                  print(_controller.selectAll());
                  selectedStudentList=_controller.selectAll();
                  print(selectedStudentList);
                },
                child: const Text('Selecionar tudo')
              ),
          ]
          ))
        ]
        );
        }
  }

  clearStudentList(studentList){
    studentList.clear();
  }

updateStudentStatus(List lista, String selectedDoc) async{

  lista.forEach((name){
    
    var documents = FirebaseFirestore.instance.collection("BD").doc(selectedDoc).collection('Students').where("name", isEqualTo: name).get().then((value) {
    value.docs.forEach((element) {
      final docStudent = FirebaseFirestore.instance.collection("BD").doc(selectedDoc).collection('Students').doc(element.id);
      docStudent.update({'status': 'Approved'});
      });
    });
  });  
}

refuseStudentStatus(List lista, String selectedDoc) async{

  lista.forEach((name) async {

    var documents = FirebaseFirestore.instance.collection("BD").doc(selectedDoc).collection('Students').where("name", isEqualTo: name).get().then((value) {
    value.docs.forEach((element) {
      final docStudent = FirebaseFirestore.instance.collection("BD").doc(selectedDoc).collection('Students').doc(element.id);
      docStudent.update({'status': 'Refused'});
      });
    });
  });  
}
  

  
  