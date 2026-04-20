import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  String? selectedGender;

  // Step 2
  int? selectedBirthYear;

  // Step 3
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Step 4
  final List<Map<String, dynamic>> goalOptions = [
    {"id": "eat_healthy", "label": "Ăn uống lành mạnh", "icon": "🥗"},
    {"id": "exercise", "label": "Vận động thường xuyên", "icon": "🏃"},
    {"id": "sleep", "label": "Cải thiện giấc ngủ", "icon": "😴"},
    {"id": "mental", "label": "Sức khỏe tinh thần", "icon": "🧘"},
    {"id": "weight", "label": "Kiểm soát cân nặng", "icon": "⚖️"},
    {"id": "hydration", "label": "Uống đủ nước", "icon": "💧"},
  ];
  final Set<String> selectedGoals = {};

  bool isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      handleFinish();
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

    await ApiService.updateProfile(
      token: token,
      gender: selectedGender,
      birthYear: selectedBirthYear,
      height: double.tryParse(heightController.text),
      weight: double.tryParse(weightController.text),
      goals: selectedGoals.toList(),
    );

    await prefs.setBool("onboarding_done", true);

    setState(() => isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  bool canProceed() {
    switch (_currentPage) {
      case 0:
        return selectedGender != null;
      case 1:
        return selectedBirthYear != null;
      case 2:
        return true; // optional
      case 3:
        return selectedGoals.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress dots
                  Row(
                    children: List.generate(4, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  TextButton(
                    onPressed: handleSkip,
                    child: const Text(
                      "Bỏ qua",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // PAGES
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
                ],
              ),
            ),

            // BOTTOM BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canProceed() && !isLoading ? nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _currentPage == 3 ? "Bắt đầu thôi! 🌱" : "Tiếp theo",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PAGE 1: GENDER =====
  Widget _buildGenderPage() {
    final genders = [
      {"id": "male", "label": "Nam", "icon": "👨"},
      {"id": "female", "label": "Nữ", "icon": "👩"},
      {"id": "other", "label": "Khác", "icon": "🧑"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Bạn là?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Giúp chúng tôi cá nhân hóa trải nghiệm cho bạn",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 40),
          ...genders.map((g) => GestureDetector(
                onTap: () => setState(() => selectedGender = g["id"]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedGender == g["id"]
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedGender == g["id"]
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(g["icon"]!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Text(g["label"]!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: selectedGender == g["id"]
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          )),
                      const Spacer(),
                      if (selectedGender == g["id"])
                        const Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 22),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ===== PAGE 2: BIRTH YEAR =====
  Widget _buildBirthYearPage() {
    final currentYear = DateTime.now().year;
    final years = List.generate(83, (i) => currentYear - 7 - i);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Năm sinh của bạn?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Để gợi ý phù hợp với độ tuổi của bạn",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (_, i) {
                final year = years[i];
                final isSelected = selectedBirthYear == year;
                return GestureDetector(
                  onTap: () => setState(() => selectedBirthYear = year),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$year",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.black87,
                            )),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF4CAF50), size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAGE 3: HEIGHT & WEIGHT =====
  Widget _buildBodyPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Thông số cơ thể",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Không bắt buộc — có thể cập nhật sau",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 40),

          // HEIGHT
          const Text("Chiều cao (cm)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Ví dụ: 165",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.height, color: Colors.grey),
              suffixText: "cm",
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // WEIGHT
          const Text("Cân nặng (kg)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Ví dụ: 55",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Colors.grey),
              suffixText: "kg",
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAGE 4: GOALS =====
  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text("Mục tiêu của bạn?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Chọn một hoặc nhiều mục tiêu",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: goalOptions.map((g) {
                final isSelected = selectedGoals.contains(g["id"]);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      selectedGoals.remove(g["id"]);
                    } else {
                      selectedGoals.add(g["id"]);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g["icon"]!, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          g["label"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          ),
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
}
