class ScheduleModel {
  final int id;
  final String name;
  bool addingTasks;
  bool checkboxClickable;
  bool showTaskInput;
  int highlightedTaskIndex;

  ScheduleModel(
      {
        required this.id,
        required this.name,
        this.addingTasks=true,
        this.checkboxClickable=false,
        this.showTaskInput=false,
        this.highlightedTaskIndex=-1,
      }
  );

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      name: map['name'],
      addingTasks: map['addingTasks'] == 1,
      checkboxClickable: map['checkboxClickable'] == 1,
      showTaskInput: map['showTaskInput'] == 1,
      highlightedTaskIndex: map['highlightedTaskIndex'] ?? -1 ,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'addingTasks': addingTasks ? 1 : 0,
      'checkboxClickable': checkboxClickable ? 1 : 0,
      'showTaskInput': showTaskInput ? 1 : 0,
      'highlightedTaskIndex': highlightedTaskIndex,
    };
  }
}
