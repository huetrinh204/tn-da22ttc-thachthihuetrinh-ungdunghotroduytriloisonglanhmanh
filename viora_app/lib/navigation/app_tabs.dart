/// Chỉ số tab bottom navigation (6 tab).
abstract final class AppTabs {
  static const int today = 0;
  static const int habits = 1;
  static const int community = 2;
  static const int grow = 3;
  static const int me = 4;
  static const int aiChat = 5;

  /// Ánh xạ chỉ số tab cũ (6 tab) sang cấu trúc mới.
  static int normalize(int index) {
    switch (index) {
      case 2:
        return grow; // Plant
      case 3:
        return community;
      case 4:
        return me; // Stats
      case 5:
        return aiChat;
      case 6:
        return me; // Profile
      default:
        if (index < 0) return today;
        if (index > aiChat) return aiChat;
        return index;
    }
  }
}
