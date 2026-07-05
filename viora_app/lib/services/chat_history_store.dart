import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatHistoryStore {
  static const _baseKey = 'ai_chat_history';
  static const _maxItems = 50;

  static Future<String> _getKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('cached_user_id') ?? 'default';
    return '${_baseKey}_$userId';
  }

  static Future<List<ChatMessage>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      final all = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
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
    final key = await _getKey();
    final trimmed = messages.length > _maxItems
        ? messages.sublist(messages.length - _maxItems)
        : messages;
    await prefs.setString(key, jsonEncode(trimmed.map((m) => m.toJson()).toList()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    await prefs.remove(key);
  }
}
