class TaskModel {
  final int status, id;
  final String content;

  TaskModel({required this.status, required this.content, required this.id});

  TaskModel.fromMap(Map<String, dynamic> map)
      : status = map['status'] ?? 0,
        content = map['content'] ?? '',
        id = map['id'] ?? 0;
}
