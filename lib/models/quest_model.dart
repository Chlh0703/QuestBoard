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
  bool _completed;

  @HiveField(3)
  int _experienceReward;

  QuestModel({
    String? id,
    required this._title,
    required this._experienceReward,
    this._completed = false,
  }) : id = id ?? const Uuid().v4();

  String get title => _title;
  bool get completed => _completed;
  int get experienceReward => _experienceReward;

  void setTitle(String newTitle) {
    _title = newTitle;
  }

  void setExperienceReward(int newExperienceReward) {
    _experienceReward = newExperienceReward;
  }

  void changeCompletion() {
    _completed = !_completed;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': _title,
      'completed': _completed,
      'experienceReward': _experienceReward,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'],
      title: map['title'],
      experienceReward: map['experienceReward'],
      completed: map['completed'],
    );
  }
}