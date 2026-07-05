import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import '../models/post.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_notification_dialog.dart';
import '../widgets/admin_post_skeleton.dart';
import '../widgets/admin_state_widgets.dart';

class AdminPostsTab extends StatefulWidget {
  const AdminPostsTab({super.key});

  @override
  State<AdminPostsTab> createState() => _AdminPostsTabState();
}

class _AdminPostsTabState extends State<AdminPostsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _posts = [];
  List<dynamic> _reports = [];
  int _pendingReportCount = 0;
  String _filterMode = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _currentSort = 'latest';

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadReports();
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

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    final res = await ApiService.getReports(_token);
    if (!mounted) return;
    setState(() {
      _reports = res['reports'] ?? [];
      _pendingReportCount = _reports.length;
    });
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

  List<dynamic> get _filteredPosts {
    switch (_filterMode) {
      case 'warned':
        return _posts.where((p) => p['is_warned'] == true).toList();
      case 'pending':
        return _posts
            .where((p) => p['is_warned'] == true && p['edited_after_warn'] == true)
            .toList();
      default:
        return _posts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final posts = _filteredPosts;
    return Column(
      children: [
        _buildHeader(l10n, posts),
        _buildSearchBar(l10n),
        _buildFilterChips(l10n),
        Expanded(
          child: _isLoading
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg + 80,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (_, __) => const AdminPostSkeleton(),
                )
              : posts.isEmpty
                  ? _buildEmptyState(l10n)
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) =>
                            _buildPostCard(posts[index], l10n),
                      ),
                    ),
        ),
      ],
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n, List<dynamic> posts) {
    final count = posts.length;
    final warnedCount = _posts.where((p) => p['is_warned'] == true).length;
    final pendingCount = _posts
        .where((p) => p['is_warned'] == true && p['edited_after_warn'] == true)
        .length;
    final isWarningMode = _filterMode == 'warned' || _filterMode == 'pending';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isWarningMode ? AppColors.warning : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isWarningMode ? AppIcons.shield : AppIcons.message,
              color: isWarningMode ? AppColors.warning : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _filterMode == 'warned'
                      ? l10n.warnedPostsCount(count)
                      : _filterMode == 'pending'
                          ? l10n.pendingPostsCount(count)
                          : '$count ${l10n.posts}',
                  style: AppTypography.headingMedium.copyWith(
                    color: context.textPrimary,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _filterMode == 'warned'
                      ? l10n.dismissWarningHint
                      : _filterMode == 'pending'
                          ? l10n.approveRejectHint
                          : l10n.adminPostsStatus(
                              l10n.adminPosts, warnedCount, pendingCount),
                  style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          if (_pendingReportCount > 0)
            GestureDetector(
              onTap: _showReportsSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Text(
                      '$_pendingReportCount',
                      style: AppTypography.captionBold.copyWith(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────
  Widget _buildSearchBar(AppLocalizations l10n) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: AppTypography.body.copyWith(
          fontSize: 14,
          color: context.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.searchPostsOrAuthors,
          hintStyle: AppTypography.bodySecondary.copyWith(fontSize: 14),
          prefixIcon: Icon(AppIcons.search, size: 20, color: context.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(AppIcons.close, size: 18, color: context.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _loadPosts();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── FILTER CHIPS ─────────────────────────────────────────────────
  Widget _buildFilterChips(AppLocalizations l10n) {
    final warnedCount = _posts.where((p) => p['is_warned'] == true).length;
    final pendingCount = _posts
        .where((p) => p['is_warned'] == true && p['edited_after_warn'] == true)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, 0, AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: Row(
          children: [
            _buildSortDropdown(l10n),
            const SizedBox(width: AppSpacing.sm),
            if (_filterMode != 'all')
              _buildModeChip(
                icon: AppIcons.arrowLeft,
                label: l10n.all,
                isActive: false,
                onTap: () => setState(() => _filterMode = 'all'),
              ),
            if (_filterMode == 'all') ...[
              _buildModeChip(
                icon: AppIcons.shield,
                label: l10n.warned,
                isActive: _filterMode == 'warned',
                badge: warnedCount,
                onTap: () => setState(() => _filterMode = 'warned'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildModeChip(
                icon: AppIcons.clock,
                label: l10n.pending,
                isActive: _filterMode == 'pending',
                badge: pendingCount,
                onTap: () => setState(() => _filterMode = 'pending'),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(AppLocalizations l10n) {
    final sortLabel = switch (_currentSort) {
      'oldest' => l10n.oldest,
      'trending' => l10n.trendingLabel,
      _ => l10n.latest,
    };
    final sortIcon = switch (_currentSort) {
      'oldest' => AppIcons.arrowUp,
      'trending' => AppIcons.trendingUp,
      _ => AppIcons.arrowDown,
    };
    return PopupMenuButton<String>(
      onSelected: (value) => _changeSortOrder(value),
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      elevation: 4,
      color: context.isDark ? const Color(0xFF1A2E27) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      itemBuilder: (_) => [
        _buildPopupItem(value: 'latest', icon: AppIcons.arrowDown, label: l10n.latest, selected: _currentSort == 'latest'),
        _buildPopupItem(value: 'oldest', icon: AppIcons.arrowUp, label: l10n.oldest, selected: _currentSort == 'oldest'),
        _buildPopupItem(value: 'trending', icon: AppIcons.trendingUp, label: l10n.trendingLabel, selected: _currentSort == 'trending'),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF24352E) : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sortIcon, size: 14, color: context.textSecondary),
            const SizedBox(width: 6),
            Text(
              sortLabel,
              style: AppTypography.captionBold,
            ),
            const SizedBox(width: 4),
            Icon(AppIcons.chevronDown, size: 14, color: context.textSecondary.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem({
    required String value,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: selected ? AppColors.primary : context.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : context.textPrimary,
              ),
            ),
          ),
          if (selected)
            Icon(AppIcons.check, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.warning.withValues(alpha: 0.12)
              : context.isDark ? const Color(0xFF24352E) : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.warning.withValues(alpha: 0.4)
                : context.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? AppColors.warning : context.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.captionBold.copyWith(
                color: isActive ? AppColors.warning : context.textSecondary,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badge',
                  style: AppTypography.captionBold.copyWith(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────
  Widget _buildEmptyState(AppLocalizations l10n) {
    final isSearching = _searchController.text.isNotEmpty;
    final icon = _filterMode == 'pending'
        ? AppIcons.clock
        : _filterMode == 'warned'
            ? AppIcons.shield
            : (isSearching ? AppIcons.search : AppIcons.message);
    final title = _filterMode == 'pending'
        ? l10n.noPendingPosts
        : _filterMode == 'warned'
            ? l10n.noWarnedPosts
            : (isSearching ? l10n.noPostsFound : l10n.noPostsYet);
    final subtitle = _filterMode == 'pending'
        ? 'Không có bài viết nào chờ duyệt'
        : _filterMode == 'warned'
            ? 'Không có bài viết nào bị cảnh báo'
            : (isSearching ? 'Thử từ khóa khác để tìm bài viết' : 'Chưa có bài viết nào từ cộng đồng');
    return AdminEmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
    );
  }

  // ─── POST CARD ────────────────────────────────────────────────────
  Widget _buildPostCard(Map<String, dynamic> post, AppLocalizations l10n) {
    final hasImage = post['image_url'] != null && post['image_url'].toString().isNotEmpty;
    final hasContent = post['content'] != null && post['content'].toString().isNotEmpty;
    final hashtags = post['hashtags'] != null
        ? List<String>.from(post['hashtags'])
        : <String>[];
    final isWarned = post['is_warned'] == true;
    final isPending = isWarned && post['edited_after_warn'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isWarned
              ? AppColors.warning.withValues(alpha: 0.3)
              : context.isDark
                  ? const Color(0xFF2E433C)
                  : const Color(0xFFE5E7EB),
          width: isWarned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Author + date + badge ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: post['user_avatar'] != null
                      ? NetworkImage(ApiService.resolveImageUrl(post['user_avatar']))
                      : null,
                  backgroundColor: AppColors.primaryLight,
                  child: post['user_avatar'] == null
                      ? Text(
                          post['user_name']?[0]?.toUpperCase() ?? 'U',
                          style: AppTypography.title.copyWith(
                            fontSize: 14,
                            color: AppColors.primary,
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
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatDate(post['created_at']),
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isWarned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending ? AppIcons.clock : AppIcons.shield,
                          size: 12,
                          color: isPending ? AppColors.primary : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                          Text(
                            isPending ? l10n.pending : l10n.warned,
                            style: AppTypography.captionBold.copyWith(
                              fontSize: 11,
                              color: isPending ? AppColors.primary : AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Row 2: Content ──
          if (hasContent)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
              child: Text(
                post['content'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  height: 1.5,
                  color: context.textPrimary,
                ),
              ),
            ),

          // ── Row 3: Image ──
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
                      color: context.isDark ? const Color(0xFF24352E) : const Color(0xFFF0F1F3),
                      child: Center(
                        child: Icon(AppIcons.image, size: 36, color: context.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Row 4: Stats + hashtags ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
            ),
            child: Row(
              children: [
                _buildStatItem(AppIcons.heart, '${post['like_count'] ?? 0}'),
                const SizedBox(width: AppSpacing.lg),
                _buildStatItem(AppIcons.message, '${post['comment_count'] ?? 0}'),
                if (hashtags.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: hashtags.take(3).map(
                          (tag) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.captionBold.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Row 5: Approve/Reject (if pending) ──
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0,
              ),
              child: Row(
                children: [
                  _buildSmallAction(
                    icon: AppIcons.check,
                    label: l10n.approve,
                    color: AppColors.success,
                    onTap: () => _approvePost(post['id']),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallAction(
                    icon: AppIcons.close,
                    label: l10n.reject,
                    color: AppColors.error,
                    onTap: () => _rejectPost(post['id']),
                  ),
                ],
              ),
            ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
            ),
            child: Divider(
              height: 1,
              color: context.isDark
                  ? const Color(0xFF2E433C)
                  : const Color(0xFFE5E7EB),
            ),
          ),

          // ── Row 6: Action buttons ──
          Padding(
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
                  icon: isWarned ? AppIcons.shield : AppIcons.flag,
                  label: isWarned ? l10n.removeWarning : l10n.reportViolation,
                  color: isWarned ? AppColors.success : AppColors.warning,
                  onTap: isWarned
                      ? () => _unwarnPost(post['id'])
                      : () => _reportViolation(
                          post['id'], post['user_id'], post['content']),
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
          style: AppTypography.bodySecondary.copyWith(
            fontSize: 13,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionBold.copyWith(
                    fontSize: 12,
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

  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.captionBold.copyWith(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── REPORTS BOTTOM SHEET ─────────────────────────────────────────
  void _showReportsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: ctx.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flag_rounded, color: AppColors.error, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Báo cáo từ người dùng',
                            style: AppTypography.title.copyWith(
                              fontSize: 17,
                              color: ctx.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_pendingReportCount báo cáo đang chờ xử lý',
                            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: ctx.textSecondary, size: 22),
                      onPressed: () {
                        _loadReports();
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (_reports.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
                        const SizedBox(height: 12),
                        Text(
                          'Không có báo cáo nào',
                          style: AppTypography.title.copyWith(color: ctx.textPrimary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (_, i) => _buildReportCard(_reports[i], ctx),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, BuildContext sheetCtx) {
    final payload = report['payload'] as Map<String, dynamic>? ?? {};
    final post = report['post'] as Map<String, dynamic>?;
    final reporter = report['reporter'] as Map<String, dynamic>?;
    final reason = payload['reason'] as String? ?? 'Không rõ';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: sheetCtx.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                  backgroundImage: reporter?['avatar_url'] != null
                      ? NetworkImage(reporter!['avatar_url'] as String)
                      : null,
                  child: reporter?['avatar_url'] == null
                      ? const Icon(Icons.person_outline, color: AppColors.warning, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reporter?['name'] ?? 'Ai đó',
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          color: sheetCtx.textPrimary,
                        ),
                      ),
                      Text(
                        report['created_at'] != null
                            ? _formatTime(DateTime.parse(report['created_at']))
                            : '',
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Post author info
          if (post != null && post['author'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: post['author']?['avatar_url'] != null
                        ? NetworkImage(post['author']['avatar_url'] as String)
                        : null,
                    child: post['author']?['avatar_url'] == null
                        ? Text(
                            (post['author']?['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text('Bài của: ', style: AppTypography.caption.copyWith(fontSize: 12)),
                  Text(
                    post['author']?['name'] ?? 'Người dùng',
                    style: AppTypography.captionBold.copyWith(fontSize: 12, color: sheetCtx.textPrimary),
                  ),
                ],
              ),
            ),
          if (post != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sheetCtx.inputFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _truncateContent(post['content'] as String? ?? ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  _getReasonLabel(reason),
                  style: AppTypography.captionBold.copyWith(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (payload['description'] != null && (payload['description'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                payload['description'] as String,
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReport(report, 'dismiss', sheetCtx),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Bỏ qua'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: sheetCtx.isDark
                            ? const Color(0xFF2E433C)
                            : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReport(report, 'warn', sheetCtx),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text('Cảnh báo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── REPORT HANDLING ──────────────────────────────────────────────
  Future<void> _handleReport(Map<String, dynamic> report, String action, BuildContext sheetCtx) async {
    final l10n = AppLocalizations.of(context)!;
    final notifId = report['id'].toString();
    final token = _token;

    if (action == 'warn') {
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

      final post = report['post'] as Map<String, dynamic>?;
      final postContent = post?['content'] as String?;

      final result = await showModalBottomSheet<String>(
        context: sheetCtx,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setDialogState) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFD1D5DB),
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
                        child: const Icon(AppIcons.flag, color: AppColors.warning, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.warningViolation,
                        style: AppTypography.title.copyWith(
                          fontSize: 17,
                          color: ctx.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (postContent != null && postContent.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ctx.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        '"$postContent"',
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    l10n.selectViolationReason,
                    style: AppTypography.title.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...reasons.map((reason) => InkWell(
                    onTap: () => setDialogState(() {
                      selectedReason = reason;
                      customReasonController.clear();
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedReason == reason ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: selectedReason == reason ? AppColors.primary : ctx.textSecondary,
                                width: 2,
                              ),
                            ),
                            child: selectedReason == reason
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedReason == reason ? ctx.textPrimary : ctx.textSecondary,
                                fontWeight: selectedReason == reason ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  if (selectedReason == l10n.otherReason) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonController,
                      decoration: InputDecoration(hintText: l10n.enterReason, isDense: true),
                      maxLines: 2,
                      onChanged: (_) => setDialogState(() {}),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(
                              color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(l10n.cancel, style: TextStyle(color: ctx.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedReason != null && (selectedReason != l10n.otherReason || customReasonController.text.trim().isNotEmpty)
                              ? () {
                                  String? finalReason;
                                  if (selectedReason == l10n.otherReason) {
                                    finalReason = customReasonController.text.trim();
                                  } else {
                                    finalReason = selectedReason;
                                  }
                                  Navigator.pop(ctx, finalReason);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(l10n.sendWarning, style: const TextStyle(fontWeight: FontWeight.bold)),
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

      customReasonController.dispose();
      if (result == null || result.isEmpty) return;
      await ApiService.handleReport(token, notifId, action: 'warn', warnReason: result);
    } else {
      final confirm = await showDialog<bool>(
        context: sheetCtx,
        builder: (ctx) => AlertDialog(
          backgroundColor: ctx.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Bỏ qua báo cáo', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc muốn bỏ qua báo cáo này? Bài viết sẽ không bị ảnh hưởng.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Hủy', style: TextStyle(color: ctx.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Bỏ qua'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await ApiService.handleReport(token, notifId, action: 'dismiss');
    }
    if (!sheetCtx.mounted) return;
    Navigator.pop(sheetCtx);
    _loadReports();
    if (!mounted) return;
    final isWarn = action == 'warn';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                isWarn ? l10n.warningSent : 'Đã bỏ qua báo cáo',
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                isWarn ? 'Cảnh báo đã được gửi đến người dùng.' : 'Báo cáo đã được bỏ qua.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.gotIt, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── UTILITY ──────────────────────────────────────────────────────
  String _truncateContent(String text) {
    if (text.length <= 150) return text;
    return '${text.substring(0, 150)}...';
  }

  String _getReasonLabel(String key) {
    const labels = {
      'violentContent': 'Nội dung bạo lực',
      'spamContent': 'Spam',
      'hateSpeech': 'Ngôn từ thù địch',
      'misinformation': 'Thông tin sai lệch',
      'adultContent': 'Nội dung người lớn',
      'copyrightViolation': 'Vi phạm bản quyền',
      'otherReason': 'Lý do khác',
    };
    return labels[key] ?? key;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
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

  // ─── POST ACTIONS ─────────────────────────────────────────────────
  Future<void> _viewPostDetails(Map<String, dynamic> postData) async {
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
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
      }
    }
  }

  Future<void> _approvePost(int postId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ApiService.approvePost(_token, postId.toString());
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.postApproved);
      }
      _loadPosts();
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
      }
    }
  }

  Future<void> _rejectPost(int postId) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rejectPost),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.rejectPostMessage, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.rejectReason,
                hintText: l10n.rejectReasonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.deletePost),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty || !mounted) return;

    try {
      await ApiService.rejectPost(_token, postId.toString(), reason);
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.postRejectedDeleted);
      }
      _loadPosts();
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
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
        AppNotificationDialog.show(
          context,
          type: NotificationType.success,
          title: l10n.postDeleted,
          content: 'Bài viết đã được xóa khỏi hệ thống.',
        );
      }
      _loadPosts();
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
      }
    }
  }

  Future<void> _unwarnPost(int postId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        icon: AppIcons.shield,
        iconColor: AppColors.success,
        iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
        title: l10n.removeWarning,
        content: l10n.removeWarningConfirm,
        cancelText: l10n.cancel,
        confirmText: l10n.removeWarning,
        confirmColor: AppColors.success,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiService.unwarnPost(_token, postId.toString());
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.postWarningRemoved);
      }
      _loadPosts();
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
      }
    }
  }

  Future<void> _reportViolation(int postId, dynamic userId, String? content) async {
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFD1D5DB),
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
                      child: const Icon(AppIcons.flag, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.warningViolation,
                      style: AppTypography.title.copyWith(
                        fontSize: 17,
                        color: ctx.textPrimary,
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
                      color: ctx.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      '"$content"',
                      maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.selectViolationReason,
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...reasons.map((reason) => InkWell(
                  onTap: () => setDialogState(() {
                    selectedReason = reason;
                    customReasonController.clear();
                  }),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedReason == reason ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: selectedReason == reason ? AppColors.primary : ctx.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: selectedReason == reason
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedReason == reason ? ctx.textPrimary : ctx.textSecondary,
                              fontWeight: selectedReason == reason ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                if (selectedReason == l10n.otherReason) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customReasonController,
                    decoration: InputDecoration(hintText: l10n.enterReason, isDense: true),
                    maxLines: 2,
                    onChanged: (_) => setDialogState(() {}),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                            color: ctx.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(l10n.cancel, style: TextStyle(color: ctx.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedReason != null &&
                                (selectedReason != l10n.otherReason || customReasonController.text.trim().isNotEmpty)
                            ? () {
                                String? finalReason;
                                if (selectedReason == l10n.otherReason) {
                                  finalReason = customReasonController.text.trim();
                                } else {
                                  finalReason = selectedReason;
                                }
                                Navigator.pop(ctx, finalReason);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.sendWarning, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        AppNotificationDialog.show(
          context,
          type: NotificationType.success,
          title: l10n.warningSent,
          content: 'Cảnh báo đã được gửi đến người dùng.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.failed, content: '$e');
      }
    }
  }
}
