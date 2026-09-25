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

  @HiveField(3)
  DateTime? _dueDate;

  @HiveField(4)
  int? _currentCount;

  @HiveField(5)
  int? _targetCount;

  TaskModel({
    String? id,
    required this._title,
    this._completed = false,
    this._dueDate,
    this._currentCount,
    this._targetCount,
  })  : id = id ?? const Uuid().v4();

  String get title => _title;
  bool get completed => _completed;
  DateTime? get dueDate => _dueDate;
  int? get currentCount => _currentCount;
  int? get targetCount => _targetCount;

  void setTitle(String newTitle) {
    _title = newTitle;
  }

  void changeCompletion() {
    _completed = !_completed;
  }

  void setDueDate(DateTime newDueDate) {
    _dueDate = newDueDate;
  }

  void setCurrentCount(int newCurrentCount){
    _currentCount = newCurrentCount;
  }

  void setTargetCount(int newTargetCount){
    _targetCount = newTargetCount;
  }
}