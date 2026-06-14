import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../services/onboarding_gate.dart';
import '../data/starter_habit_templates.dart';
import '../l10n/app_localizations.dart';
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
  final int _totalPages = 6;

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
  List<Map<String, dynamic>> goalOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {"id": "eat_healthy", "label": l10n.goalEatHealthy, "icon": "🥗", "color": 0xFFE8F5E9},
      {"id": "exercise",    "label": l10n.goalExercise,   "icon": "🏃", "color": 0xFFE3F2FD},
      {"id": "sleep",       "label": l10n.goalSleep,      "icon": "😴", "color": 0xFFEDE7F6},
      {"id": "mental",      "label": l10n.goalMental,     "icon": "🧘", "color": 0xFFFFF8E1},
      {"id": "weight",      "label": l10n.goalWeight,     "icon": "⚖️", "color": 0xFFFCE4EC},
      {"id": "hydration",   "label": l10n.goalHydration,  "icon": "💧", "color": 0xFFE0F7FA},
      {"id": "other",       "label": l10n.goalOther,      "icon": "✏️", "color": 0xFFF3E5F5},
    ];
  }
  final Set<String> selectedGoals = {};
  final customGoalController = TextEditingController();

  // Step 5 - Starter habits
  List<StarterHabitOption> _starterOptions = [];
  final Set<String> _selectedStarterIds = {};

  // Step 6 - Plant
  String selectedPlant = "bamboo";
  List<Map<String, dynamic>> get plantOptions {
    final l10n = AppLocalizations.of(context)!;
    return [
      {"id": "bamboo",  "emoji": "🎋", "name": l10n.plantBamboo,   "desc": l10n.plantDescBamboo},
      {"id": "cactus",  "emoji": "🌵", "name": l10n.plantCactus,  "desc": l10n.plantDescCactus},
      {"id": "flower",  "emoji": "🌸", "name": l10n.plantFlower, "desc": l10n.plantDescFlower},
      {"id": "sunflower","emoji": "🌻","name": l10n.plantSunflower, "desc": l10n.plantDescSunflower},
    ];
  }

  // Validation errors
  String? birthYearError;
  String? heightError;
  String? weightError;

  bool isLoading = false;

  // Validation helpers
  String? _validateBirthYear(String v, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final year = int.tryParse(v.trim());
    if (v.trim().isEmpty) return null;
    if (year == null) return l10n.invalidBirthYear;
    if (year < 1930) return l10n.birthYearBefore1930;
    if (year > currentYear - 10) return l10n.mustBeAtLeast10;
    return null;
  }

  String? _validateHeight(String v, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (v.trim().isEmpty) return null;
    final h = double.tryParse(v.trim());
    if (h == null) return l10n.invalidHeight;
    if (h < 100) return l10n.heightMin;
    if (h > 250) return l10n.heightMax;
    return null;
  }

  String? _validateWeight(String v, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (v.trim().isEmpty) return null;
    final w = double.tryParse(v.trim());
    if (w == null) return l10n.invalidWeight;
    if (w < 15) return l10n.weightMin;
    if (w > 300) return l10n.weightMax;
    return null;
  }

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

  void _syncStarterHabitsFromGoals() {
    final l10n = AppLocalizations.of(context)!;
    final customText = selectedGoals.contains('other')
        ? customGoalController.text.trim()
        : null;
    final options = StarterHabitTemplates.forGoals(
      selectedGoals,
      l10n,
      customGoalText: customText,
    );
    _starterOptions = options;
    _selectedStarterIds
      ..clear()
      ..addAll(options.take(3).map((o) => o.id));
  }

  void nextPage() {
    if (_currentPage == 3) {
      _syncStarterHabitsFromGoals();
    }
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
    final token = prefs.getString("token") ?? "";
    final profile = await ApiService.getProfile(token);
    final userId = profile["user"]?["id"]?.toString() ?? "";
    await OnboardingGate.markComplete(userId);
    await FlowPrefs.setProfileIncomplete(true);
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

    final profile = await ApiService.getProfile(token);
    final userId = profile["user"]?["id"]?.toString() ?? "";
    await OnboardingGate.markComplete(userId);

    var habitsCreated = 0;
    for (final opt in _starterOptions) {
      if (!_selectedStarterIds.contains(opt.id)) continue;
      final res = await ApiService.createHabit(
        token: token,
        name: opt.name,
        category: opt.category,
        icon: opt.icon,
      );
      if (res['habit'] != null) habitsCreated++;
    }

    if (habitsCreated == 0) {
      await FlowPrefs.markPendingFirstHabitNudge();
    } else {
      await FlowPrefs.markOpenHabitsAfterOnboarding();
      await FlowPrefs.markOnboardingHabitsReady();
      await FlowPrefs.startPostCheckinCoachFlow();
    }

    await prefs.setString("plant_type", selectedPlant);

    // Sync plant type lên backend
    await ApiService.setPlantType(token, selectedPlant);

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
        if (birthYearError != null) return false;
        return selectedBirthYear != null ||
            (birthYearController.text.trim().isNotEmpty &&
                int.tryParse(birthYearController.text.trim()) != null);
      case 2:
        return heightError == null && weightError == null;
      case 3:
        if (selectedGoals.isEmpty) return false;
        if (selectedGoals.contains("other") &&
            customGoalController.text.trim().isEmpty) return false;
        return true;
      case 4:
        return _selectedStarterIds.isNotEmpty;
      case 5:
        return true;
      default:
        return true;
    }
  }

  // Page configs — soft green palette
  static const List<Map<String, dynamic>> _pageConfigs = [
    {"gradient": [0xFF2E7D32, 0xFF388E3C, 0xFF81C784]}, // xanh lá đậm → nhạt
    {"gradient": [0xFF1B5E20, 0xFF2E7D32, 0xFFA5D6A7]}, // forest green
    {"gradient": [0xFF33691E, 0xFF558B2F, 0xFFAED581]}, // olive green
    {"gradient": [0xFF00695C, 0xFF00897B, 0xFF80CBC4]}, // teal xanh lá
    {"gradient": [0xFF1B5E20, 0xFF43A047, 0xFFC8E6C9]}, // mint xanh nhạt
    {"gradient": [0xFF2E7D32, 0xFF66BB6A, 0xFFB9F6CA]}, // starter habits
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
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
                    _buildStarterHabitsPage(),
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
                                ? l10n.startJourney
                                : l10n.next,
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
    final l10n = AppLocalizations.of(context)!;
    final genders = [
      {"id": "male",   "label": l10n.male,  "icon": "👨", "color": 0xFFE3F2FD},
      {"id": "female", "label": l10n.female, "icon": "👩", "color": 0xFFFCE4EC},
      {"id": "other",  "label": l10n.other, "icon": "🧑", "color": 0xFFF3E5F5},
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingWhoAreYou,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.onboardingPersonalize,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final suggestedYears = List.generate(7, (i) => currentYear - 15 - i * 5);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingBirthYear,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.onboardingAgeRecommendation,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                    final error = _validateBirthYear(v, context);
                    final year = int.tryParse(v.trim());
                    setState(() {
                      birthYearError = error;
                      selectedBirthYear = (error == null && year != null) ? year : null;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.enterBirthYear,
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF2E7D32)),
                    errorText: birthYearError,
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFF1F8E9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.quickSelect,
                    style: const TextStyle(fontSize: 13, color: Colors.grey,
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingBodyStats,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.onboardingOptionalLater,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBodyField(
                  controller: heightController,
                  label: l10n.heightLabel,
                  hint: l10n.heightExample,
                  suffix: l10n.unitCm,
                  icon: Icons.height,
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFF1F8E9),
                  errorText: heightError,
                  onChanged: (v) => setState(() => heightError = _validateHeight(v, context)),
                ),
                const SizedBox(height: 20),
                _buildBodyField(
                  controller: weightController,
                  label: l10n.weightLabel,
                  hint: l10n.weightExample,
                  suffix: l10n.unitKg,
                  icon: Icons.monitor_weight_outlined,
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFF1F8E9),
                  errorText: weightError,
                  onChanged: (v) => setState(() => weightError = _validateWeight(v, context)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.bmiInfo,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20)),
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
    String? errorText,
    ValueChanged<String>? onChanged,
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: color),
            suffixText: suffix,
            suffixStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
            errorText: errorText,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ===== PAGE 4: GOALS =====
  Widget _buildGoalsPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingYourGoals,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.onboardingSelectGoals,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                  children: goalOptions(context).map((g) {
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
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.whatIsYourGoal,
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

  // ===== PAGE 5: STARTER HABITS =====
  Widget _buildStarterHabitsPage() {
    final l10n = AppLocalizations.of(context)!;
    if (_starterOptions.isEmpty) {
      _syncStarterHabitsFromGoals();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStarterHabitsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingStarterHabitsSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingStarterHabitsHint,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ..._starterOptions.map((opt) {
                  final isSelected = _selectedStarterIds.contains(opt.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => setState(() {
                          if (isSelected) {
                            if (_selectedStarterIds.length > 1) {
                              _selectedStarterIds.remove(opt.id);
                            }
                          } else {
                            _selectedStarterIds.add(opt.id);
                          }
                        }),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Text(opt.icon,
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade400,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ===== PAGE 6: PLANT =====
  Widget _buildPlantPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingChoosePlant + " 🌿",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(l10n.onboardingPlantGrowWithHabits,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
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
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(p["name"] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF00695C)
                                      : Colors.black87,
                                )),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(p["desc"] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
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
                  child: Row(
                    children: [
                      const Text("💡", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.onboardingPlantTip,
                          style: const TextStyle(
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
    [Color(0x22A5D6A7), Color(0x3381C784), Color(0x1AFFFFFF)],
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
