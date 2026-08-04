// Este doc describe una classe, en este caso Quest

import 'dart:convert';
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Quest extends HiveObject {

  @HiveField(0)
  String _title;

  @HiveField(1)
  String _description;

  @HiveField(2)
  bool _completed;

  Quest({
    required this._title,
    required this._description,
    this._completed = false,
  });

  String get title => _title;
  String get description => _description;
  bool get completed => _completed;

  void setTitle(String newTitle) {
    _title = newTitle;
  }

  void setDescription(String newDescription) {
    _description = newDescription;
  }

  void changeCompletion(){
    _completed = !_completed;
  }

}


  String language;

  @HiveField(1)
  String examName;

  @HiveField(2)
  int examId;

  @HiveField(3)
  Profile profile;

  @HiveField(4)
  ListExam listexam;

  @override
  String toString() {
    return jsonEncode({
      'language': this.language,
      'examName': this.examName,
      'examId': this.examId,
      'profile': this.profile,
      'listexam': this.listexam
    });
  }

  PersonModel(
      this.language, this.examName, this.examId, this.profile, this.listexam);
}