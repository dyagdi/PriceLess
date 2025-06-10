import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/widgets/elegant_toast.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/theme_provider.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();
  final TextEditingController _newListController = TextEditingController();
  int? _selectedListId;
  List<Map<String, dynamic>> _shoppingLists = [];
  Map<String, dynamic>? _selectedListDetails;
  String? _currentUserUsername;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchShoppingLists();
    _getCurrentUser();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _shoppingLists =
            List<Map<String, dynamic>>.from(data['shopping_lists']);
        if (_shoppingLists.isNotEmpty && _selectedListId == null) {
          _selectedListId = _shoppingLists[0]['id'];
          _fetchItems();
          _fetchListDetails(_selectedListId!);
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
    print(
        "Auth token for fetching items: ${token != null ? 'present' : 'missing'}");

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
        final items =
            List<Map<String, dynamic>>.from(json.decode(response.body));
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
          SnackBar(
              content: Text("Öğe eklenirken hata oluştu: ${response.body}")),
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
        body: json.encode({'email': email}),
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
          SnackBar(
              content: Text(
                  errorData['error'] ?? "Davet gönderilirken hata oluştu")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Davet gönderilirken hata oluştu: $e")),
      );
    }
  }

  Future<void> _deleteList(int listId) async {
    String? token = await _getAuthToken();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}shopping-lists/$listId/delete/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 204) {
        ElegantToast.showSuccess(context, "Liste başarıyla silindi!");

        // Reset selected list if it was the deleted one
        if (_selectedListId == listId) {
          setState(() {
            _selectedListId = null;
            _toDoItems.clear();
          });
        }

        // Refresh the lists
        _fetchShoppingLists();
      } else if (response.statusCode == 404) {
        // Parse error message from response if available
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Liste bulunamadı veya yetkiniz yok';
          ElegantToast.showError(context, errorMessage);
        } catch (e) {
          ElegantToast.showError(context,
              "Bu listeyi silme yetkiniz yok. Sadece liste sahibi listeyi silebilir.");
        }
      } else {
        // Handle other error status codes
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Liste silinirken hata oluştu';
          ElegantToast.showError(context, errorMessage);
        } catch (e) {
          ElegantToast.showError(
              context, "Liste silinirken hata oluştu (${response.statusCode})");
        }
      }
    } catch (e) {
      if (!mounted) return;
      ElegantToast.showError(context, "Bağlantı hatası: $e");
    }
  }

  void _showDeleteListConfirmation(int listId, String listName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Liste Sil",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "'$listName' listesini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve listedeki tüm öğeler de silinecektir.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "İptal",
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteList(listId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Sil",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
                ...List<Map<String, dynamic>>.from(listData['members'])
                    .map<Widget>((member) => Text(
                        "• ${member['name'] ?? member['username'] ?? member['email']}"))
                    .toList(),
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

  Future<void> _fetchListDetails(int listId) async {
    String? token = await _getAuthToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}shopping-lists/$listId/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final listData = json.decode(response.body);
        setState(() {
          _selectedListDetails = listData;
        });
      }
    } catch (e) {
      print("Error fetching list details: $e");
    }
  }

  Future<void> _getCurrentUser() async {
    String? token = await _getAuthToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user-info/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _currentUserUsername = userData['username'] ?? userData['email'];
        });
      }
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  bool _isCurrentUserOwner() {
    if (_selectedListDetails == null || _currentUserUsername == null)
      return false;
    return _selectedListDetails!['owner'] == _currentUserUsername;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          },
        ),
        title: Text(
          "Alışveriş Listeleri",
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people,
                color: Colors.blue,
                size: 20,
              ),
            ),
            onPressed: _showListMembers,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.green,
                size: 20,
              ),
            ),
            onPressed: _showCreateListDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // List Selection Section
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Liste Seçin",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showCreateListDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                "Yeni Liste",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Selected list display
                            if (_selectedListId != null) ...[
                              _buildSelectedListCard(),
                              const SizedBox(height: 12),
                            ],
                            // Other lists
                            if (_shoppingLists.length > 1) ...[
                              Text(
                                "Diğer Listeler",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._shoppingLists
                                  .where(
                                      (list) => list['id'] != _selectedListId)
                                  .map((list) => _buildListCard(list, false))
                                  .toList(),
                            ],
                            if (_shoppingLists.isEmpty) ...[
                              _buildEmptyListState(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Actions Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Hızlı İşlemler",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              "Ürün Ekle",
                              Icons.add_circle_outline,
                              Colors.blue,
                              () => _showAddItemDialog(),
                            ),
                          ),
                          Expanded(
                            child: _buildQuickAction(
                              "Davet Et",
                              Icons.person_add,
                              Colors.green,
                              () => _showInviteDialog(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Items List Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Liste Öğeleri",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_toDoItems.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _toDoItems.length,
                          itemBuilder: (context, index) {
                            final item = _toDoItems[index];
                            return _buildListItem(item, index);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        categorizedProducts: const {},
      ),
    );
  }

  Widget _buildQuickAction(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz öğe eklenmemiş",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Listeye ürün eklemek için yukarıdaki 'Ürün Ekle' butonunu kullanın",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item['is_done'],
          onChanged: (_) => _toggleItem(index),
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          item['name'],
          style: GoogleFonts.poppins(
            decoration: item['is_done'] ? TextDecoration.lineThrough : null,
            color: item['is_done']
                ? Colors.grey[600]
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          "Ekleyen: ${item['added_by']}",
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
          onPressed: () => _deleteItem(index),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Yeni Ürün Ekle",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Ürün adını yazın",
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "İptal",
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addItem(_controller.text);
              Navigator.pop(context);
            },
            child: Text(
              "Ekle",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Kullanıcı Davet Et",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _inviteController,
          decoration: InputDecoration(
            hintText: "E-posta adresi",
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "İptal",
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _inviteUser(_inviteController.text);
              Navigator.pop(context);
            },
            child: Text(
              "Davet Et",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedListCard() {
    final selectedList = _shoppingLists.firstWhere(
      (list) => list['id'] == _selectedListId,
      orElse: () => {'name': 'Unknown', 'id': _selectedListId},
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mainGreen, AppColors.mainGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.playlist_add_check,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedList['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isCurrentUserOwner()) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Sahip",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Aktif Liste • ${_toDoItems.length} öğe",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (_isCurrentUserOwner()) ...[
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: () {
                    _showDeleteListConfirmation(
                        _selectedListId!, selectedList['name']);
                  },
                  tooltip: "Listeyi Sil",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(Map<String, dynamic> list, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedListId = list['id'];
              _selectedListDetails = null;
            });
            _fetchItems();
            _fetchListDetails(list['id']);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppColors.mainGreen
                    : Theme.of(context).dividerColor.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[700]?.withOpacity(0.3)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Listeye geç",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyListState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[700]?.withOpacity(0.3)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.playlist_add,
              size: 40,
              color: isDark ? Colors.grey[400] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz liste yok",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "İlk alışveriş listenizi oluşturmak için\n'Yeni Liste' butonuna tıklayın",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateListDialog,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              "İlk Listenizi Oluşturun",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
