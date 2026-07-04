import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';

class ReportReasonSheet extends StatefulWidget {
  final void Function(String reason, String description) onReport;

  const ReportReasonSheet({super.key, required this.onReport});

  @override
  State<ReportReasonSheet> createState() => _ReportReasonSheetState();
}

class _ReportReasonSheetState extends State<ReportReasonSheet> {
  String? _selectedReason;
  final _descController = TextEditingController();
  bool _isSubmitting = false;

  static const List<Map<String, String>> _reasons = [
    {"key": "violentContent", "label": "Nội dung bạo lực"},
    {"key": "spamContent", "label": "Spam"},
    {"key": "hateSpeech", "label": "Ngôn từ thù địch"},
    {"key": "misinformation", "label": "Thông tin sai lệch"},
    {"key": "adultContent", "label": "Nội dung người lớn"},
    {"key": "otherReason", "label": "Lý do khác"},
  ];

  @override
  void initState() {
    super.initState();
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.flag_outlined, color: AppColors.warning, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Báo cáo bài viết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn lý do báo cáo bài viết này.',
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
            const SizedBox(height: 16),
            ...List.generate(_reasons.length, (i) {
              final r = _reasons[i];
              return RadioListTile<String>(
                value: r["key"]!,
                groupValue: _selectedReason,
                title: Text(r["label"]!, style: TextStyle(fontSize: 14, color: context.textPrimary)),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (v) => setState(() => _selectedReason = v),
              );
            }),
            if (_selectedReason == 'otherReason') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Mô tả chi tiết (tuỳ chọn)',
                  hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.infoBoxBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: TextStyle(color: context.textPrimary, fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null && !_isSubmitting
                    && (_selectedReason != 'otherReason' || _descController.text.trim().isNotEmpty)
                    ? () {
                        setState(() => _isSubmitting = true);
                        final desc = _selectedReason == 'otherReason' ? _descController.text.trim() : '';
                        widget.onReport(_selectedReason!, desc);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Gửi báo cáo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy', style: TextStyle(color: context.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
