import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/post.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../constants/app_icons.dart';
import '../l10n/app_localizations.dart';

class CreatePostScreen extends StatefulWidget {
  final Post? existingPost;
  final String? initialContent;
  final String? initialImageUrl;
  final List<String>? initialHashtags;
  final String postType;

  const CreatePostScreen({
    super.key,
    this.existingPost,
    this.initialContent,
    this.initialImageUrl,
    this.initialHashtags,
    this.postType = 'normal',
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final TextEditingController _contentController;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isPosting = false;

  bool get _isEditing => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingPost?.content ?? widget.initialContent ?? '',
    );
    _existingImageUrl = widget.existingPost?.imageUrl ?? widget.initialImageUrl;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _publishPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty && _selectedImage == null && _existingImageUrl == null) {
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.warning,
          title: AppLocalizations.of(context)!.shareYourThoughts,
        );
      }
      return;
    }

    setState(() => _isPosting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    String? imageUrl = _existingImageUrl;

    if (_selectedImage != null) {
      final uploadResponse = await ApiService.uploadImage(token, _selectedImage!.path);
      if (uploadResponse["url"] != null) {
        imageUrl = uploadResponse["url"];
      }
    }

    final hashtags = <String>[];
    final hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(content);
    for (final match in matches) {
      hashtags.add(match.group(0)!);
    }

    final Map<String, dynamic> response;
    if (_isEditing) {
      response = await ApiService.updatePost(
        token: token,
        postId: widget.existingPost!.id,
        content: content,
        imageUrl: imageUrl,
        hashtags: hashtags.isNotEmpty ? hashtags : null,
      );
    } else {
      response = await ApiService.createPost(
        token: token,
        content: content,
        imageUrl: imageUrl,
        hashtags: hashtags.isNotEmpty ? hashtags : null,
        postType: widget.postType,
      );
    }

    if (!mounted) return;

    setState(() => _isPosting = false);

    if (response["message"] == null || response["post"] != null) {
      if (mounted) {
        await AppNotificationDialog.show(
          context,
          type: NotificationType.success,
          title: _isEditing ? 'Đã cập nhật bài viết' : AppLocalizations.of(context)!.postCreated,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } else {
      final msg = response["message"] as String? ?? "Failed";
      final hint = msg == "Network error"
          ? "Không kết nối được server.\nKiểm tra backend (npm run dev) và IP trong api_service.dart"
          : msg;
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.error,
          title: 'Đăng bài thất bại',
          content: hint,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: _isEditing ? 'Chỉnh sửa bài viết' : l10n.createPost,
        showBack: true,
        actions: [
          if (_isPosting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _publishPost,
              child: Text(
                _isEditing ? 'Lưu' : l10n.publish,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing && widget.existingPost!.isWarned)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.shield, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bài viết của bạn đã bị cảnh báo vi phạm. Sau khi chỉnh sửa, quản trị viên sẽ xem xét và gỡ cảnh báo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: l10n.shareYourThoughts,
                hintStyle: TextStyle(
                  color: context.textSecondary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                filled: false,
              ),
            ),

            const SizedBox(height: 16),

            if (_selectedImage != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (_existingImageUrl != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _existingImageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedImage == null && _existingImageUrl == null)
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.infoBoxBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addPhoto,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.photo,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
