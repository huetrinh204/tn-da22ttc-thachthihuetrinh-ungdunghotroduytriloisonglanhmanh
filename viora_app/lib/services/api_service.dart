import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

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
    String? gender,
    int? birthYear,
    double? height,
    double? weight,
    List<String>? goals,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "gender": gender,
          "birth_year": birthYear,
          "height": height,
          "weight": weight,
          "goals": goals,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {"message": data["message"] ?? "Update failed"};
      }
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
        body: jsonEncode({
          "token": token,
        }),
      );

      final data = jsonDecode(response.body);

      // 👉 debug
      print("GOOGLE API RESPONSE: $data");

      if (response.statusCode == 200) {
        return data;
      } else {
        return {"message": data["message"] ?? "Google login failed"};
      }
    } catch (e) {
      print("ERROR: $e");
      return {"message": "Network error"};
    }
  }
}