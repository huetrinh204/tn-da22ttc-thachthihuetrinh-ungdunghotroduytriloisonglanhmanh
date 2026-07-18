import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../providers/locale_provider.dart';
import '../services/ai_chat_service.dart';
import '../services/chat_history_store.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../constants/app_icons.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_notification_dialog.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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

  Future<void> _loadHistory() async {
    final history = await ChatHistoryStore.load();
    if (!mounted) return;
    setState(() => _messages = history);
    if (history.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
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

      // Pass all messages except the last (just-added user msg) as history
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

      await ChatHistoryStore.save(_messages);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on AiChatException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 400) {
        setState(() {
          _isLoading = false;
          _inputError = e.message;
          _messages = _messages.sublist(0, _messages.length - 1);
        });
        _textController.text = text;
      } else {
        final errMsg = ChatMessage(
          role: 'ai',
          content: e.message,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages = [..._messages, errMsg];
          _isLoading = false;
        });
        _textController.text = text;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages = _messages.sublist(0, _messages.length - 1);
      });
      _textController.text = text;
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.error,
          title: 'Mất kết nối',
          content: 'Không có kết nối mạng. Vui lòng thử lại.',
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        icon: Icons.delete_outline_rounded,
        iconColor: Colors.red,
        iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
        title: 'Xóa lịch sử',
        content: 'Bạn có chắc muốn xóa toàn bộ lịch sử hội thoại?',
        cancelText: 'Hủy',
        confirmText: 'Xóa',
        confirmColor: Colors.red,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    if (confirm == true) {
      await ChatHistoryStore.clear();
      if (mounted) setState(() => _messages = []);
    }
  }

  @override
  void dispose() {
    _typingAnimController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bongbongchat.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Viora Coach',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textGreen,
                  ),
                ),
                Text(
                  'Huấn luyện viên lối sống',
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: Icon(AppIcons.delete, color: context.textSecondary, size: 20),
              tooltip: 'Xóa lịch sử',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/AI_chatbox.png'),
                  fit: BoxFit.contain,
                  colorFilter: isDark
                      ? ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken)
                      : ColorFilter.mode(Colors.white.withValues(alpha: 0.3), BlendMode.lighten),
                ),
              ),
              child: _messages.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bongbongchat.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viora Coach',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Xin chào! Tôi là Viora Coach 🌿',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tôi có thể giúp bạn về sức khỏe, dinh dưỡng và xây dựng thói quen lành mạnh.',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSuggestionChip('💧 Uống bao nhiêu nước mỗi ngày?'),
                        _buildSuggestionChip('🏃 Tập thể dục bao lâu là đủ?'),
                        _buildSuggestionChip('😴 Làm sao ngủ sâu hơn?'),
                        _buildSuggestionChip('🌱 Cách duy trì thói quen tốt?'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return _SuggestionChip(text: text);
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final isError = !isUser &&
        (msg.content.contains('bận') ||
            msg.content.contains('không hợp lệ') ||
            msg.content.contains('hết hạn'));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
              Container(
              width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bongbongchat.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFFE8F5E9)
                      : isError ? Colors.red.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: isError ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                      : Border.all(color: context.infoBoxBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                ),
              child: isUser
                  ? Text(msg.content, style: TextStyle(fontSize: 14, color: context.textPrimary, height: 1.45))
                  : MarkdownBody(
                      data: msg.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(fontSize: 14, color: isError ? Colors.red.shade700 : context.textPrimary, height: 1.45),
                        strong: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isError ? Colors.red.shade700 : context.textPrimary, height: 1.45),
                        listBullet: TextStyle(fontSize: 14, color: isError ? Colors.red.shade700 : context.textPrimary, height: 1.45),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/bongbongchat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: context.infoBoxBorder),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.3;
                    final val = (_typingAnimController.value - delay).clamp(0.0, 1.0);
                    final opacity = (val < 0.5 ? val * 2 : (1 - val) * 2).clamp(0.3, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: opacity), shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    final canSend = _textController.text.trim().isNotEmpty && !_isLoading;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _inputError != null && _inputError!.isNotEmpty ? Colors.red : AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onChanged: (_) {
                            if (_inputError != null && _inputError!.isNotEmpty) setState(() => _inputError = '');
                            setState(() {});
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty && !_isLoading) _sendMessage();
                          },
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(fontSize: 14, color: context.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: canSend ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: canSend ? _sendMessage : null,
                  child: Container(
                    width: 44, height: 44, alignment: Alignment.center,
                    child: Icon(AppIcons.send, color: canSend ? Colors.white : context.textSecondary, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String text;
  const _SuggestionChip({required this.text});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final screen = context.findAncestorStateOfType<_AiChatScreenState>();
          screen?._textController.text = widget.text;
          screen?.setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          transform: _isHovered ? (Matrix4.identity()..translate(0, -2)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 13,
              color: _isHovered ? AppColors.primaryDark : AppColors.primary,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
