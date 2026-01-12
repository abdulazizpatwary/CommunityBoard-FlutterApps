import 'package:firebase_database/firebase_database.dart';

class Board{
  String? key;
  String? subject;
  String? body;

  Board(this.subject, this.body);
  Board.fromSnapshot(DataSnapshot snapshot) {
      final map= snapshot.value as Map<dynamic,dynamic>;
      body=map["body"] ;
      subject=map["subject"];
      key = snapshot.key;
  }
  toJson(){
    return {
      "subject":subject,
      "body":body,

    };
  }

}