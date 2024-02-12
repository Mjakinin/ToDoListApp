import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final _todosList = <ToDo>[];
  late List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  bool _isButtonEnabled = true; // Zustand für die Aktivierung des Buttons

  @override
  void initState() {
    _loadAndShuffleToDoList();
    super.initState();
  }

  Future<void> _loadAndShuffleToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getString('todo_list');
    if (todoListJson != null) {
      setState(() {
        _todosList.clear();
        _todosList.addAll(ToDo.todoListFromJson(todoListJson));
        _foundToDo = List.from(_todosList);
      });
    } else {
      // Wenn keine gespeicherten ToDos vorhanden sind, initialisiere die Liste mit vordefinierten ToDos
      setState(() {
        _todosList.addAll(ToDo.todoList());
        _foundToDo = List.from(_todosList);
      });
      _saveToDoList(); // Speichern Sie die vordefinierte Liste, damit sie beim nächsten Mal geladen wird
    }
    _shuffleToDoList(); // Mischen Sie die Liste, nachdem sie geladen wurde
  }

  void _shuffleToDoList() {
    setState(() {
      _todosList.shuffle();
      _foundToDo = List.from(_todosList);
    });
  }

  Future<void> _saveToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = ToDo.todoListToJson(_todosList);
    await prefs.setString('todo_list', todoListJson);
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.1),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Container(
        margin: const EdgeInsets.only(top: 0), // Margin für die gesamte Liste
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: Column(
            children: [
              Container(), // Leere Container-Ansicht für den oberen Rand
              Expanded(
                child: ReorderableListView(
                  proxyDecorator: proxyDecorator,
                  onReorder: _reorderItems,
                  children: _foundToDo
                      .asMap()
                      .entries
                      .map((entry) => _buildToDoItem(entry.key, entry.value))
                      .toList(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: tdBGColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 20,
                            top: 0,
                            right: 20,
                            left: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.transparent,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _todoController,
                            onChanged: (value) {
                              setState(() {
                                _isButtonEnabled = value.isNotEmpty;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Add your dreams here...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 30,
                          right: 20,
                        ),
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled
                              ? () {
                            if (_todoController.text.isNotEmpty) {
                              _addToDoItem(_todoController.text);
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tdBlack,
                            minimumSize: const Size(70, 70),
                            elevation: 20,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToDoItem(int index, ToDo todo) {
    return ToDoItem(
      key: ValueKey(todo.id),
      todo: todo,
      onDeleteItem: _deleteToDoItem,
      index: index + 1,
    );
  }

  void _deleteToDoItem(String id) {
    setState(() {
      _todosList.removeWhere((item) => item.id == id);
      _saveToDoList();
      _foundToDo.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String toDo) {
    setState(() {
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      _todosList.add(ToDo(id: timeStamp, todoText: toDo));
      _foundToDo.insert(0, ToDo(id: timeStamp, todoText: toDo));
      _saveToDoList();
    });
    _todoController.clear();
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final ToDo item = _foundToDo.removeAt(oldIndex);
      _foundToDo.insert(newIndex, item);
      _saveToDoList();
    });
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = List.from(_todosList);
    } else {
      results = _todosList
          .where((item) =>
          item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: _runFilter,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      surfaceTintColor: Colors.transparent,
      title: searchBox(),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Bucket List',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
