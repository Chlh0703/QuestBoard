import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String _title;

  @HiveField(2)
  bool _completed;

  TaskModel({
    String? id,
    required this._title,
    this._completed = false,
  })  : id = id ?? const Uuid().v4();

  String get title => _title;
  bool get completed => _completed;

  void setTitle(String newTitle) {
    _title = newTitle;
  }

  void changeCompletion() {
    _completed = !_completed;
  }
}