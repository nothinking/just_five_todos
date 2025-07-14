import 'package:flutter/material.dart';
import 'dart:math';

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
  DateTime? completedAt;

  Todo({required this.id, required this.title, this.isDone = false, this.completedAt});
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
        todo.completedAt = DateTime.now();
        _todos.removeWhere((t) => t.id == todo.id);
        _completedTodos.insert(0, todo);
      } else {
        // 미완료로 되돌리기
        todo.isDone = false;
        todo.completedAt = null;
        _completedTodos.removeWhere((t) => t.id == todo.id);
        _todos.insert(0, todo);
      }
    });
  }

  Map<DateTime, int> _getCompletedCountByDay() {
    final Map<DateTime, int> counts = {};
    for (final todo in _completedTodos) {
      if (todo.completedAt != null) {
        final day = DateTime(todo.completedAt!.year, todo.completedAt!.month, todo.completedAt!.day);
        counts[day] = (counts[day] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final visibleTodos = _todos.take(5).toList();
    final visibleCompleted = _completedTodos.take(5).toList();
    final completedCountByDay = _getCompletedCountByDay();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Just Five Todos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _TodoHeatmap(counts: completedCountByDay),
          ),
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

class _TodoHeatmap extends StatelessWidget {
  final Map<DateTime, int> counts;
  final int weeks;
  final int daysPerWeek;
  final int cellSize;
  final int cellPadding;
  final int maxCount;

  _TodoHeatmap({
    required this.counts,
    this.weeks = 12,
    this.daysPerWeek = 7,
    this.cellSize = 16,
    this.cellPadding = 2,
  }) : maxCount = counts.isEmpty ? 1 : counts.values.reduce(max);

  Color _colorForCount(int count) {
    if (count == 0) return Colors.grey[200]!;
    if (count == 1) return Colors.green[100]!;
    if (count == 2) return Colors.green[300]!;
    if (count == 3) return Colors.green[400]!;
    if (count == 4) return Colors.green[600]!;
    return Colors.green[800]!; // 5개 이상
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: weeks * daysPerWeek - 1));
    List<Widget> columns = [];
    for (int w = 0; w < weeks; w++) {
      List<Widget> cells = [];
      for (int d = 0; d < daysPerWeek; d++) {
        final day = start.add(Duration(days: w * daysPerWeek + d));
        final count = counts[DateTime(day.year, day.month, day.day)] ?? 0;
        cells.add(Container(
          width: cellSize.toDouble(),
          height: cellSize.toDouble(),
          margin: EdgeInsets.all(cellPadding.toDouble()),
          decoration: BoxDecoration(
            color: _colorForCount(count),
            borderRadius: BorderRadius.circular(3),
          ),
        ));
      }
      columns.add(Column(children: cells));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: columns),
    );
  }
}
