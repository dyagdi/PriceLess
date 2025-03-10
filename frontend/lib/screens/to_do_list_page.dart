import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_navigation.dart';

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<Map<String, dynamic>> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem(String item) {
    if (item.isNotEmpty) {
      setState(() {
        _toDoItems.add({'text': item, 'isDone': false});
        _controller.clear();
      });
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _toDoItems[index]['isDone'] = !_toDoItems[index]['isDone'];
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _toDoItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Market Ürünleri Listesi"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ürün ekle",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addItem(_controller.text),
                  child: Text("Ekle"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _toDoItems.length,
              itemBuilder: (context, index) {
                final item = _toDoItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      item['text'],
                      style: TextStyle(
                        decoration: item['isDone']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            item['isDone']
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () => _toggleItem(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
      ),
    );
  }
}
