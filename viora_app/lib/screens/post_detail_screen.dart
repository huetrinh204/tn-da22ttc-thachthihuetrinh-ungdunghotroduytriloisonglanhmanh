import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../constants/app_icons.dart';
import '../l10n/app_localizations.dart';
import 'user_profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  late Post _post;
  List<Comment> _comments = [];
  Map<String, List<dynamic>> _repliesMap = {}; // commentId -> list of replies
  Map<String, bool> _expandedReplies = {}; // commentId -> expanded state
  String? _replyingToCommentId;
  String? _replyingToUserName;
  bool _isLoading = false;
  bool _isSendingComment = false;
  bool _isSendingReply = false;
  String? _commentsError;
  String? _token;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _initTokenAndLoad();
  }

  Future<void> _initTokenAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";
    final profile = await ApiService.getProfile(_token!);
    if (profile["user"] != null) {
      _currentUserId = profile["user"]["id"]?.toString();
    }
    await _loadComments();
  }

  bool get _isOwnPost =>
      _currentUserId != null && _post.userId == _currentUserId;

  Future<void> _deletePost() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePost),
        content: Text(l10n.confirmDeletePost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await ApiService.deletePost(_token ?? "", _post.id);
    if (!mounted) return;
    if (res["message"] == null || res["message"] == "Deleted") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.postDeleted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"] ?? "Failed"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _commentsError = null;
    });

    final token = _token ?? "";
    final response = await ApiService.getComments(token, _post.id);

    if (!mounted) return;

    if (response["message"] != null) {
      setState(() {
        _comments = [];
        _commentsError = response["message"] as String;
        _isLoading = false;
      });
      return;
    }

    final commentsData = response["comments"] as List? ?? [];
    setState(() {
      _comments = commentsData.map((json) => Comment.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSendingComment = true);

    final token = _token ?? "";

    final response = await ApiService.createComment(
      token: token,
      postId: _post.id,
      content: content,
    );

    if (!mounted) return;

    setState(() => _isSendingComment = false);

    if (response["comment"] != null) {
      final newComment = Comment.fromJson(response["comment"]);
      setState(() {
        _comments.insert(0, newComment);
        _post = _post.copyWith(commentCount: _post.commentCount + 1);
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Failed to comment"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUserName = comment.userName;
    });
    // Focus on reply input (which will be in comment input area)
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = null;
    });
    _replyController.clear();
  }

  Future<void> _sendReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty || _replyingToCommentId == null) return;

    setState(() => _isSendingReply = true);

    final token = _token ?? "";
    final commentId = _replyingToCommentId!;

    final response = await ApiService.createReply(
      token: token,
      commentId: commentId,
      content: content,
    );

    if (!mounted) return;

    setState(() => _isSendingReply = false);

    if (response["reply"] != null) {
      // Add reply to map
      final replies = _repliesMap[commentId] ?? [];
      replies.add(response["reply"]);
      setState(() {
        _repliesMap[commentId] = replies;
        _expandedReplies[commentId] = true; // Auto-expand after sending
        // Update reply count in comment
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index] = _comments[index].copyWith(
            replyCount: _comments[index].replyCount + 1,
          );
        }
      });
      _replyController.clear();
      _cancelReply();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Failed to reply"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loadReplies(String commentId) async {
    final token = _token ?? "";
    final response = await ApiService.getReplies(token, commentId);

    if (!mounted) return;

    if (response["replies"] != null) {
      setState(() {
        _repliesMap[commentId] = response["replies"];
        _expandedReplies[commentId] = true;
      });
    }
  }

  void _toggleReplies(Comment comment) {
    final isExpanded = _expandedReplies[comment.id] ?? false;
    
    if (isExpanded) {
      // Collapse
      setState(() {
        _expandedReplies[comment.id] = false;
      });
    } else {
      // Expand - load if not loaded yet
      if (_repliesMap[comment.id] == null) {
        _loadReplies(comment.id);
      } else {
        setState(() {
          _expandedReplies[comment.id] = true;
        });
      }
    }
  }

  void _handleLike() async {
    final token = _token ?? "";
    final wasLiked = _post.isLiked;
    final snapshot = _post;

    setState(() {
      _post = _post.copyWith(
        isLiked: !wasLiked,
        likeCount: wasLiked ? _post.likeCount - 1 : _post.likeCount + 1,
      );
    });

    final response = wasLiked
        ? await ApiService.unlikePost(token, _post.id)
        : await ApiService.likePost(token, _post.id);

    if (response["message"] != null && mounted) {
      setState(() => _post = snapshot);
    }
  }

  void _handleCommentLike(Comment comment) async {
    final token = _token ?? "";
    final wasLiked = comment.isLiked;

    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(
          isLiked: !wasLiked,
          likeCount: wasLiked ? comment.likeCount - 1 : comment.likeCount + 1,
        );
      }
    });

    final response = wasLiked
        ? await ApiService.unlikeComment(token, comment.id)
        : await ApiService.likeComment(token, comment.id);

    if (response["message"] != null && mounted) {
      setState(() {
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) _comments[index] = comment;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: l10n.postContent,
        showBack: true,
        actions: [
          if (_isOwnPost)
            IconButton(
              icon: Icon(AppIcons.delete, color: AppColors.error),
              onPressed: _deletePost,
            ),
        ],
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header
                  _buildPostHeader(),
                  
                  // Post content
                  if (_post.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _post.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  
                  // Post image
                  if (_post.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 500,
                        ),
                        child: Image.network(
                          _post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: context.inputFill,
                            child: Center(
                              child: Icon(
                                AppIcons.image,
                                size: 48,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Hashtags
                  if (_post.hashtags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _post.hashtags.map((tag) => Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Post actions
                  _buildPostActions(l10n),
                  
                  const Divider(height: 1),
                  
                  // Comments section
                  _buildCommentsSection(l10n),
                ],
              ),
            ),
          ),
          
          // Comment input
          _buildCommentInput(l10n),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    final l10n = AppLocalizations.of(context)!;

    void goToProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            userId: _post.userId,
            userName: _post.userName,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar — tappable
          GestureDetector(
            onTap: goToProfile,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _post.userAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        _post.userAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            _post.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _post.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & time — tappable
          Expanded(
            child: GestureDetector(
              onTap: goToProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _post.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(_post.createdAt, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Streak badge
          if (_post.daysStreak != null && _post.daysStreak! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.streak, color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${_post.daysStreak} ${l10n.days}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildActionButton(
            icon: _post.isLiked ? AppIcons.heartFilled : AppIcons.heart,
            label: l10n.likes(_post.likeCount),
            color: _post.isLiked ? AppColors.error : context.textSecondary,
            onTap: _handleLike,
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            icon: AppIcons.message,
            label: l10n.comments(_post.commentCount),
            color: context.textSecondary,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(AppLocalizations l10n) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_commentsError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Text(
                _commentsError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadComments,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                AppIcons.message,
                size: 48,
                color: context.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.writeComment,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCommentItem(_comments[index], l10n);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, AppLocalizations l10n) {
    void goToCommentUserProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            userId: comment.userId,
            userName: comment.userName,
          ),
        ),
      );
    }
    
    final isExpanded = _expandedReplies[comment.id] ?? false;
    final replies = _repliesMap[comment.id] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar — tappable
            GestureDetector(
              onTap: goToCommentUserProfile,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: comment.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          comment.userAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              comment.userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          comment.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: goToCommentUserProfile,
                          child: Text(
                            comment.userName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatTime(comment.createdAt, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => _handleCommentLike(comment),
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked ? AppIcons.heartFilled : AppIcons.heart,
                              size: 14,
                              color: comment.isLiked ? AppColors.error : context.textSecondary,
                            ),
                            if (comment.likeCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${comment.likeCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reply button
                      InkWell(
                        onTap: () => _startReply(comment),
                        child: Text(
                          l10n.reply,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // View/Hide replies button
                  if (comment.replyCount > 0) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _toggleReplies(comment),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.remove : Icons.add,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpanded 
                                ? l10n.hideReplies 
                                : l10n.viewReplies(comment.replyCount),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        // Replies list
        if (isExpanded && replies.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              children: replies.map((replyJson) {
                return _buildReplyItem(comment, replyJson, l10n);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReplyItem(Comment comment, Map<String, dynamic> replyJson, AppLocalizations l10n) {
    final replyUserId = replyJson['user_id'] ?? '';
    final replyUserName = replyJson['user_name'] ?? 'Unknown';
    final replyUserAvatar = replyJson['user_avatar'];
    final replyContent = replyJson['content'] ?? '';
    final replyCreatedAt = replyJson['created_at'] != null
        ? DateTime.parse(replyJson['created_at'])
        : DateTime.now();

    void goToReplyUserProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            userId: replyUserId,
            userName: replyUserName,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          GestureDetector(
            onTap: goToReplyUserProfile,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: replyUserAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        replyUserAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            replyUserName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        replyUserName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Reply content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: goToReplyUserProfile,
                        child: Text(
                          replyUserName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        replyContent,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(replyCreatedAt, l10n),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Reply button
                    InkWell(
                      onTap: () => _startReply(comment),
                      child: Text(
                        l10n.reply,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(AppLocalizations l10n) {
    final isReplying = _replyingToCommentId != null;
    final controller = isReplying ? _replyController : _commentController;
    final isSending = isReplying ? _isSendingReply : _isSendingComment;
    final onSend = isReplying ? _sendReply : _sendComment;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.infoBoxBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply indicator
            if (isReplying) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.reply} $_replyingToUserName',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _cancelReply,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isReplying ? l10n.writeReply : l10n.writeComment,
                      hintStyle: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: context.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                isSending
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: onSend,
                        icon: const Icon(Icons.send_rounded),
                        color: AppColors.primary,
                        iconSize: 24,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
