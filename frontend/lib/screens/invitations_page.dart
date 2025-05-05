import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:frontend/constants/constants_url.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  _InvitationsPageState createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  List<dynamic> _pendingInvitations = [];
  bool _isLoading = true;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
    _connectWebSocket();
  }

  Future<void> _loadInvitations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}invitations/pending/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingInvitations = data['invitations'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading invitations: $e');
    }
  }

  Future<void> _connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(
            'wss://priceless.onrender.com/ws/notifications/?token=$token'),
      );

      _channel?.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'invitation') {
          _loadInvitations(); // Reload invitations when a new one arrives
        }
      });
    } catch (e) {
      print('WebSocket error: $e');
    }
  }

  Future<void> _respondToInvitation(int invitationId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}invitations/respond/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'invitation_id': invitationId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        _loadInvitations(); // Reload the list after responding
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation ${action}ed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error responding to invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ortak Alışveriş Listesi Davetleri'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingInvitations.isEmpty
              ? const Center(child: Text('No pending invitations'))
              : ListView.builder(
                  itemCount: _pendingInvitations.length,
                  itemBuilder: (context, index) {
                    final invitation = _pendingInvitations[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(invitation['shopping_list_name']),
                        subtitle: Text('From: ${invitation['sender_name']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _respondToInvitation(
                                  invitation['id'], 'accept'),
                              child: const Text('Accept'),
                            ),
                            TextButton(
                              onPressed: () => _respondToInvitation(
                                  invitation['id'], 'decline'),
                              child: const Text('Decline'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
