import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // true = điện thoại thật, false = máy ảo (emulator)
  static const bool _isPhysicalDevice = false;

  static const String baseUrl = _isPhysicalDevice
      ? "http://192.168.1.6:3000"
      : "http://10.0.2.2:3000";

  // ================= GET PROFILE =================
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
      String token, int habitId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/habits/$habitId/checkin"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
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
}