import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_teste/Models/student.dart';

Class classFromJson(String str) => Class.fromJson(json.decode(str));

//String classToJson(Class data) => json.encode(data.toJson());

class Class{



  List<Class> classList= [];
  List<Student> studentList= [];
  
  String id;
  int classNumber;
  String subject;
  String teacher;
  String teacherEmail;
  String time;
  int tp;
  String year;
  int approvedStudents;
  int refusedStudents;
  int initialStudents;


    Class({
        required this.id,
        required this.classNumber,
        required this.subject,
        required this.teacher,
        required this.teacherEmail,
        required this.time,
        required this.tp,
        required this.year,
        this.approvedStudents=0,
        this.initialStudents=0,
        this.refusedStudents=0

    });
   

    factory Class.fromJson(Map<String, dynamic> json) {
      if (json == "Null") {
        return Class(id: "id", classNumber: 0, subject: "subject", teacher: "teacher", teacherEmail: "teacherEmail", time: "time", tp: 0, year: "year");
      }

      final Timestamp timestamp = json['time'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        String date = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')}  ${dateTime.hour.toString().padLeft(2,'0')}.${dateTime.minute.toString().padLeft(2,'0')}h";
        json["time"]=date;

      json["classNumber"] = int.parse(json["classNumber"]);
      json["tp"] = int.parse(json["tp"]);

      return Class(
        id: json["id"],
        classNumber: json["classNumber"],
        subject: json["subject"],
        teacher: json["teacher"],
        teacherEmail: json["teacherEmail"],
        time: json["time"],
        tp: json["tp"],
        year: json["year"],
    );
    }

     static int Function(Class, Class) sorter(int sortOrder, String property) {
     int handleSortOrder(int sortOrder, int sort) {
       if (sortOrder == 1) {
         // a is before b
         if (sort == -1) {
           return -1;
         } else if (sort > 0) {
           // a is after b
           return 1;
         } else {
           // a is same as b
           return 0;
         }
       } else {
         // a is before b
         if (sort == -1) {
           return 1;
         } else if (sort > 0) {
           // a is after b
           return 0;
         } else {
           // a is same as b
           return 0;
         }
       }
     }

    return (Class a, Class b) {
      switch (property) {
        case "classNumber":
            int sort = a.classNumber.compareTo(b.classNumber);
            return handleSortOrder(sortOrder, sort);
        case "tp":
            int sort = a.tp.compareTo(b.tp);
            return handleSortOrder(sortOrder, sort);
        default: 
          return sortOrder;           

      }
    };
  }

    // sortOrder = 1 ascending | 0 descending
  static sortClass(List<Class> classs, {int sortOrder = 1, String property = "classNumber"}) {
    switch (property) {
      case "classNumber":
        classs.sort(sorter(sortOrder, "tp"));
        classs.sort(sorter(sortOrder, "classNumber"));
        break;
      case "tp":
        classs.sort(sorter(sortOrder, property));
        break;
      default:
        print("Unrecognized property $property");
    }
    return classs;
  }

    Map<String, dynamic> toFirestore() => {
        "id": id,
        "classNumber": classNumber,
        "subject": subject,
        "teacher": teacher,
        "teacherEmail": teacherEmail,
        "time": time,
        "tp": tp,
        "year": year,
    };

    Future<List<Class>> getClass(emailTeacher) async {

    int n=0;
    await FirebaseFirestore.instance.collection('BD')
                                    .where("teacherEmail", isEqualTo: emailTeacher)
                                    .get().then(
    (snapshot) => snapshot.docs.forEach((document) async {
      
      classList.add(Class.fromJson(document.data()));
      
      await FirebaseFirestore.instance.collection("BD").doc(document.id).collection('Students').get().then(
        (snapshot) => snapshot.docs.forEach((element) {
          if (element.data().isEmpty) {
            print(n.toString() + 'BD ' + classList[n].subject + "  - VAZIA");
          }
          else{
            studentList.add(Student.fromJson(element.data()));
            print(n.toString() + 'BD ' + classList[n].subject);        
            if (studentList.length>0) {
              for (var i = 0; i < studentList.length; i++) {
                if (studentList[i].status=='Initial') {
                  
                    classList[n].initialStudents++;

                  print(i.toString() + 'Student ' + studentList[i].status);
                  print("Vou alterar "+ classList[n].initialStudents.toString() );
                }
                if (studentList[i].status=='Refused') {

                    classList[n].refusedStudents++;

                  print(i.toString() + 'Student ' + studentList[i].status);
                  print("Vou alterar "+ classList[n].initialStudents.toString() );
                }else{

                    classList[n].approvedStudents++;

                  print(i.toString() + 'Student ' + studentList[i].status);
                  print("Vou alterar "+ classList[n].initialStudents.toString() );
              }
            
            studentList.clear();
            }
          }
          
        }
    }));n=n+1;

      }
      
      ));
      
        return classList;    
    }

    
        


}