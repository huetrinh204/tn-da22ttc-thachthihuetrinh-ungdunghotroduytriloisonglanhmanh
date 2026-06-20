import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // true = điện thoại thật, false = máy ảo (emulator)
  static const bool _isPhysicalDevice = false;

  static const String baseUrl = _isPhysicalDevice
      ? "http://192.168.1.5:3000"
      : "http://10.0.2.2:3000";

  // Helper method to resolve image URLs
  static String resolveImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }

  // ================= GET PROFILE ====Uu=============
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= GET STREAK =================
  static Future<Map<String, dynamic>> getStreak(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/habits/streak"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {"message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {"message": data["message"] ?? "Register failed"};
      }
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= SAVE NOTIFICATION SETTINGS =================
  static Future<void> saveNotificationSettings({
    required String token,
    required bool morningEnabled,
    required int morningHour,
    required int morningMinute,
    required bool eveningEnabled,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/auth/notification-settings"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "morning_enabled": morningEnabled ? 1 : 0,
          "morning_hour": morningHour,
          "morning_minute": morningMinute,
          "evening_enabled": eveningEnabled ? 1 : 0,
          "evening_hour": eveningHour,
          "evening_minute": eveningMinute,
        }),
      );
    } catch (_) {}
  }

  // ================= SAVE FCM TOKEN =================
  static Future<void> saveFcmToken(String token, String fcmToken) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/auth/fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"fcm_token": fcmToken}),
      );
    } catch (_) {}
  }

  // ================= FORGOT PASSWORD =================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": code,
          "new_password": newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? gender,
    int? birthYear,
    double? height,
    double? weight,
    List<String>? goals,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body["name"] = name;
      if (gender != null) body["gender"] = gender;
      if (birthYear != null) body["birth_year"] = birthYear;
      if (height != null) body["height"] = height;
      if (weight != null) body["weight"] = weight;
      if (goals != null) body["goals"] = goals;

      final response = await http.put(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Update failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= GOOGLE LOGIN =================
  static Future<Map<String, dynamic>> googleLogin(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Google login failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= GET TODAY HABITS =================
  static Future<Map<String, dynamic>> getTodayHabits(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/habits/today"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= CREATE HABIT =================
  static Future<Map<String, dynamic>> createHabit({
    required String token,
    required String name,
    String category = "other",
    String icon = "⭐",
    String color = "#4CAF50",
    int? targetCount,
    String? reminderTime,
    bool reminderEnabled = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/habits"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "category": category,
          "icon": icon,
          "color": color,
          if (targetCount != null) "target_count": targetCount,
          if (reminderTime != null) "reminder_time": reminderTime,
          "reminder_enabled": reminderEnabled,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }


  // ================= GET ACHIEVEMENTS =================
  static Future<Map<String, dynamic>> getAchievements(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/habits/achievements"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"achievements": []};
    } catch (e) {
      return {"achievements": []};
    }
  }

  // ================= CHECK-IN HABIT =================
  static Future<Map<String, dynamic>> checkInHabit(
      String token, 
      int habitId, 
      {double? metricValue, 
      String? metricUnit}) async {
    try {
      final body = <String, dynamic>{};
      if (metricValue != null) body["metric_value"] = metricValue;
      if (metricUnit != null) body["metric_unit"] = metricUnit;

      final response = await http.post(
        Uri.parse("$baseUrl/habits/$habitId/checkin"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= STATS =================
  static Future<Map<String, dynamic>> getWeeklyStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/weekly"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"data": []};
    } catch (e) {
      return {"data": []};
    }
  }

  static Future<Map<String, dynamic>> getMonthlyStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/monthly"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"data": []};
    } catch (e) {
      return {"data": []};
    }
  }

  static Future<Map<String, dynamic>> getCategoryStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/categories"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"data": []};
    } catch (e) {
      return {"data": []};
    }
  }

  static Future<Map<String, dynamic>> getStatsSummary(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/summary"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"summary": {}};
    } catch (e) {
      return {"summary": {}};
    }
  }

  // ================= HABIT METRICS =================
  static Future<Map<String, dynamic>> getHabitMetrics(
      String token, int habitId, {int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/habits/$habitId/metrics?days=$days"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"metrics": [], "summary": {}};
    } catch (e) {
      return {"metrics": [], "summary": {}};
    }
  }

  static Future<Map<String, dynamic>> getHabitsOverview(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stats/habits/overview"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"habits": []};
    } catch (e) {
      return {"habits": []};
    }
  }

  // ================= UPDATE PASSWORD =================
  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "current_password": currentPassword,
          "new_password": newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= SET PLANT TYPE =================
  static Future<void> setPlantType(String token, String plantType) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/habits/plant/type"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"plant_type": plantType}),
      );
    } catch (_) {}
  }

  // ================= GET PLANT =================
  static Future<Map<String, dynamic>> getPlant(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/habits/plant"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= UPDATE HABIT =================
  static Future<Map<String, dynamic>> updateHabit({
    required String token,
    required int habitId,
    required String name,
    String category = "other",
    String icon = "⭐",
    String color = "#4CAF50",
    int? targetCount,
    String? reminderTime,
    bool reminderEnabled = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/habits/$habitId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "category": category,
          "icon": icon,
          "color": color,
          if (targetCount != null) "target_count": targetCount,
          "reminder_time": reminderEnabled ? reminderTime : null,
          "reminder_enabled": reminderEnabled,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= DELETE HABIT =================
  static Future<Map<String, dynamic>> deleteHabit(
      String token, int habitId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/habits/$habitId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET POSTS =================
  static Future<Map<String, dynamic>> getPosts(
    String token, {
    String type = "trending", // trending, following, achievements
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/posts?type=$type&page=$page&limit=$limit"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"posts": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"posts": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET SINGLE POST =================
  static Future<Map<String, dynamic>> getPostById(
    String token,
    String postId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/posts/$postId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"post": null, "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"post": null, "message": "Network error"};
    }
  }

  // ================= COMMUNITY - CREATE POST =================
  static Future<Map<String, dynamic>> createPost({
    required String token,
    required String content,
    String? imageUrl,
    List<String>? hashtags,
    String postType = 'normal',
  }) async {
    try {
      final body = <String, dynamic>{
        "content": content,
        "post_type": postType,
      };
      if (imageUrl != null) body["image_url"] = imageUrl;
      if (hashtags != null && hashtags.isNotEmpty) body["hashtags"] = hashtags;

      final response = await http.post(
        Uri.parse("$baseUrl/community/posts"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - LIKE POST =================
  static Future<Map<String, dynamic>> likePost(
      String token, String postId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/posts/$postId/like"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - UNLIKE POST =================
  static Future<Map<String, dynamic>> unlikePost(
      String token, String postId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/posts/$postId/like"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET COMMENTS =================
  static Future<Map<String, dynamic>> getComments(
    String token,
    String postId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/posts/$postId/comments?page=$page&limit=$limit"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"comments": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"comments": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - CREATE COMMENT =================
  static Future<Map<String, dynamic>> createComment({
    required String token,
    required String postId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/posts/$postId/comments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"content": content}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - LIKE COMMENT =================
  static Future<Map<String, dynamic>> likeComment(
      String token, String commentId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/comments/$commentId/like"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - UNLIKE COMMENT =================
  static Future<Map<String, dynamic>> unlikeComment(
      String token, String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/comments/$commentId/like"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET COMMENT REPLIES =================
  static Future<Map<String, dynamic>> getReplies(
      String token, String commentId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/comments/$commentId/replies"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"replies": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"replies": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - CREATE COMMENT REPLY =================
  static Future<Map<String, dynamic>> createReply({
    required String token,
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/comments/$commentId/replies"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"content": content}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - DELETE POST =================
  static Future<Map<String, dynamic>> deletePost(
      String token, String postId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/posts/$postId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - FOLLOW USER =================
  static Future<Map<String, dynamic>> followUser(
      String token, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/users/$userId/follow"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(
      String token, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/users/$userId/follow"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - UPLOAD IMAGE =================
  static Future<Map<String, dynamic>> uploadImage(
      String token, String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/community/upload"),
      );
      request.headers["Authorization"] = "Bearer $token";
      final ext = imagePath.split('.').last.toLowerCase();
      final mimeSubType = ext == 'png' ? 'png' : 'jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', mimeSubType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Upload failed"};
    } catch (e) {
      print("uploadImage error: $e");
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - UPLOAD IMAGE FROM BYTES (for assets) =================
  static Future<Map<String, dynamic>> uploadImageFromBytes({
    required String token,
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/community/upload"),
      );
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: MediaType('image', 'png'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Upload failed"};
    } catch (e) {
      print("uploadImageFromBytes error: $e");
      return {"message": "Network error"};
    }
  }

  // ================= AUTH - UPLOAD AVATAR =================
  static Future<Map<String, dynamic>> uploadAvatar(
      String token, String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/auth/avatar"),
      );
      request.headers["Authorization"] = "Bearer $token";
      final ext = imagePath.split('.').last.toLowerCase();
      final mimeSubType = ext == 'png' ? 'png' : 'jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        imagePath,
        contentType: MediaType('image', mimeSubType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Upload failed"};
    } catch (e) {
      print("uploadAvatar error: $e");
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET USER PROFILE =================
  static Future<Map<String, dynamic>> getUserProfile(
      String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/users/$userId/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET USER POSTS =================
  static Future<Map<String, dynamic>> getUserPosts(
      String token, String userId, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/users/$userId/posts?page=$page"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "posts": []};
    } catch (e) {
      return {"message": "Network error", "posts": []};
    }
  }

  // ================= COMMUNITY - SEARCH =================
  static Future<Map<String, dynamic>> searchCommunity(
      String token, String query) async {
    try {
      final encoded = Uri.encodeQueryComponent(query);
      final response = await http.get(
        Uri.parse("$baseUrl/community/search?q=$encoded"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "users": [], "posts": []};
    } catch (e) {
      return {"message": "Network error", "users": [], "posts": []};
    }
  }

  // ================= COMMUNITY - GET NOTIFICATIONS =================
  static Future<Map<String, dynamic>> getCommunityNotifications(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/notifications"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "notifications": []};
    } catch (e) {
      return {"message": "Network error", "notifications": []};
    }
  }

  // ================= COMMUNITY - GET FOLLOWERS =================
  static Future<Map<String, dynamic>> getFollowers(
      String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/users/$userId/followers"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"users": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"users": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET FOLLOWING =================
  static Future<Map<String, dynamic>> getFollowing(
      String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/users/$userId/following"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"users": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"users": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - GET NOTIFICATIONS =================
  static Future<Map<String, dynamic>> getNotifications(
    String token, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/community/notifications?page=$page&limit=$limit"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"notifications": [], "message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"notifications": [], "message": "Network error"};
    }
  }

  // ================= COMMUNITY - MARK NOTIFICATION AS READ =================
  static Future<Map<String, dynamic>> markNotificationAsRead(
      String token, String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/community/notifications/$notificationId/read"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - MARK ALL NOTIFICATIONS AS READ =================
  static Future<void> markAllNotificationsAsRead(String token) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/community/notifications/read-all"),
        headers: {"Authorization": "Bearer $token"},
      );
    } catch (_) {}
  }

  // ================= COMMUNITY - DELETE NOTIFICATION =================
  static Future<Map<String, dynamic>> deleteNotification(
      String token, String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/notifications/$notificationId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - DELETE NOTIFICATIONS (batch) =================
  static Future<Map<String, dynamic>> deleteNotifications(
      String token, List<String> ids) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/community/notifications/delete-batch"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"ids": ids}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= COMMUNITY - DELETE ALL READ NOTIFICATIONS =================
  static Future<Map<String, dynamic>> deleteReadNotifications(String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/community/notifications/read-all"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= SAVE USER LANGUAGE =================
  static Future<void> updateUserLanguage(String token, String languageCode) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/auth/user/language"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"language": languageCode}),
      );
    } catch (_) {}
  }

  // ================= ADMIN APIS =================
  
  // Get admin dashboard stats
  static Future<Map<String, dynamic>> getAdminStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/stats"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Get growth data for charts
  static Future<Map<String, dynamic>> getAdminGrowthData(String token, {String period = 'monthly'}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/growth?period=$period"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Get all users for admin
  static Future<Map<String, dynamic>> getAdminUsers(String token, {String? search}) async {
    try {
      var url = "$baseUrl/admin/users";
      if (search != null && search.isNotEmpty) {
        url += "?search=$search";
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Create new user (admin only)
  static Future<Map<String, dynamic>> createUser(
    String token,
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/users"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data["message"] ?? "Failed to create user");
    } catch (e) {
      rethrow;
    }
  }

  // Update user role
  static Future<Map<String, dynamic>> updateUserRole(String token, String userId, String role) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/admin/users/$userId/role"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"role": role}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Delete user
  static Future<Map<String, dynamic>> deleteUser(String token, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/users/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Bulk delete users
  static Future<Map<String, dynamic>> bulkDeleteUsers(String token, List<int> userIds) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/users/bulk-delete"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"userIds": userIds}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data["message"] ?? "Failed to delete users");
    } catch (e) {
      rethrow;
    }
  }

  // Get all posts for admin
  static Future<Map<String, dynamic>> getAdminPosts(String token, {String? search, String? sort}) async {
    try {
      var url = "$baseUrl/admin/posts";
      final params = <String>[];
      
      if (search != null && search.isNotEmpty) {
        params.add("search=$search");
      }
      if (sort != null && sort.isNotEmpty) {
        params.add("sort=$sort");
      }
      
      if (params.isNotEmpty) {
        url += "?${params.join('&')}";
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Delete post (admin)
  static Future<Map<String, dynamic>> deletePostAdmin(String token, String postId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/posts/$postId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Report post violation (admin warning)
  static Future<Map<String, dynamic>> reportPostViolation(
    String token,
    String postId,
    String reason,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/posts/$postId/report"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"reason": reason}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data["message"] ?? "Failed to report post");
    } catch (e) {
      rethrow;
    }
  }

  // Get all comments for admin
  static Future<Map<String, dynamic>> getAdminComments(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/comments"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Delete comment (admin)
  static Future<Map<String, dynamic>> deleteCommentAdmin(String token, String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/comments/$commentId"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Get all plants for admin
  static Future<Map<String, dynamic>> getAdminPlants(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/plants"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "plants": []};
    } catch (e) {
      return {"message": "Network error", "plants": []};
    }
  }

  // Get plant history for specific user (admin)
  static Future<Map<String, dynamic>> getPlantHistory(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/plants/$userId/history"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "plant": null, "history": []};
    } catch (e) {
      return {"message": "Network error", "plant": null, "history": []};
    }
  }

  // Get auto reminder settings (admin)
  static Future<Map<String, dynamic>> getAutoReminderSettings(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/auto-reminder/settings"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Update auto reminder settings (admin)
  static Future<Map<String, dynamic>> updateAutoReminderSettings(
    String token,
    bool isEnabled,
    String morningTime,
    String eveningTime,
    bool sendMorning,
    bool sendEvening,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/admin/auto-reminder/settings"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "is_enabled": isEnabled,
          "morning_time": morningTime,
          "evening_time": eveningTime,
          "send_morning": sendMorning,
          "send_evening": sendEvening,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Get reminder messages (admin)
  static Future<Map<String, dynamic>> getReminderMessages(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/auto-reminder/messages"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed", "messages": []};
    } catch (e) {
      return {"message": "Network error", "messages": []};
    }
  }

  // Add reminder message (admin)
  static Future<Map<String, dynamic>> addReminderMessage(String token, String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/auto-reminder/messages"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"message": message}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Update reminder message (admin)
  static Future<Map<String, dynamic>> updateReminderMessage(
    String token,
    String id,
    String message,
    bool isActive,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/admin/auto-reminder/messages/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
          "is_active": isActive,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Delete reminder message (admin)
  static Future<Map<String, dynamic>> deleteReminderMessage(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/auto-reminder/messages/$id"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // ================= APP SETTINGS (ADMIN) =================

  // Get app settings (admin)
  static Future<Map<String, dynamic>> getAppSettings(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/app-settings"),
        headers: {"Authorization": "Bearer $token"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Update app name (admin)
  static Future<Map<String, dynamic>> updateAppName(String token, String appName) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/admin/app-settings/name"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"appName": appName}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }

  // Update app logo (admin)
  static Future<Map<String, dynamic>> updateAppLogo(String token, String logoUrl) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/admin/app-settings/logo"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"logoUrl": logoUrl}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      return {"message": data["message"] ?? "Failed"};
    } catch (e) {
      return {"message": "Network error"};
    }
  }
}
