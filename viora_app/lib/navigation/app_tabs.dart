/// Chỉ số tab bottom navigation (4 tab).
abstract final class AppTabs {
  static const int today = 0; // merged: Today + Habits
  static const int community = 1;
  static const int grow = 2;
  static const int me = 3;

  /// Chuẩn hoá index — pass-through vì callers đều dùng AppTabs constants.
  static int normalize(int index) {
    if (index < 0) return today;
    if (index > me) return me;
    return index;
  }
}
