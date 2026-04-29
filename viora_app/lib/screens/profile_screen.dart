import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';
import 'achievements_screen.dart';
import 'notification_settings_screen.dart';

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
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    // Không xóa onboarding_done — giữ lại để lần sau login không phải onboard lại
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showEditNameSheet() {
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
            const Text("Đổi tên",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: _inputDeco("Họ và tên", Icons.person_outline),
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
                    AppSnackbar.showSuccess(context, "Đã cập nhật tên");
                  } else {
                    AppSnackbar.showError(context, res["message"] ?? "Thất bại");
                  }
                },
                style: _btnStyle(),
                child: const Text("Lưu"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBodySheet() {
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
              const Text("Thông số cơ thể",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: hCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final h = double.tryParse(v);
                  setSheet(() => hError = (h == null || h < 100 || h > 250)
                      ? "Chiều cao từ 100–250 cm"
                      : null);
                },
                decoration: _inputDeco("Chiều cao (cm)", Icons.height,
                    suffixText: "cm", error: hError),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: wCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final w = double.tryParse(v);
                  setSheet(() => wError = (w == null || w < 15 || w > 300)
                      ? "Cân nặng từ 15–300 kg"
                      : null);
                },
                decoration: _inputDeco("Cân nặng (kg)", Icons.monitor_weight_outlined,
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
                          AppSnackbar.showSuccess(context, "Đã cập nhật thông số");
                        },
                  style: _btnStyle(),
                  child: const Text("Lưu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGoalsSheet() {
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
              const Text("Mục tiêu cá nhân",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        "${g["icon"]} ${g["label"]}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSel
                              ? const Color(0xFF2E7D32)
                              : Colors.black87,
                        ),
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
                    AppSnackbar.showSuccess(context, "Đã cập nhật mục tiêu");
                  },
                  style: _btnStyle(),
                  child: const Text("Lưu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
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
              const Text("Đổi mật khẩu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: curCtrl,
                obscureText: obscureCur,
                decoration: _inputDeco("Mật khẩu hiện tại", Icons.lock_outline,
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
                decoration: _inputDeco("Mật khẩu mới", Icons.lock_outline,
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
                decoration: _inputDeco("Xác nhận mật khẩu mới", Icons.lock_outline,
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
                      AppSnackbar.showError(context, "Mật khẩu xác nhận không khớp");
                      return;
                    }
                    if (newCtrl.text.length < 8) {
                      AppSnackbar.showError(context, "Mật khẩu tối thiểu 8 ký tự");
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
                      AppSnackbar.showSuccess(context, "Đổi mật khẩu thành công");
                    } else {
                      AppSnackbar.showError(context, res["message"] ?? "Thất bại");
                    }
                  },
                  style: _btnStyle(),
                  child: const Text("Đổi mật khẩu"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Hồ sơ",
            style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar + name
                _buildAvatarCard(),
                const SizedBox(height: 16),

                // Personal info
                _buildSection("Thông tin cá nhân", [
                  _buildTile("Họ và tên", name, Icons.person_outline,
                      onTap: _showEditNameSheet),
                  _buildTile("Email", email, Icons.email_outlined),
                  _buildTile(
                      "Giới tính",
                      gender == "male"
                          ? "Nam"
                          : gender == "female"
                              ? "Nữ"
                              : gender ?? "Chưa cập nhật",
                      Icons.wc),
                  _buildTile(
                      "Năm sinh",
                      birthYear?.toString() ?? "Chưa cập nhật",
                      Icons.cake_outlined),
                ]),
                const SizedBox(height: 16),

                // Body stats
                _buildSection("Thông số cơ thể", [
                  _buildTile(
                      "Chiều cao",
                      height != null
                          ? "${height!.toStringAsFixed(1)} cm"
                          : "Chưa cập nhật",
                      Icons.height,
                      onTap: _showEditBodySheet),
                  _buildTile(
                      "Cân nặng",
                      weight != null
                          ? "${weight!.toStringAsFixed(1)} kg"
                          : "Chưa cập nhật",
                      Icons.monitor_weight_outlined,
                      onTap: _showEditBodySheet),
                  if (height != null && weight != null)
                    _buildBmiTile(),
                ]),
                const SizedBox(height: 16),

                // Goals
                _buildSection("Mục tiêu cá nhân", [
                  _buildGoalsTile(),
                ]),
                const SizedBox(height: 16),

                // Security
                _buildSection("Bảo mật", [
                  _buildTile("Đổi mật khẩu", "Cập nhật mật khẩu",
                      Icons.lock_outline,
                      onTap: _showChangePasswordSheet),
                ]),
                const SizedBox(height: 16),

                // Achievements
                _buildSection("Thành tích", [
                  _buildTile("Thành tích của tôi", "Xem các thành tích đã mở khóa",
                      Icons.emoji_events_outlined,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AchievementsScreen()),
                          )),
                ]),
                const SizedBox(height: 16),

                // Notifications
                _buildSection("Thông báo", [
                  _buildTile("Nhắc nhở thói quen", "Cài đặt giờ nhắc hàng ngày",
                      Icons.notifications_outlined,
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationSettingsScreen()),
                          )),
                ]),
                const SizedBox(height: 16),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Đăng xuất",
                        style: TextStyle(color: Colors.red, fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50), size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildBmiTile() {
    final bmi = weight! / ((height! / 100) * (height! / 100));
    String category;
    Color color;
    if (bmi < 18.5) {
      category = "Thiếu cân";
      color = Colors.blue;
    } else if (bmi < 25) {
      category = "Bình thường";
      color = const Color(0xFF4CAF50);
    } else if (bmi < 30) {
      category = "Thừa cân";
      color = Colors.orange;
    } else {
      category = "Béo phì";
      color = Colors.red;
    }

    return ListTile(
      leading: const Icon(Icons.calculate_outlined,
          color: Color(0xFF4CAF50), size: 22),
      title: const Text("BMI",
          style: TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Row(
        children: [
          Text(bmi.toStringAsFixed(1),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
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
    final activeGoals = goalOptions
        .where((g) => goals.contains(g["id"]))
        .toList();

    return ListTile(
      leading: const Icon(Icons.flag_outlined,
          color: Color(0xFF4CAF50), size: 22),
      title: const Text("Mục tiêu",
          style: TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: activeGoals.isEmpty
          ? const Text("Chưa chọn mục tiêu",
              style: TextStyle(fontSize: 15, color: Colors.black87))
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: activeGoals
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${g["icon"]} ${g["label"]}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E7D32)),
                        ),
                      ))
                  .toList(),
            ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: _showEditGoalsSheet,
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon,
      {String? suffixText, String? error, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      suffixText: suffixText,
      suffixIcon: suffix,
      errorText: error,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
}
