class Task {
  String image;
  String text;
  bool isDone;
  bool isHighlighted;

  Task({
    this.image = '',
    required this.text,
    this.isDone = false,
    this.isHighlighted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'text': text,
      'isDone': isDone ? 1 : 0,
      'isHighlighted': isHighlighted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      image: map['image'],
      text: map['text'],
      isDone: map['isDone'] == 1,
      isHighlighted: map['isHighlighted'] == 1,
    );
  }
}