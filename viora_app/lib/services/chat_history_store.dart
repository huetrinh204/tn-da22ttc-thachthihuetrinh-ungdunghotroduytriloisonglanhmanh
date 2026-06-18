import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatHistoryStore {
  static const _key = 'ai_chat_history';
  static const _maxItems = 50;

  static Future<List<ChatMessage>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      final all = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      // Return only the last _maxItems messages
      if (all.length > _maxItems) {
        return all.sublist(all.length - _maxItems);
      }
      return all;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = messages.length > _maxItems
        ? messages.sublist(messages.length - _maxItems)
        : messages;
    await prefs.setString(_key, jsonEncode(trimmed.map((m) => m.toJson()).toList()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
