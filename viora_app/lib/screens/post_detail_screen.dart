import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
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
  late Post _post;
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSendingComment = false;
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
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
                    Image.network(
                      _post.imageUrl!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 300,
                        color: context.inputFill,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: context.textSecondary,
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
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    "${_post.daysStreak} ${l10n.days}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF9800),
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
            icon: _post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: l10n.likes(_post.likeCount),
            color: _post.isLiked ? Colors.red : context.textSecondary,
            onTap: _handleLike,
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: l10n.comments(_post.commentCount),
            color: context.textSecondary,
            onTap: () {},
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: l10n.share,
            color: context.textSecondary,
            onTap: () {
              // TODO: Implement share
            },
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
                Icons.chat_bubble_outline,
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
    
    return Row(
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
                          comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: comment.isLiked ? Colors.red : context.textSecondary,
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
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(AppLocalizations l10n) {
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: TextStyle(color: context.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.writeComment,
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
                onSubmitted: (_) => _sendComment(),
              ),
            ),
            const SizedBox(width: 8),
            _isSendingComment
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
                    onPressed: _sendComment,
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.primary,
                    iconSize: 24,
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
