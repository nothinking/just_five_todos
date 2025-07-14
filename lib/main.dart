import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Five Todos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListPage(),
    );
  }
}

class Todo {
  final int id;
  final String title;
  bool isDone;

  Todo({required this.id, required this.title, this.isDone = false});
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Todo> _todos = [];
  final List<Todo> _completedTodos = [];
  final TextEditingController _controller = TextEditingController();
  int _nextId = 1;

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos.insert(0, Todo(id: _nextId++, title: text));
        _controller.clear();
      });
    }
  }

  void _toggleComplete(Todo todo) {
    setState(() {
      if (!todo.isDone) {
        // 완료 처리
        todo.isDone = true;
        _todos.removeWhere((t) => t.id == todo.id);
        _completedTodos.insert(0, todo);
      } else {
        // 미완료로 되돌리기
        todo.isDone = false;
        _completedTodos.removeWhere((t) => t.id == todo.id);
        _todos.insert(0, todo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTodos = _todos.take(5).toList();
    final visibleCompleted = _completedTodos.take(5).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Just Five Todos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '할 일을 입력하세요',
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _controller.text.trim().isEmpty ? null : _addTodo,
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: visibleTodos.length,
              itemBuilder: (context, index) {
                final todo = visibleTodos[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => _toggleComplete(todo),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        tooltip: '미루기',
                        onPressed: () {
                          setState(() {
                            _todos.removeWhere((t) => t.id == todo.id);
                            _todos.add(todo);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _todos.removeWhere((t) => t.id == todo.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (visibleCompleted.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('완료한 일', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...visibleCompleted.map((todo) => ListTile(
                        title: Text(
                          todo.title,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => _toggleComplete(todo),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _completedTodos.removeWhere((t) => t.id == todo.id);
                            });
                          },
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
