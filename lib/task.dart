class Task {
  String image;
  String text;
  bool isDone;
  bool isHighlighted;
  bool showCancelIcon;
  bool showCancelText;
  String recordedFilePath;

  Task({
    this.image = '',
    required this.text,
    this.isDone = false,
    this.isHighlighted = false,
    this.showCancelIcon = false,
    this.showCancelText = false,
    this.recordedFilePath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'text': text,
      'isDone': isDone ? 1 : 0,
      'isHighlighted': isHighlighted ? 1 : 0,
      'showCancelIcon': showCancelIcon ? 1 : 0,
      'showCancelText': showCancelText ? 1 : 0,
      'recordedFilePath': recordedFilePath,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      image: map['image'],
      text: map['text'],
      isDone: map['isDone'] == 1,
      isHighlighted: map['isHighlighted'] == 1,
      showCancelIcon: map['showCancelIcon'] == 1,
      showCancelText: map['showCancelText'] == 1,
      recordedFilePath: map['recordedFilePath'],
    );
  }
}