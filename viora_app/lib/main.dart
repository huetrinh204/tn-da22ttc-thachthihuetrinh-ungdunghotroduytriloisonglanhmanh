import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}
void testLogin() async {
  print("CALL API...");

  final res = await ApiService.login(
    "trinh123@gmail.com",
    "123456",
  );

  print("LOGIN RESPONSE: $res");
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    testLogin(); // 👈 gọi ở đây
  }

  void testLogin() async {
    print("CALL API...");

    final res = await ApiService.login(
      "testlogin@gmail.com",
      "111111",
    );

    print("LOGIN RESPONSE: $res");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}