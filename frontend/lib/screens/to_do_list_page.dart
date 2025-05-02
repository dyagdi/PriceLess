import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/constants/constants_url.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Map<String, dynamic>> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();
  final TextEditingController _newListController = TextEditingController();
  int? _selectedListId;
  List<Map<String, dynamic>> _shoppingLists = [];

  @override
  void initState() {
    super.initState();
    _fetchShoppingLists();
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchShoppingLists() async {
    String? token = await _getAuthToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${baseUrl}shopping-lists/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _shoppingLists = List<Map<String, dynamic>>.from(data['shopping_lists']);
        if (_shoppingLists.isNotEmpty && _selectedListId == null) {
          _selectedListId = _shoppingLists[0]['id'];
          _fetchItems();
        }
      });
    }
  }

  Future<void> _createNewList(String name) async {
    if (name.isEmpty) return;
    String? token = await _getAuthToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('${baseUrl}shopping-lists/create/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 201) {
      _newListController.clear();
      _fetchShoppingLists();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Liste oluşturulurken hata oluştu")),
      );
    }
  }

  Future<void> _fetchItems() async {
    print("Fetching items for list: $_selectedListId");
    if (_selectedListId == null) {
      print("No list selected, cannot fetch items");
      return;
    }
    
    String? token = await _getAuthToken();
    print("Auth token for fetching items: ${token != null ? 'present' : 'missing'}");
    
    if (token == null) {
      print("No auth token available");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}shopping-lists/$_selectedListId/items/'),
        headers: {'Authorization': 'Token $token'},
      );

      print("Fetch items response status: ${response.statusCode}");
      print("Fetch items response body: ${response.body}");

      if (response.statusCode == 200) {
        final items = List<Map<String, dynamic>>.from(json.decode(response.body));
        print("Fetched ${items.length} items");
        
        setState(() {
          _toDoItems = items;
        });
      } else {
        print("Error fetching items: ${response.body}");
      }
    } catch (e) {
      print("Exception fetching items: $e");
    }
  }

  Future<void> _addItem(String item) async {
    print("Adding item: $item to list: $_selectedListId");
    if (item.isEmpty || _selectedListId == null) {
      print("Empty item or no list selected");
      return;
    }
    
    String? token = await _getAuthToken();
    print("Auth token: ${token != null ? 'present' : 'missing'}");
    
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oturum açmanız gerekiyor!")),
      );
      return;
    }

    try {
      print("Sending API request to add item");
      final response = await http.post(
        Uri.parse('${baseUrl}shopping-lists/$_selectedListId/items/add/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({'name': item}),
      );

      if (!mounted) return;
      
      print("API response status: ${response.statusCode}");
      print("API response body: ${response.body}");

      if (response.statusCode == 201) {
        _controller.clear();
        print("Item added successfully, fetching items");
        _fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Öğe eklenirken hata oluştu: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error adding item: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Öğe eklenirken hata oluştu: $e")),
      );
    }
  }

  Future<void> _toggleItem(int index) async {
    String? token = await _getAuthToken();
    if (token == null) return;
    int itemId = _toDoItems[index]['id'];

    final response = await http.post(
      Uri.parse('${baseUrl}items/$itemId/toggle/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      _fetchItems();
    }
  }

  Future<void> _deleteItem(int index) async {
    String? token = await _getAuthToken();
    if (token == null) return;
    int itemId = _toDoItems[index]['id'];

    final response = await http.delete(
      Uri.parse('${baseUrl}items/$itemId/delete/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 204) {
      _fetchItems();
    }
  }

  Future<void> _inviteUser(String email) async {
    if (_selectedListId == null || email.isEmpty) return;
    String? token = await _getAuthToken();
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}shopping-lists/$_selectedListId/add-member/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'email': email
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _inviteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Davet başarıyla gönderildi!")),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? "Davet gönderilirken hata oluştu")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Davet gönderilirken hata oluştu: $e")),
      );
    }
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Liste Oluştur"),
        content: TextField(
          controller: _newListController,
          decoration: const InputDecoration(
            hintText: "Liste adı",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () => _createNewList(_newListController.text),
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }

  Future<void> _showListMembers() async {
    if (_selectedListId == null) return;
    String? token = await _getAuthToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}shopping-lists/$_selectedListId/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final listData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Liste Üyeleri"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sahip: ${listData['owner']}", 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Paylaşılan kişiler:", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<Map<String, dynamic>>.from(listData['members']).map<Widget>((member) => 
                    Text("• ${member['name'] ?? member['username'] ?? member['email']}")
                ).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kapat"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Üye listesi alınırken hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paylaşılan Alışveriş Listesi"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showListMembers,
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateListDialog,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DropdownButton<int>(
                      value: _selectedListId,
                      isExpanded: true,
                      hint: const Text("Liste seçin"),
                      items: _shoppingLists.map((list) {
                        return DropdownMenuItem<int>(
                          value: list['id'],
                          child: Text(list['name']),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedListId = newValue;
                          _fetchItems();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inviteController,
                            decoration: const InputDecoration(
                              hintText: "E-posta ile kullanıcı davet et",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _inviteUser(_inviteController.text),
                          icon: const Icon(Icons.person_add),
                          label: const Text("Davet Et"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Yeni öğe ekle",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addItem(_controller.text),
                      icon: const Icon(Icons.add),
                      label: const Text("Ekle"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _toDoItems.length,
              itemBuilder: (context, index) {
                final item = _toDoItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: item['is_done'],
                      onChanged: (_) => _toggleItem(index),
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        decoration: item['is_done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text("Ekleyen: ${item['added_by']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}