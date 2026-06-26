// Este doc describe una classe, en este casi Quest

class Quest {
  String _title;
  String _description;
  bool _completed;

  Quest({
    required this._title,
    required this._description,
    required this._completed,
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