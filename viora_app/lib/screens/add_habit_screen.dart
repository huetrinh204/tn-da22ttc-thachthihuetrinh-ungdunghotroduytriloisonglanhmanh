import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_extensions.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'hydration';
  String _selectedIcon = '💧';
  double _dailyGoal = 2000;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.addNewHabit,
          style: const TextStyle(
            color: Color(0xFF1E352F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  color: Color(0xFF0F623F),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildNameSection(l10n),
          const SizedBox(height: 16),
          _buildCategorySection(l10n),
          const SizedBox(height: 16),
          _buildIconSection(l10n),
          const SizedBox(height: 16),
          _buildDailyGoalSection(l10n),
          const SizedBox(height: 16),
          _buildReminderSection(l10n),
          const SizedBox(height: 16),
          _buildMotivationalQuote(l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNameSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitName.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E8A85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1E352F)),
            decoration: InputDecoration(
              hintText: l10n.habitNameExample,
              hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF4F6F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    final categories = [
      {'id': 'eat', 'label': l10n.categoryEat, 'icon': LucideIcons.utensils},
      {'id': 'exercise', 'label': l10n.categoryExercise, 'icon': LucideIcons.dumbbell},
      {'id': 'sleep', 'label': l10n.categorySleep, 'icon': LucideIcons.moon},
      {'id': 'mental', 'label': l10n.categoryMental, 'icon': LucideIcons.flower2},
      {'id': 'hydration', 'label': l10n.categoryHydration, 'icon': LucideIcons.droplet},
      {'id': 'other', 'label': l10n.categoryOther, 'icon': LucideIcons.moreHorizontal},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addHabitCategory,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E8A85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat['id'];
              Widget iconWidget = Icon(
                cat['icon'] as IconData,
                color: isSelected ? Colors.white : const Color(0xFF0F623F),
                size: 24,
              );
              if (cat['id'] == 'exercise') {
                iconWidget = Transform.rotate(angle: -0.5, child: iconWidget);
              }
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = cat['id'] as String;
                  switch (cat['id']) {
                    case 'hydration':
                      _selectedIcon = '💧';
                      _dailyGoal = _dailyGoal.clamp(100, 5000);
                      break;
                    case 'eat':
                      _selectedIcon = '🍴';
                      _dailyGoal = _dailyGoal.clamp(100, 5000);
                      break;
                    case 'exercise':
                    case 'sleep':
                    case 'mental':
                      _selectedIcon = cat['id'] == 'exercise' ? '🏃' : (cat['id'] == 'sleep' ? '😴' : '🧘');
                      _dailyGoal = _dailyGoal.clamp(5, 480);
                      break;
                    default:
                      _selectedIcon = '⭐';
                      _dailyGoal = _dailyGoal.clamp(1, 10);
                  }
                }),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0F623F), width: 1.5)
                        : null,
                  ),
                  padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F623F) : const Color(0xFFF4F6F4),
                      borderRadius: isSelected ? BorderRadius.circular(13) : BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconWidget,
                        const SizedBox(height: 8),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF0F623F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSection(AppLocalizations l10n) {
    final iconOptions = [
      {'emoji': '💧', 'icon': LucideIcons.droplet},
      {'emoji': '🌿', 'icon': LucideIcons.leaf},
      {'emoji': '❤️', 'icon': LucideIcons.heart},
      {'emoji': '🏃', 'icon': LucideIcons.activity},
      {'emoji': '🧘', 'icon': LucideIcons.flower2},
      {'emoji': '🍴', 'icon': LucideIcons.utensils},
      {'emoji': '😴', 'icon': LucideIcons.moon},
      {'emoji': '📖', 'icon': LucideIcons.bookOpen},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addHabitIcon,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E8A85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: iconOptions.map((item) {
              final emoji = item['emoji'] as String;
              final iconData = item['icon'] as IconData;
              final isSelected = _selectedIcon == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = emoji),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: const Color(0xFF0F623F), width: 1.5)
                        : null,
                  ),
                  padding: isSelected ? const EdgeInsets.all(3) : EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF0F623F) : const Color(0xFFF4F6F4),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: isSelected ? Colors.white : const Color(0xFF0F623F),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalSection(AppLocalizations l10n) {
    String unit;
    double minVal;
    double maxVal;
    int divisions;

    if (_selectedCategory == 'hydration') {
      unit = l10n.unitMl;
      minVal = 100; maxVal = 5000; divisions = 49;
    } else if (_selectedCategory == 'exercise' || _selectedCategory == 'mental' || _selectedCategory == 'sleep') {
      unit = l10n.addHabitUnitMinutes;
      minVal = 5; maxVal = 480; divisions = 95;
    } else if (_selectedCategory == 'eat') {
      unit = l10n.addHabitUnitCalories;
      minVal = 100; maxVal = 5000; divisions = 49;
    } else {
      unit = l10n.addHabitUnitTimes;
      minVal = 1; maxVal = 10; divisions = 9;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.addHabitDailyGoal,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7E8A85),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB1E5CD), width: 1.5),
                ),
                child: Text(
                  '${_dailyGoal.toInt()} $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F623F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFB1E5CD),
              inactiveTrackColor: const Color(0xFFE5ECE8),
              thumbColor: const Color(0xFF0F623F),
              overlayColor: const Color(0xFF0F623F).withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 6,
            ),
            child: Slider(
              value: _dailyGoal.clamp(minVal, maxVal),
              min: minVal,
              max: maxVal,
              divisions: divisions,
              onChanged: (value) => setState(() => _dailyGoal = value),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Min: ${minVal.toInt()}$unit',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7E8A85))),
              Text('Max: ${maxVal.toInt()}$unit',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7E8A85))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(AppLocalizations l10n) {
    final hour = _reminderTime.hour;
    final minute = _reminderTime.minute;
    final isAM = hour < 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isAM ? 'AM' : 'PM';
    final timeStr = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addHabitReminder,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E8A85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.addHabitReminderLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF1E352F),
                  ),
                ),
              ),
              InkWell(
                onTap: _reminderEnabled
                    ? () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF0F623F),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (time != null) setState(() => _reminderTime = time);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _reminderEnabled ? const Color(0xFFF4F6F4) : const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDE3DE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _reminderEnabled ? const Color(0xFF0F623F) : const Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: _reminderEnabled ? const Color(0xFF0F623F) : const Color(0xFFAAAAAA),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF0F623F),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCCCCCC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F623F),
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addHabitQuote,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.addHabitQuoteAuthor,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFB1E5CD),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _saveHabit() {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addHabitEnterName),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'icon': _selectedIcon,
      'daily_goal': _dailyGoal,
      'reminder_enabled': _reminderEnabled,
      'reminder_time': '${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}',
    });
  }
}
