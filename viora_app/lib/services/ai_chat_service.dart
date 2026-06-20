import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'api_service.dart';

class AiChatException implements Exception {
  final String message;
  final int? statusCode;
  const AiChatException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AiChatService {
  static Future<String> sendMessage({
    required String token,
    required String message,
    required List<ChatMessage> history,
    String language = 'vi',
  }) async {
    // Map chat history to backend format
    final historyPayload = history.map((m) => {
      'role': m.isUser ? 'user' : 'model',
      'parts': [{'text': m.content}],
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'history': historyPayload,
          'language': language,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['reply'] as String? ?? '';
      } else if (response.statusCode == 400) {
        throw const AiChatException(
          'Tin nhắn không hợp lệ. Vui lòng kiểm tra lại nội dung.',
          statusCode: 400,
        );
      } else if (response.statusCode == 401) {
        throw const AiChatException('Phiên đăng nhập hết hạn.', statusCode: 401);
      } else {
        throw const AiChatException(
          'Trợ lý AI đang bận, vui lòng thử lại sau ít phút.',
          statusCode: 503,
        );
      }
    } on AiChatException {
      rethrow;
    } catch (e) {
      throw const AiChatException('Không có kết nối mạng. Vui lòng thử lại.');
    }
  }
}
