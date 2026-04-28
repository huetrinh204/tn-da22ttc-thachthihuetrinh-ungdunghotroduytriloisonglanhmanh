import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  AnimationController? _bubbleController;

  // Step 1 - Gender
  String? selectedGender;

  // Step 2 - Birth year
  int? selectedBirthYear;
  final birthYearController = TextEditingController();

  // Step 3 - Body
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Step 4 - Goals
  final List<Map<String, dynamic>> goalOptions = [
    {"id": "eat_healthy", "label": "Ăn lành mạnh", "icon": "🥗", "color": 0xFFE8F5E9},
    {"id": "exercise",    "label": "Vận động",       "icon": "🏃", "color": 0xFFE3F2FD},
    {"id": "sleep",       "label": "Giấc ngủ",       "icon": "😴", "color": 0xFFEDE7F6},
    {"id": "mental",      "label": "Tinh thần",      "icon": "🧘", "color": 0xFFFFF8E1},
    {"id": "weight",      "label": "Cân nặng",       "icon": "⚖️", "color": 0xFFFCE4EC},
    {"id": "hydration",   "label": "Uống nước",      "icon": "💧", "color": 0xFFE0F7FA},
    {"id": "other",       "label": "Khác",           "icon": "✏️", "color": 0xFFF3E5F5},
  ];
  final Set<String> selectedGoals = {};
  final customGoalController = TextEditingController();

  // Step 5 - Plant
  String selectedPlant = "sprout";
  final List<Map<String, dynamic>> plantOptions = [
    {"id": "sprout",  "emoji": "🌱", "name": "Mầm xanh",   "desc": "Nhỏ bé nhưng đầy tiềm năng"},
    {"id": "cactus",  "emoji": "🌵", "name": "Xương rồng",  "desc": "Kiên cường, không bỏ cuộc"},
    {"id": "bonsai",  "emoji": "🌳", "name": "Bonsai",      "desc": "Kiên nhẫn, từng bước vững chắc"},
    {"id": "flower",  "emoji": "🌸", "name": "Hoa anh đào", "desc": "Tươi sáng và tràn đầy năng lượng"},
    {"id": "bamboo",  "emoji": "🎋", "name": "Tre xanh",    "desc": "Dẻo dai, bền bỉ mỗi ngày"},
    {"id": "sunflower","emoji": "🌻","name": "Hướng dương", "desc": "Luôn hướng về phía ánh sáng"},
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bubbleController?.dispose();
    _pageController.dispose();
    heightController.dispose();
    weightController.dispose();
    birthYearController.dispose();
    customGoalController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      handleFinish();
    }
  }

  void prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void handleSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void handleFinish() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final goals = selectedGoals.toList();
    if (goals.contains("other") && customGoalController.text.trim().isNotEmpty) {
      goals.remove("other");
      goals.add("other:${customGoalController.text.trim()}");
    }

    await ApiService.updateProfile(
      token: token,
      gender: selectedGender,
      birthYear: selectedBirthYear,
      height: double.tryParse(heightController.text),
      weight: double.tryParse(weightController.text),
      goals: goals,
    );

    await prefs.setBool("onboarding_done", true);
    await prefs.setString("plant_type", selectedPlant);

    setState(() => isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  bool canProceed() {
    switch (_currentPage) {
      case 0: return selectedGender != null;
      case 1:
        return selectedBirthYear != null ||
            (birthYearController.text.trim().isNotEmpty &&
                int.tryParse(birthYearController.text.trim()) != null);
      case 2: return true;
      case 3: return selectedGoals.isNotEmpty;
      case 4: return true;
      default: return true;
    }
  }

  // Page configs — soft green palette
  static const List<Map<String, dynamic>> _pageConfigs = [
    {"gradient": [0xFF2E7D32, 0xFF388E3C, 0xFF81C784]}, // xanh lá đậm → nhạt
    {"gradient": [0xFF1B5E20, 0xFF2E7D32, 0xFFA5D6A7]}, // forest green
    {"gradient": [0xFF33691E, 0xFF558B2F, 0xFFAED581]}, // olive green
    {"gradient": [0xFF00695C, 0xFF00897B, 0xFF80CBC4]}, // teal xanh lá
    {"gradient": [0xFF1B5E20, 0xFF43A047, 0xFFC8E6C9]}, // mint xanh nhạt
  ];

  @override
  Widget build(BuildContext context) {
    final config = _pageConfigs[_currentPage];
    final gradColors = (config["gradient"] as List<int>)
        .map((c) => Color(c))
        .toList();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradColors,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated bubbles background
            if (_bubbleController != null)
              AnimatedBuilder(
                animation: _bubbleController!,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _BubblePainter(_bubbleController!.value, _currentPage),
                    size: Size.infinite,
                  );
                },
              ),
            SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back / empty
                    _currentPage > 0
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                            onPressed: prevPage,
                          )
                        : const SizedBox(width: 48),

                    // Step indicator
                    Text(
                      "${_currentPage + 1} / $_totalPages",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Skip
                    TextButton(
                      onPressed: handleSkip,
                      child: const Text(
                        "Bỏ qua",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _totalPages,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 4,
                  ),
                ),
              ),

              // PAGE CONTENT
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildGenderPage(),
                    _buildBirthYearPage(),
                    _buildBodyPage(),
                    _buildGoalsPage(),
                    _buildPlantPage(),
                  ],
                ),
              ),

              // NEXT BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: canProceed() && !isLoading ? nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(_pageConfigs[_currentPage]["gradient"][0]),
                      disabledBackgroundColor: Colors.white30,
                      disabledForegroundColor: Colors.white54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(_pageConfigs[_currentPage]["gradient"][0]),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _currentPage == _totalPages - 1
                                ? "Bắt đầu hành trình 🌱"
                                : "Tiếp theo →",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  // ===== SHARED CARD WRAPPER =====
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ===== PAGE 1: GENDER =====
  Widget _buildGenderPage() {
    final genders = [
      {"id": "male",   "label": "Nam",  "icon": "👨", "color": 0xFFE3F2FD},
      {"id": "female", "label": "Nữ",   "icon": "👩", "color": 0xFFFCE4EC},
      {"id": "other",  "label": "Khác", "icon": "🧑", "color": 0xFFF3E5F5},
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("Bạn là?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Giúp chúng tôi cá nhân hóa cho bạn",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: genders.map((g) {
                final isSelected = selectedGender == g["id"];
                return GestureDetector(
                  onTap: () => setState(() => selectedGender = g["id"] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(g["color"] as int)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF43A047)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(g["icon"] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Text(g["label"] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.black87,
                            )),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF43A047), size: 24),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAGE 2: BIRTH YEAR =====
  Widget _buildBirthYearPage() {
    final currentYear = DateTime.now().year;
    final suggestedYears = List.generate(7, (i) => currentYear - 15 - i * 5);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("Năm sinh?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Để gợi ý phù hợp với độ tuổi của bạn",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: birthYearController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: (v) {
                    final year = int.tryParse(v);
                    setState(() => selectedBirthYear =
                        (year != null && year >= 1924 && year <= currentYear - 5)
                            ? year
                            : null);
                  },
                  decoration: InputDecoration(
                    hintText: "Nhập năm sinh (VD: 1995)",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF1E88E5)),
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFF0F7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Chọn nhanh:",
                    style: TextStyle(fontSize: 13, color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: suggestedYears.map((year) {
                    final isSelected = selectedBirthYear == year;
                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedBirthYear = year;
                        birthYearController.text = "$year";
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE3F2FD)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1E88E5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text("$year",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : Colors.black87,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAGE 3: HEIGHT & WEIGHT =====
  Widget _buildBodyPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("Thông số cơ thể",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Không bắt buộc — có thể cập nhật sau",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBodyField(
                  controller: heightController,
                  label: "Chiều cao",
                  hint: "Ví dụ: 165",
                  suffix: "cm",
                  icon: Icons.height,
                  color: const Color(0xFF8E24AA),
                  bgColor: const Color(0xFFF3E5F5),
                ),
                const SizedBox(height: 20),
                _buildBodyField(
                  controller: weightController,
                  label: "Cân nặng",
                  hint: "Ví dụ: 55",
                  suffix: "kg",
                  icon: Icons.monitor_weight_outlined,
                  color: const Color(0xFF8E24AA),
                  bgColor: const Color(0xFFF3E5F5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF8E24AA), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Thông tin này giúp tính BMI và gợi ý thói quen phù hợp hơn.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: color),
            suffixText: suffix,
            suffixStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ===== PAGE 4: GOALS =====
  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("Mục tiêu của bạn?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Chọn một hoặc nhiều mục tiêu",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: goalOptions.map((g) {
                    final isSelected = selectedGoals.contains(g["id"]);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          selectedGoals.remove(g["id"]);
                        } else {
                          selectedGoals.add(g["id"] as String);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(g["color"] as int)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE53935)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(g["icon"] as String,
                                style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 8),
                            Text(g["label"] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFC62828)
                                      : Colors.black87,
                                )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedGoals.contains("other")) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: customGoalController,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: "Mục tiêu của bạn là gì?",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.edit_outlined,
                          color: Color(0xFFE53935)),
                      filled: true,
                      fillColor: const Color(0xFFFFF8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE53935), width: 1.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ===== PAGE 5: PLANT =====
  Widget _buildPlantPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("Chọn cây của bạn 🌿",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Cây sẽ lớn lên cùng thói quen của bạn",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: plantOptions.map((p) {
                    final isSelected = selectedPlant == p["id"];
                    return GestureDetector(
                      onTap: () => setState(() => selectedPlant = p["id"] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00897B)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p["emoji"] as String,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 6),
                            Text(p["name"] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF00695C)
                                      : Colors.black87,
                                )),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(p["desc"] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text("💡", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Hoàn thành thói quen mỗi ngày để cây phát triển và mở khóa thành tích mới!",
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ===== BUBBLE BACKGROUND PAINTER =====
class _BubblePainter extends CustomPainter {
  final double animValue;
  final int pageIndex;

  _BubblePainter(this.animValue, this.pageIndex);

  static const List<List<Color>> _bubbleColors = [
    [Color(0x22A5D6A7), Color(0x33C8E6C9), Color(0x1AFFFFFF)],
    [Color(0x22A5D6A7), Color(0x2281C784), Color(0x1AFFFFFF)],
    [Color(0x22AED581), Color(0x33C5E1A5), Color(0x1AFFFFFF)],
    [Color(0x2280CBC4), Color(0x33B2DFDB), Color(0x1AFFFFFF)],
    [Color(0x22C8E6C9), Color(0x33DCEDC8), Color(0x1AFFFFFF)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _bubbleColors[pageIndex % _bubbleColors.length];

    final bubbles = [
      // x%, y% base, radius, color index, speed multiplier
      [0.1, 0.8, 80.0, 0, 1.0],
      [0.85, 0.7, 60.0, 1, 0.7],
      [0.5, 0.9, 100.0, 2, 0.5],
      [0.2, 0.3, 50.0, 0, 1.2],
      [0.75, 0.15, 70.0, 1, 0.9],
      [0.9, 0.45, 45.0, 2, 1.1],
    ];

    for (final b in bubbles) {
      final x = (b[0] as double) * size.width;
      final baseY = (b[1] as double) * size.height;
      final r = b[2] as double;
      final colorIdx = (b[3] as double).toInt();
      final speed = b[4] as double;

      // Float up and down
      final dy = (animValue * 2 - 1) * 20 * speed;
      final center = Offset(x, baseY + dy);

      final paint = Paint()
        ..color = colors[colorIdx % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, r, paint);

      // Inner highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(center.dx - r * 0.25, center.dy - r * 0.25), r * 0.4,
          highlightPaint);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.animValue != animValue || old.pageIndex != pageIndex;
}
