import 'dart:convert';

Subject studentFromJson(String str) => Subject.fromJson(json.decode(str));

class Subject {
    Subject({
        required this.name,
        required this.teacherTP1,
        required this.teacherTP2,
        required this.teacherTP3,
        required this.totalClass,

    });

    String name;
    String teacherTP1;
    String teacherTP2;
    String teacherTP3;
    String totalClass;

    factory Subject.fromJson(Map<String, dynamic> json) {
      if (json == "Null") {
        return Subject(name: "name", teacherTP1: "Nulo", teacherTP2: "Nulo",teacherTP3: "Nulo",totalClass: "totalClass");
      }else{

        if(json["teacherTP2"]==""){
          json["teacherTP2"]="Sem TP2";
        }
        if(json["teacherTP3"]==""){
          json["teacherTP3"]="Sem TP3";
        }
      
        return Subject(
        name: json["name"],
        teacherTP1: json["teacherTP1"],
        teacherTP2: json["teacherTP2"],
        teacherTP3: json["teacherTP3"],
        totalClass: json["totalClass"],

      );
      }
    }

}