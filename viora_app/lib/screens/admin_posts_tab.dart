import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import '../models/post.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_snackbar.dart';

class AdminPostsTab extends StatefulWidget {
  const AdminPostsTab({super.key});

  @override
  State<AdminPostsTab> createState() => _AdminPostsTabState();
}

class _AdminPostsTabState extends State<AdminPostsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _posts = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentSort = 'latest';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    try {
      final search =
          _searchController.text.isNotEmpty ? _searchController.text : null;
      final res = await ApiService.getAdminPosts(
        _token,
        search: search,
        sort: _currentSort,
      );
      if (!mounted) return;
      setState(() {
        _posts = res['posts'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _loadPosts();
      }
    });
  }

  void _changeSortOrder(String sort) {
    setState(() => _currentSort = sort);
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(l10n),
        _buildSearchAndFilter(l10n),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                  ? _buildEmptyState(l10n)
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) =>
                            _buildPostCard(_posts[index], l10n),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final count = _posts.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              AppIcons.message,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count ${l10n.posts}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.adminPosts,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchPostsOrAuthors,
              prefixIcon: const Icon(AppIcons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(AppIcons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _loadPosts();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(l10n.latest, 'latest'),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip(l10n.oldest, 'oldest'),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip(l10n.trendingLabel, 'trending'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentSort == value;
    return GestureDetector(
      onTap: () => _changeSortOrder(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : context.isDark
                  ? const Color(0xFF24352E)
                  : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : context.isDark
                    ? const Color(0xFF2E433C)
                    : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF24352E)
                    : const Color(0xFFF0F1F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? AppIcons.search : AppIcons.message,
                size: 40,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isSearching ? l10n.noPostsFound : l10n.noPostsYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, AppLocalizations l10n) {
    final hasImage = post['image_url'] != null && post['image_url'].toString().isNotEmpty;
    final hasContent = post['content'] != null && post['content'].toString().isNotEmpty;
    final hashtags = post['hashtags'] != null
        ? List<String>.from(post['hashtags'])
        : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2E433C)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post['user_avatar'] != null
                      ? NetworkImage(
                          ApiService.resolveImageUrl(post['user_avatar']),
                        )
                      : null,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: post['user_avatar'] == null
                      ? Text(
                          post['user_name']?[0]?.toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.isDark
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['user_name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        post['user_email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(post['created_at']),
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (hasContent)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
              child: Text(
                post['content'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: context.textPrimary,
                ),
              ),
            ),
          if (hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    ApiService.resolveImageUrl(post['image_url']),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: context.isDark
                          ? const Color(0xFF24352E)
                          : const Color(0xFFF0F1F3),
                      child: Center(
                        child: Icon(
                          AppIcons.image,
                          size: 36,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0,
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: hashtags.map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
            ),
            child: Row(
              children: [
                _buildStatItem(AppIcons.heart, '${post['like_count'] ?? 0}'),
                const SizedBox(width: AppSpacing.lg),
                _buildStatItem(
                  AppIcons.message,
                  '${post['comment_count'] ?? 0}',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(height: 1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            child: Row(
              children: [
                _buildActionButton(
                  icon: AppIcons.eye,
                  label: l10n.viewDetails,
                  color: AppColors.primary,
                  onTap: () => _viewPostDetails(post),
                ),
                _buildActionButton(
                  icon: AppIcons.flag,
                  label: l10n.reportViolation,
                  color: AppColors.warning,
                  onTap: () => _reportViolation(
                    post['id'],
                    post['user_id'],
                    post['content'],
                  ),
                ),
                _buildActionButton(
                  icon: AppIcons.delete,
                  label: l10n.deletePost,
                  color: AppColors.error,
                  onTap: () => _deletePost(post['id'], post['content']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: context.textSecondary),
        const SizedBox(width: 5),
        Text(
          count,
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return '';
    }
  }

  Future<void> _viewPostDetails(Map<String, dynamic> postData) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final post = Post.fromJson({
        'id': postData['id'].toString(),
        'user_id': postData['user_id']?.toString() ?? '0',
        'user_name': postData['user_name'] ?? 'Unknown',
        'user_avatar': postData['user_avatar'],
        'content': postData['content'] ?? '',
        'image_url': postData['image_url'],
        'hashtags': postData['hashtags'] ?? [],
        'like_count': postData['like_count'] ?? 0,
        'comment_count': postData['comment_count'] ?? 0,
        'is_liked': false,
        'created_at': postData['created_at'],
        'challenge_name': null,
        'is_following': false,
        'is_followed_back': false,
        'is_own_post': false,
      });
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, '${l10n.failed}: $e');
      }
    }
  }

  Future<void> _deletePost(int postId, String? content) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        icon: AppIcons.delete,
        iconColor: AppColors.error,
        iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
        title: l10n.deletePost,
        content: l10n.confirmDeletePostMessage(content ?? ''),
        cancelText: l10n.cancel,
        confirmText: l10n.delete,
        confirmColor: AppColors.error,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiService.deletePostAdmin(_token, postId.toString());
      if (mounted) {
        AppSnackbar.showSuccess(context, l10n.postDeleted);
      }
      _loadPosts();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, '${l10n.failed}: $e');
      }
    }
  }

  Future<void> _reportViolation(
    int postId,
    dynamic userId,
    String? content,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final customReasonController = TextEditingController();
    String? selectedReason;

    final reasons = [
      l10n.violentContent,
      l10n.spamContent,
      l10n.hateSpeech,
      l10n.misinformation,
      l10n.adultContent,
      l10n.copyrightViolation,
      l10n.otherReason,
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF2E433C)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        AppIcons.flag,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.warningViolation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (content != null && content.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF24352E)
                          : const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0xFF2E433C)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      '"$content"',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.selectViolationReason,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...reasons.map(
                  (reason) => InkWell(
                    onTap: () => setDialogState(() {
                      selectedReason = reason;
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedReason == reason
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: selectedReason == reason
                                    ? AppColors.primary
                                    : context.textSecondary,
                                width: 2,
                              ),
                            ),
                            child: selectedReason == reason
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedReason == reason
                                    ? context.textPrimary
                                    : context.textSecondary,
                                fontWeight: selectedReason == reason
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selectedReason == l10n.otherReason) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customReasonController,
                    decoration: InputDecoration(
                      hintText: l10n.enterReason,
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: context.isDark
                                ? const Color(0xFF2E433C)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          String? finalReason;
                          if (selectedReason == l10n.otherReason) {
                            finalReason = customReasonController.text.trim();
                          } else {
                            finalReason = selectedReason;
                          }
                          Navigator.pop(ctx, finalReason);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.sendWarning,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;
    try {
      await ApiService.reportPostViolation(_token, postId.toString(), result);
      if (mounted) {
        AppSnackbar.showSuccess(context, l10n.warningSent);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, '${l10n.failed}: $e');
      }
    }
  }
}
