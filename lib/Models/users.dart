import 'dart:convert';

Users userFromJson(String str) => Users.fromJson(json.decode(str));

String userToJson(Users data) => json.encode(data.toJson());

class Users {
    Users({
        required this.nameFirst,
        required this.nameLast,
        required this.email,
        required this.genre,
        required this.type,
        required this.number,
    });

    String nameFirst;
    String nameLast;
    String email;
    String genre;
    String type;
    String number;

    factory Users.fromJson(Map<String, dynamic> json) {

      return Users(
        nameFirst: json["nameFirst"],
        nameLast: json["nameLast"],
        email: json["email"],
        genre: json["genre"],
        number: json["number"],
        type: json["type"],
    );
    
    }

    Map<String, dynamic> toJson() => {
        "nameFirst": nameFirst,
        "nameLast": nameLast,
        "email": email,
        "genre": genre,
        "number": number,
        "type": type,
    };
}