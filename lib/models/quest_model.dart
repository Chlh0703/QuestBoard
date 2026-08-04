// Este doc describe una classe, en este caso Quest
import 'package:hive_flutter/hive_flutter.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 1)
class QuestModel extends HiveObject {

  @HiveField(0)
  String _title;

  @HiveField(1)
  String _description;

  @HiveField(2)
  bool _completed;

  QuestModel({
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
