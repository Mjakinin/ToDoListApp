import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(String) onDeleteItem;
  final int index;

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onDeleteItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id!),
      onDismissed: (_) {
        onDeleteItem(todo.id!);
      },
      background: Container(
        decoration: BoxDecoration(
          color: tdRed,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 5, left: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10), // Add space for the drag handle icon
            const Icon(Icons.drag_handle), // Drag handler icon
            Expanded(
              child: ListTile(
                onTap: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                tileColor: Colors.white,
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$index. ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: tdBlack,
                        ),
                      ),
                      TextSpan(
                        text: todo.todoText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tdBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
