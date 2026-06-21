import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_tabs.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../screens/habits_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/user_profile_screen.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void Function(int tabIndex)? onSwitchTab;

  static void switchToTab(int index) {
    onSwitchTab?.call(AppTabs.normalize(index));
  }

  static void openToday() => switchToTab(AppTabs.today);
  static void openHabits() => navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const HabitsScreen()),
  );
  static void openCommunity() => switchToTab(AppTabs.community);
  static void openGrow() => switchToTab(AppTabs.grow);
  static void openMe() => switchToTab(AppTabs.me);
  static void openAiChat() => navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const AiChatScreen()),
  );

  static void openPlant() => openGrow();
  static void openProfile() => openMe();

  static void openPostDetail(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    if (token.isEmpty) return;

    final response = await ApiService.getPostById(token, postId);
    final postJson = response["post"];
    if (postJson == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: Post.fromJson(postJson as Map<String, dynamic>),
        ),
      ),
    );
  }

  static void openUserProfile(String userId, String userName) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  static void handleFcmDeepLink(Map<String, String> data) {
    final type = data['type'];
    final postId = data['post_id'];
    final userId = data['user_id'];
    final userName = data['user_name'];

    if (postId != null && (type == 'like' || type == 'comment' || type == 'warning')) {
      openCommunity();
      openPostDetail(postId);
    } else if (type == 'follow' && userId != null) {
      openCommunity();
      openUserProfile(userId, userName ?? 'User');
    } else {
      openCommunity();
    }
  }
}
