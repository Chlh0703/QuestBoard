// Este doc describe una classe, en este caso Quest
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quest_board/models/task_model.dart';
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

  @HiveField(4)
  bool _paused;

  @HiveField(5)
  int _classification; //0: Not_listed 1: Main, 2:Secondary, 3:Repetitive

  @HiveField(6)
  DateTime? _dueDate;

  @HiveField(7)
  List<TaskModel> _tasks;

  QuestModel({
    String? id,
    required this._title,
    required this._experienceReward,
    this._completed = false,
    this._paused = true,
    this._classification = 0,
    List<TaskModel>? tasks,
    this._dueDate,
  }) : id = id ?? const Uuid().v4(),
        _tasks = tasks ?? [];

  String get title => _title;
  bool get completed => _completed;
  bool get paused => _paused;
  int get experienceReward => _experienceReward;
  int get classification => _classification;
  DateTime? get dueDate => _dueDate;
  List<TaskModel> get tasks => List.unmodifiable(_tasks);


  void setTitle(String newTitle) {
    _title = newTitle;
  }

  void setExperienceReward(int newExperienceReward) {
    _experienceReward = newExperienceReward;
  }

  void changeCompletion() {
    _completed = !_completed;
  }

  void togglePaused(){
    _paused = !_paused;
  }

  void setClassification(int newClassification) {
    _classification = newClassification;
  }

  void setDueDate(DateTime? newDueDate) {
    _dueDate = newDueDate;
  }

  void setTasks(List<TaskModel> newTasks){
    _tasks = newTasks;
  }

  bool updateTask(String taskId,
      { String? newTitle,
        int? newCurrentCount,
        int? newTargetCount,
        bool? taskTapped}){
    final task = _tasks.cast<TaskModel?>().firstWhere(
          (q) => q?.id == taskId,
      orElse: () => null,
    );

    if (task == null) return false;

    // Quest
    if (newTitle != null) {
      task.setTitle(newTitle);
    }

    if (newCurrentCount != null) {
      task.setCurrentCount(newCurrentCount);
    }

    if (newTargetCount != null) {
      task.setTargetCount(newTargetCount);
    }

    final previousCompleted = _completed;


    if (taskTapped != null) {
      if (task.targetCount != null) {
        final currentCount = task.currentCount ?? 0;
        if (currentCount < task.targetCount!) {
          task.setCurrentCount(currentCount + 1);
        }
        if (currentCount == task.targetCount!){
          task.changeCompletion();
        }
      } else {
        task.changeCompletion();
      }
      _completed = _tasks.isNotEmpty &&
          _tasks.every((task) => task.completed);
    }

    return previousCompleted != _completed;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': _title,
      'completed': completed,
      'experienceReward': _experienceReward,
      'paused': _paused,
      'classification': _classification,
      'dueDate': _dueDate?.toIso8601String(),
      'tasks': _tasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'completed': task.completed,
          'dueDate': task.dueDate?.toIso8601String(),
        };
      }).toList(),
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    final tasks = (map['tasks'] as List<dynamic>? ?? [])
        .map(
          (task) => TaskModel(
            id: task['id'],
            title: task['title'],
            completed: task['completed'] ?? false,
            dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      ),
    ).toList();
    return QuestModel(
        id: map['id'],
        title: map['title'],
        experienceReward: map['experienceReward'],
        completed: map['completed'],
        paused: map['paused'],
        classification: map['classification'] ?? 0,
        dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
        tasks: tasks
    );
  }
}