import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Student studentFromJson(String str) => Student.fromJson(json.decode(str));

String studentToJson(Student data) => json.encode(data.toJson());

class Student {
    Student({
        required this.email,
        required this.name,
        required this.number,
        required this.status,
        required this.time,

    });

    String number;
    String name;
    String status;
    String email;
    String time;

    factory Student.fromJson(Map<String, dynamic> json) {
      if (json == "Null") {
        return Student(email: "email", name: "name", number: "number", status: "status", time: "time");
      }
      
        final Timestamp timestamp = json['time'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        String date = "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')}  ${dateTime.hour.toString().padLeft(2,'0')}.${dateTime.minute.toString().padLeft(2,'0')}h";
        json["time"]=date;
      
        return Student(
        number: json["number"],
        name: json["name"],
        email: json["email"],
        status: json["status"],
        time: json["time"],
      );
    }

    Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "email": email,
        "status": status,
        "time": time,

    };
}