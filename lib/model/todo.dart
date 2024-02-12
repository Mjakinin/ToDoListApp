import 'dart:convert';

class ToDo {
  String? id;
  String? todoText;

  ToDo({
    required this.id,
    required this.todoText,
  });

  // Convert ToDo object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
    };
  }

  // Convert JSON format to ToDo object
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
    );
  }

  // Convert list of ToDo objects to JSON format
  static String todoListToJson(List<ToDo> todos) {
    List<Map<String, dynamic>> todoListJson =
    todos.map((todo) => todo.toJson()).toList();
    return jsonEncode(todoListJson);
  }

  // Convert JSON format to list of ToDo objects
  static List<ToDo> todoListFromJson(String jsonStr) {
    List<dynamic> todoListJson = jsonDecode(jsonStr);
    return todoListJson.map((json) => ToDo.fromJson(json)).toList();
  }

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Run a marathon'),
      ToDo(id: '02', todoText: 'Road trip across the USA'),
      ToDo(id: '03', todoText: 'Write a book'),
      ToDo(id: '04', todoText: 'Learn to play a musical instrument'),
      ToDo(id: '05', todoText: 'Learn to speak Spanish fluently'),
    ];
  }
}
