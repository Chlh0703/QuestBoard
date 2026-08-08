// Este doc describe una classe, en este caso Quest
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 1)
class QuestModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  String _title;

  @HiveField(2)
  String _description;

  @HiveField(3)
  bool _completed;

  QuestModel({
    String? id,
    required this._title,
    required this._description,
    this._completed = false,
  })  : id = id ?? const Uuid().v4();


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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "title": _title,
      "description": _description,
      "completed": _completed,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'],
      title: map["title"],
      description: map["description"],
      completed: map["completed"],
    );
  }
}


