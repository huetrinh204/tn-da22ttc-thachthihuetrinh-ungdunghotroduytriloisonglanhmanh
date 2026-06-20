import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../providers/locale_provider.dart';
import '../services/ai_chat_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../constants/app_icons.dart';

class AdminAiAssistantTab extends StatefulWidget {
  const AdminAiAssistantTab({super.key});

  @override
  State<AdminAiAssistantTab> createState() => _AdminAiAssistantTabState();
}

class _AdminAiAssistantTabState extends State<AdminAiAssistantTab>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardListenerNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _inputError;
  late AnimationController _typingAnimController;

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _keyboardListenerNode.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('admin_ai_chat_history');
    if (raw == null) return;
    final List<dynamic> decoded = jsonDecode(raw);
    setState(() {
      _messages = decoded
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = _messages.length > 50
        ? _messages.sublist(_messages.length - 50)
        : _messages;
    await prefs.setString('admin_ai_chat_history',
        jsonEncode(trimmed.map((m) => m.toJson()).toList()));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages = [..._messages, userMsg];
      _isLoading = true;
      _inputError = null;
    });
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final history = _messages.sublist(0, _messages.length - 1);

      final reply = await AiChatService.sendMessage(
        token: token,
        message: text,
        history: history,
        language: LocaleProvider.global.locale.languageCode,
      );

      if (!mounted) return;

      final aiMsg = ChatMessage(
        role: 'ai',
        content: reply,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages = [..._messages, aiMsg];
        _isLoading = false;
      });

      _saveHistory();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on AiChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _inputError = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inputError = 'Không có kết nối mạng. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleProvider.global.locale.languageCode == 'en' ? 'Clear history' : 'Xóa lịch sử'),
        content: Text(LocaleProvider.global.locale.languageCode == 'en'
            ? 'Delete the entire conversation?'
            : 'Xóa toàn bộ cuộc trò chuyện?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_ai_chat_history');
    setState(() => _messages = []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(bottom: BorderSide(color: context.infoBoxBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(AppIcons.aiChat, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleProvider.global.locale.languageCode == 'en'
                          ? 'AI Assistant'
                          : 'Trợ lý AI',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _isLoading ? 'Đang suy nghĩ...' : 'Sẵn sàng hỗ trợ',
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              if (_messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: _clearHistory,
                  tooltip: 'Xóa lịch sử',
                ),
            ],
          ),
        ),

        // Messages or empty state
        Expanded(
          child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
        ),

        // Input area
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.aiChat, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              LocaleProvider.global.locale.languageCode == 'en'
                  ? 'Admin AI Assistant'
                  : 'Trợ lý AI Quản trị',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              LocaleProvider.global.locale.languageCode == 'en'
                  ? 'I can help you manage the system, analyze data, and answer questions about the platform.'
                  : 'Tôi có thể giúp bạn quản lý hệ thống, phân tích dữ liệu và trả lời câu hỏi về nền tảng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildTypingIndicator();
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(AppIcons.aiChat, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : context.cardColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                border: isUser
                    ? null
                    : Border.all(color: context.infoBoxBorder),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : context.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(AppIcons.aiChat, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(color: context.infoBoxBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _typingAnimController,
                  builder: (context, child) {
                    final delay = i * 0.15;
                    final t = ((_typingAnimController.value - delay) % 1.0).clamp(0.0, 1.0);
                    final size = 6.0 + (t * 6.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.infoBoxBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: _keyboardListenerNode,
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !HardwareKeyboard.instance.isShiftPressed) {
                      if (_textController.text.trim().isNotEmpty && !_isLoading) {
                        _sendMessage();
                      }
                    }
                  },
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: LocaleProvider.global.locale.languageCode == 'en'
                          ? 'Ask anything...'
                          : 'Nhập câu hỏi...',
                      filled: true,
                      fillColor: context.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    style: TextStyle(fontSize: 15, color: context.textPrimary),
                    onChanged: (_) {
                      if (_inputError != null) setState(() => _inputError = null);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey.shade300 : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(AppIcons.send, color: Colors.white, size: 20),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
