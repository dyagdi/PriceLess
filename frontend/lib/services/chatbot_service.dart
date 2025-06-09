import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static Future<String> sendMessage(String userId, String message) async {
    // For local development use: http://127.0.0.1:8000/chat
    final url = Uri.parse("https://priceless-chatbot.onrender.com/chat"); // Testing regular chat endpoint

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? "Yanıt alınamadı.";
    } else {
      return "Bir hata oluştu: ${response.statusCode}";
    }
  }
}
