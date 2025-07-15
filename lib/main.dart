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
  bool _canAdd = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canAdd = _controller.text.trim().isNotEmpty;
      });
    });
  }

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Just Five Todos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 8),
                // const Text(
                //   '완료한 Todo 히트맵',
                //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                // ),
                // const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _TodoHeatmap(counts: completedCountByDay),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '할 일을 입력하세요',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        elevation: 2,
                      ),
                      onPressed: _canAdd ? _addTodo : null,
                      child: const Text('추가', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // const Text(
                //   '할 일',
                //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                // ),
                // const SizedBox(height: 8),
                ...visibleTodos.map((todo) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          todo.title,
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => _toggleComplete(todo),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                      ),
                    )),
                if (visibleTodos.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: const Text('할 일을 추가해보세요!', style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(height: 24),
                if (visibleCompleted.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Divider(height: 32, thickness: 1),
                      // const Text('완료한 일', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      // const SizedBox(height: 8),
                      ...visibleCompleted.map((todo) => Card(
                            color: Colors.grey[200],
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              title: Text(
                                todo.title,
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              leading: Checkbox(
                                value: todo.isDone,
                                onChanged: (_) => _toggleComplete(todo),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _completedTodos.removeWhere((t) => t.id == todo.id);
                                  });
                                },
                              ),
                            ),
                          )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TodoHeatmap extends StatefulWidget {
  final Map<DateTime, int> counts;
  final int weeks;
  final int daysPerWeek;
  final int cellSize;
  final int cellPadding;
  final int maxCount;
  final List<Color> palette;

  _TodoHeatmap({
    required this.counts,
    this.weeks = 53,
    this.daysPerWeek = 7,
    this.cellSize = 11,
    this.cellPadding = 2,
  })  : maxCount = counts.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b),
        palette = const [
          Color(0xFFebedf0), // 0
          Color(0xFF9be9a8), // 1
          Color(0xFF40c463), // 2
          Color(0xFF30a14e), // 3
          Color(0xFF216e39), // 4+
        ];

  @override
  State<_TodoHeatmap> createState() => _TodoHeatmapState();
}

class _TodoHeatmapState extends State<_TodoHeatmap> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  int _colorIndex(int count) {
    if (count == 0) return 0;
    if (count == 1) return 1;
    if (count == 2) return 2;
    if (count == 3) return 3;
    return 4;
  }

  String _monthLabel(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final int weekday = today.weekday;
    final DateTime thisMonday = today.subtract(Duration(days: weekday - 1));
    final DateTime start = thisMonday.subtract(Duration(days: (widget.weeks - 1) * 7));

    List<TableRow> rows = [];
    for (int d = 0; d < widget.daysPerWeek; d++) {
      List<Widget> cells = [];
      for (int w = 0; w < widget.weeks; w++) {
        final day = start.add(Duration(days: w * widget.daysPerWeek + d));
        if (day.isAfter(today)) {
          cells.add(const SizedBox.shrink());
        } else {
          final count = widget.counts[DateTime(day.year, day.month, day.day)] ?? 0;
          cells.add(Tooltip(
            message: '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}: $count개 완료',
            child: Container(
              width: widget.cellSize.toDouble(),
              height: widget.cellSize.toDouble(),
              margin: EdgeInsets.all(widget.cellPadding.toDouble()),
              decoration: BoxDecoration(
                color: widget.palette[_colorIndex(count)],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ));
        }
      }
      rows.add(TableRow(children: cells));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              children: rows,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
