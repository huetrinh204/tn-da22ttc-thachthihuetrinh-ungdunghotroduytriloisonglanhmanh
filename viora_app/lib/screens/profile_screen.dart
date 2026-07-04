import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/app_notification_dialog.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'admin_home_screen.dart';
import 'login_screen.dart';
import 'achievements_screen.dart';
import 'stats_screen.dart';
import 'forgot_password_screen.dart';
import 'followers_list_screen.dart';
import 'user_profile_screen.dart';
import '../providers/locale_provider.dart';
import '../utils/habit_icon_mapper.dart';
import '../services/notification_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String token = "";

  // User data
  String name = "";
  String email = "";
  String? gender;
  int? birthYear;
  double? height;
  double? weight;
  List<String> goals = [];
  String? avatarUrl;
  bool _isUploadingAvatar = false;
  String? role; // admin or user
  
  // Community stats
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;
  String? _currentUserId;

  final List<Map<String, dynamic>> goalOptions = [
    {"id": "eat_healthy", "label": "Ăn lành mạnh", "icon": "🥗"},
    {"id": "exercise",    "label": "Vận động",      "icon": "🏃"},
    {"id": "sleep",       "label": "Giấc ngủ",      "icon": "😴"},
    {"id": "mental",      "label": "Tinh thần",     "icon": "🧘"},
    {"id": "weight",      "label": "Cân nặng",      "icon": "⚖️"},
    {"id": "hydration",   "label": "Uống nước",     "icon": "💧"},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    final res = await ApiService.getProfile(token);
    if (!mounted) return;
    setState(() {
      final user = res["user"] ?? {};
      name = user["name"] ?? "";
      email = user["email"] ?? "";
      gender = user["gender"];
      birthYear = user["birth_year"];
      avatarUrl = user["avatar_url"] as String?;
      _currentUserId = user["id"]?.toString();
      role = user["role"] as String?;
      height = user["height"] != null
          ? double.tryParse(user["height"].toString())
          : null;
      weight = user["weight"] != null
          ? double.tryParse(user["weight"].toString())
          : null;
      final rawGoals = user["goals"];
      if (rawGoals is List) {
        goals = rawGoals.map((g) => g.toString()).toList();
      }
      isLoading = false;
    });
    
    // Load community stats
    if (_currentUserId != null) {
      _loadCommunityStats();
    }
  }
  
  Future<void> _loadCommunityStats() async {
    if (_currentUserId == null) return;
    final profileRes = await ApiService.getUserProfile(token, _currentUserId!);
    if (!mounted) return;
    if (profileRes["user"] != null) {
      setState(() {
        _followersCount = profileRes["user"]["follower_count"] as int? ?? 0;
        _followingCount = profileRes["user"]["following_count"] as int? ?? 0;
        _postsCount = profileRes["user"]["post_count"] as int? ?? 0;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _isUploadingAvatar = true);
    final res = await ApiService.uploadAvatar(token, picked.path);
    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);
    if (res['avatar_url'] != null) {
      setState(() => avatarUrl = res['avatar_url'] as String);
      AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.avatarUpdated);
    } else {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.avatarUpdateFailed);
    }
  }

  void _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.logout,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ctx.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.logoutConfirm,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ctx.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ctx.textSecondary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(l10n.no, style: TextStyle(color: ctx.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(l10n.yes, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirmed != true) return;
    
    await NotificationService.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token != null) {
      await ApiService.clearFcmToken(token);
    }
    await prefs.remove("token");
    // Không xóa onboarding_done — giữ lại để lần sau login không phải onboard lại
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showEditNameSheet() {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: _inputDeco(l10n.fullName, Icons.person_outline),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final res = await ApiService.updateProfile(
                    token: token,
                    name: ctrl.text.trim(),
                  );
                  if (!mounted) return;
                  if (res["message"] == "Profile updated") {
                    setState(() => name = ctrl.text.trim());
                    AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.nameUpdated);
                  } else {
                    AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.failed);
                  }
                },
                style: _btnStyle(),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBodySheet() {
    final l10n = AppLocalizations.of(context)!;
    final hCtrl = TextEditingController(
        text: height != null ? height!.toStringAsFixed(1) : "");
    final wCtrl = TextEditingController(
        text: weight != null ? weight!.toStringAsFixed(1) : "");
    String? hError, wError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.bodyStatsTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: hCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final h = double.tryParse(v);
                  setSheet(() => hError = (h == null || h < 100 || h > 250)
                      ? l10n.heightRange
                      : null);
                },
                decoration: _inputDeco(l10n.height, Icons.height,
                    suffixText: "cm", error: hError),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: wCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final w = double.tryParse(v);
                  setSheet(() => wError = (w == null || w < 15 || w > 300)
                      ? l10n.weightRange
                      : null);
                },
                decoration: _inputDeco(l10n.weight, Icons.monitor_weight_outlined,
                    suffixText: "kg", error: wError),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: hError != null || wError != null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final h = double.tryParse(hCtrl.text);
                          final w = double.tryParse(wCtrl.text);
                          await ApiService.updateProfile(
                              token: token, gender: gender,
                              birthYear: birthYear, height: h,
                              weight: w, goals: goals);
                          setState(() { height = h; weight = w; });
                          if (!mounted) return;
                          AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.statsUpdated);
                        },
                  style: _btnStyle(),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGoalsSheet() {
    final l10n = AppLocalizations.of(context)!;
    final selected = Set<String>.from(goals);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.personalGoals,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: goalOptions.map((g) {
                  final isSel = selected.contains(g["id"]);
                  return GestureDetector(
                    onTap: () => setSheet(() {
                      if (isSel) selected.remove(g["id"]);
                      else selected.add(g["id"] as String);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primaryLight
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            HabitIconMapper.getIconData(g["icon"]),
                            size: 14,
                            color: isSel
                                ? AppColors.primaryDark
                                : Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            g["label"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSel
                                  ? AppColors.primaryDark
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ApiService.updateProfile(
                        token: token, gender: gender,
                        birthYear: birthYear, height: height,
                        weight: weight, goals: selected.toList());
                    setState(() => goals = selected.toList());
                    if (!mounted) return;
                    AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.goalsUpdated);
                  },
                  style: _btnStyle(),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final l10n = AppLocalizations.of(context)!;
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final cfCtrl = TextEditingController();
    bool obscureCur = true, obscureNew = true, obscureCf = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.changePassword,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // Link quên mật khẩu
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  l10n.forgotPassword,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: curCtrl,
                obscureText: obscureCur,
                decoration: _inputDeco(l10n.currentPassword, Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(obscureCur
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          color: Colors.grey, size: 20),
                      onPressed: () => setSheet(() => obscureCur = !obscureCur),
                    )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: obscureNew,
                decoration: _inputDeco(l10n.newPassword, Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          color: Colors.grey, size: 20),
                      onPressed: () => setSheet(() => obscureNew = !obscureNew),
                    )),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cfCtrl,
                obscureText: obscureCf,
                decoration: _inputDeco(l10n.confirmPassword, Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(obscureCf
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          color: Colors.grey, size: 20),
                      onPressed: () => setSheet(() => obscureCf = !obscureCf),
                    )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (newCtrl.text != cfCtrl.text) {
                      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.passwordMismatch);
                      return;
                    }
                    if (newCtrl.text.length < 8) {
                      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.passwordTooShort);
                      return;
                    }
                    Navigator.pop(ctx);
                    final res = await ApiService.updatePassword(
                      token: token,
                      currentPassword: curCtrl.text,
                      newPassword: newCtrl.text,
                    );
                    if (!mounted) return;
                    if (res["message"] == "Password updated") {
                      AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.passwordUpdated);
                    } else {
                      AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.failed);
                    }
                  },
                  style: _btnStyle(),
                  child: Text(l10n.changePassword),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(title: l10n.profile),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar + name
                _buildAvatarCard(),
                const SizedBox(height: 16),
                
                // Community stats (Followers, Following, Posts)
                if (_currentUserId != null) ...[
                  _buildCommunityStatsCard(),
                  const SizedBox(height: 16),

                  // Shortcut xem trang cá nhân
                  _buildSection(l10n.profile, [
                    _buildTile(
                      l10n.viewProfile,
                      l10n.viewProfileInCommunity,
                      Icons.account_circle_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(
                              userId: _currentUserId!,
                              userName: name,
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Personal info
                _buildSection(l10n.personalInfo, [
                  _buildTile(l10n.fullName, name, Icons.person_outline,
                      onTap: _showEditNameSheet),
                  _buildTile(l10n.email, email, Icons.email_outlined),
                  _buildTile(
                      l10n.gender,
                      gender == "male"
                          ? l10n.male
                          : gender == "female"
                              ? l10n.female
                              : gender ?? l10n.notUpdated,
                      Icons.wc),
                  _buildTile(
                      l10n.birthYear,
                      birthYear?.toString() ?? l10n.notUpdated,
                      Icons.cake_outlined),
                ]),
                const SizedBox(height: 16),

                // Body stats
                _buildSection(l10n.bodyStats, [
                  _buildTile(
                      l10n.height,
                      height != null
                          ? "${height!.toStringAsFixed(1)} cm"
                          : l10n.notUpdated,
                      Icons.height,
                      onTap: _showEditBodySheet),
                  _buildTile(
                      l10n.weight,
                      weight != null
                          ? "${weight!.toStringAsFixed(1)} kg"
                          : l10n.notUpdated,
                      Icons.monitor_weight_outlined,
                      onTap: _showEditBodySheet),
                  if (height != null && weight != null)
                    _buildBmiTile(),
                ]),
                const SizedBox(height: 16),

                // Goals
                _buildSection(l10n.personalGoals, [
                  _buildGoalsTile(),
                ]),
                const SizedBox(height: 16),

                // Security
                _buildSection(l10n.security, [
                  _buildTile(l10n.changePassword, l10n.updatePassword,
                      Icons.lock_outline,
                      onTap: _showChangePasswordSheet),
                ]),
                const SizedBox(height: 16),

                // Insights / Statistics (moved from bottom tab)
                _buildSection(l10n.insights, [
                  _buildTile(
                    l10n.statsTitle,
                    l10n.viewInsights,
                    Icons.bar_chart_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatsScreen(),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Achievements
                _buildSection(l10n.achievements, [
                  _buildTile(l10n.myAchievements, l10n.viewUnlockedAchievements,
                      Icons.emoji_events_outlined,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AchievementsScreen()),
                          )),
                ]),
                const SizedBox(height: 16),

                // Giao diện
                _buildSection(l10n.appearance, [
                  _buildThemeToggleTile(),
                  _buildLanguageTile(),
                ]),
                const SizedBox(height: 24),

                // Admin Panel (only for admin)
                if (role == 'admin') ...[
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminHomeScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.admin_panel_settings, 
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Logout
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.isDark 
                        ? Colors.red.shade900.withValues(alpha: 0.2)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.isDark 
                          ? Colors.red.shade700
                          : Colors.red.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleLogout,
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, 
                              color: context.isDark 
                                  ? Colors.red.shade400
                                  : Colors.red.shade700,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.logout,
                            style: TextStyle(
                              color: context.isDark 
                                  ? Colors.red.shade400
                                  : Colors.red.shade700,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildThemeToggleTile() {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            isDark ? l10n.darkMode : l10n.lightMode,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: context.textPrimary),
          ),
          subtitle: Text(
            isDark ? l10n.usingDarkMode : l10n.usingLightMode,
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (val) {
              themeNotifier.value =
                  val ? ThemeMode.dark : ThemeMode.light;
            },
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile() {
    final localeProvider = LocaleProvider.global;
    
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final languageCode = localeProvider.locale.languageCode;
        final isVietnamese = languageCode == 'vi';
        
        return ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            l10n.language,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: context.textPrimary),
          ),
          subtitle: Text(
            isVietnamese ? l10n.vietnamese : l10n.english,
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVietnamese ? "🇻🇳 VI" : "🇬🇧 EN",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
          onTap: () => _showLanguageSheet(languageCode),
        );
      },
    );
  }

  void _showLanguageSheet(String currentLanguageCode) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.global;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Vietnamese option
            _buildLanguageOption(
              context: ctx,
              flag: "🇻🇳",
              language: l10n.vietnamese,
              code: "Vietnamese",
              isSelected: currentLanguageCode == 'vi',
              onTap: () async {
                await localeProvider.setLocale(const Locale('vi'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.languageChanged);
              },
            ),
            
            const SizedBox(height: 12),
            
            // English option
            _buildLanguageOption(
              context: ctx,
              flag: "🇬🇧",
              language: l10n.english,
              code: "English",
              isSelected: currentLanguageCode == 'en',
              onTap: () async {
                await localeProvider.setLocale(const Locale('en'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.languageChangedEn);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String language,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : this.context.textPrimary,
                      ),
                    ),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 13,
                        color: this.context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF00845F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar — tappable to upload
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                  ),
                  child: _isUploadingAvatar
                      ? const Center(
                          child: SizedBox(
                            width: 28, height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white,
                            ),
                          ),
                        )
                      : avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                                ),
                              ),
                            ),
                ),
                // Camera badge
                if (!_isUploadingAvatar)
                                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  l10n.tapToChangeAvatar,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(label,
          style: TextStyle(fontSize: 13, color: context.textSecondary)),
      subtitle: Text(value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.textPrimary)),
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded, color: context.textSecondary, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildBmiTile() {
    final l10n = AppLocalizations.of(context)!;
    final bmi = weight! / ((height! / 100) * (height! / 100));
    String category;
    Color color;
    if (bmi < 18.5) {
      category = l10n.underweight;
      color = Colors.blue;
    } else if (bmi < 25) {
      category = l10n.normal;
      color = AppColors.primary;
    } else if (bmi < 30) {
      category = l10n.overweight;
      color = AppColors.warning;
    } else {
      category = l10n.obese;
      color = AppColors.error;
    }

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 18),
      ),
      title: Text(l10n.bmi,
          style: TextStyle(fontSize: 13, color: context.textSecondary)),
      subtitle: Row(
        children: [
          Text(bmi.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(category,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTile() {
    final l10n = AppLocalizations.of(context)!;
    final activeGoals = goalOptions
        .where((g) => goals.contains(g["id"]))
        .toList();

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.target, color: AppColors.primary, size: 18),
      ),
      title: Text(l10n.goals,
          style: TextStyle(fontSize: 13, color: context.textSecondary)),
      subtitle: activeGoals.isEmpty
          ? Text(l10n.noGoalsSelected,
              style: TextStyle(fontSize: 15, color: context.textPrimary))
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: activeGoals
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              HabitIconMapper.getIconData(g["icon"]),
                              size: 12,
                              color: AppColors.primaryDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              g["label"],
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
      trailing: Icon(Icons.chevron_right_rounded, color: context.textSecondary, size: 20),
      onTap: _showEditGoalsSheet,
    );
  }

  Widget _buildCommunityStatsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            count: _postsCount.toString(),
            label: l10n.posts,
            onTap: null, // Không cần navigate, chỉ hiển thị
          ),
          Container(
            width: 1,
            height: 40,
            color: context.infoBoxBorder,
          ),
          _buildStatItem(
            count: _followersCount.toString(),
            label: l10n.followers,
            onTap: () {
              if (_currentUserId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FollowersListScreen(
                    userId: _currentUserId!,
                    userName: name,
                    type: 'followers',
                  ),
                ),
              );
            },
          ),
          Container(
            width: 1,
            height: 40,
            color: context.infoBoxBorder,
          ),
          _buildStatItem(
            count: _followingCount.toString(),
            label: l10n.following,
            onTap: () {
              if (_currentUserId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FollowersListScreen(
                    userId: _currentUserId!,
                    userName: name,
                    type: 'following',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String count,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: onTap != null
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon,
      {String? suffixText, String? error, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixText: suffixText,
      suffixIcon: suffix,
      errorText: error,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
}
