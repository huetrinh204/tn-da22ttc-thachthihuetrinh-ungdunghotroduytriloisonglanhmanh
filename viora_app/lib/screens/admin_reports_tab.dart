import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _token = token;

    final res = await ApiService.getReports(token);
    if (!mounted) return;
    setState(() {
      _reports = res['reports'] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _handleReport(Map<String, dynamic> report, String action) async {
    final token = _token ?? '';
    final notifId = report['id'].toString();

    if (action == 'warn') {
      final reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ctx.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cảnh báo bài viết',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nhập lý do cảnh báo...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: TextStyle(color: ctx.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy', style: TextStyle(color: ctx.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'Đã xác nhận vi phạm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Gửi cảnh báo'),
            ),
          ],
        ),
      );

      if (reason == null) return;

      final res = await ApiService.handleReport(token, notifId, action: 'warn', warnReason: reason);
      if (!mounted) return;
      if (res['message'] != null) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: 'Đã gửi cảnh báo');
        _load();
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ctx.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Bỏ qua báo cáo',
              style: TextStyle(fontWeight: FontWeight.bold)),
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

      final res = await ApiService.handleReport(token, notifId, action: 'dismiss');
      if (!mounted) return;
      if (res['message'] != null) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: 'Đã bỏ qua báo cáo');
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_outlined, size: 64, color: context.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('Không có báo cáo nào',
                          style: TextStyle(fontSize: 16, color: context.textSecondary)),
                      const SizedBox(height: 8),
                      Text('Các báo cáo từ người dùng sẽ xuất hiện ở đây',
                          style: TextStyle(fontSize: 13, color: context.textSecondary.withValues(alpha: 0.7))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (_, i) => _buildReportCard(_reports[i]),
                  ),
                ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final payload = report['payload'] as Map<String, dynamic>? ?? {};
    final post = report['post'] as Map<String, dynamic>?;
    final reporter = report['reporter'] as Map<String, dynamic>?;
    final reason = payload['reason'] as String? ?? 'Không rõ';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: reporter?['avatar_url'] != null
                      ? ClipOval(child: Image.network(reporter!['avatar_url'], width: 36, height: 36, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag_outlined, color: AppColors.warning, size: 20)))
                      : const Icon(Icons.flag_outlined, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Báo cáo từ ${reporter?['name'] ?? 'Ai đó'}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(DateTime.parse(report['created_at'])),
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Mới', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Post content
          if (post != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Author avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: post['author']?['avatar_url'] != null
                        ? ClipOval(child: Image.network(post['author']['avatar_url'], fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(child: Text(
                              (post['author']?['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ))))
                        : Center(child: Text(
                            (post['author']?['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          )),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author']?['name'] ?? 'Người dùng',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
                      ),
                      Text('Người đăng bài', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _truncateContent(post['content'] as String? ?? ''),
                      style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4),
                    ),
                    if (post['image_url'] != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post['image_url'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Reporter info
            if (reporter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: reporter['avatar_url'] != null
                          ? ClipOval(child: Image.network(reporter['avatar_url'], fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(child: Text(
                                (reporter['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(color: AppColors.warning, fontSize: 12),
                              ))))
                          : Center(child: Text(
                              (reporter['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.warning, fontSize: 12),
                            )),
                    ),
                    const SizedBox(width: 8),
                    Text('Báo cáo bởi: ', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    Text(reporter['name'] ?? 'Ai đó', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                  ],
                ),
              ),
          ],

          // Reason
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  'Lý do: ${_getReasonLabel(reason)}',
                  style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          if (payload['description'] != null && (payload['description'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                payload['description'] as String,
                style: TextStyle(fontSize: 13, color: context.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleReport(report, 'dismiss'),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Bỏ qua'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReport(report, 'warn'),
                    icon: const Icon(Icons.warning_amber, size: 18),
                    label: const Text('Cảnh báo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
