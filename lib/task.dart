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
}