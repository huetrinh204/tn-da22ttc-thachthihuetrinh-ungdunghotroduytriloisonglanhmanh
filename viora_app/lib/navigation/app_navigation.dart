import 'app_tabs.dart';

/// Điều hướng toàn app (đổi tab, mở từ notification).
class AppNavigation {
  static void Function(int tabIndex)? onSwitchTab;

  static void switchToTab(int index) {
    onSwitchTab?.call(AppTabs.normalize(index));
  }

  static void openToday() => switchToTab(AppTabs.today);
  static void openHabits() => switchToTab(AppTabs.habits);
  static void openCommunity() => switchToTab(AppTabs.community);
  static void openGrow() => switchToTab(AppTabs.grow);
  static void openMe() => switchToTab(AppTabs.me);
  static void openAiChat() => switchToTab(AppTabs.aiChat);

  /// Tương thích code cũ gọi [openPlant].
  static void openPlant() => openGrow();

  /// Tương thích code cũ gọi [openProfile].
  static void openProfile() => openMe();
}
