import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/onboarding_gate.dart';
import 'services/fcm_service.dart';
import 'navigation/app_navigation.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

// Handler cho background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_deep_link', jsonEncode(message.data));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.init();
  await NotificationService.requestPermission();
  await FcmService.init();
  runApp(MyApp(key: myAppKey));
}

// Global key to access MyApp state
final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget? startScreen;
  final LocaleProvider _localeProvider = LocaleProvider.global;
  
  // Public getter để truy cập từ bên ngoài
  LocaleProvider get localeProvider => _localeProvider;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final needsOnboarding = await OnboardingGate.needsOnboarding(token);
      setState(() {
        startScreen =
            needsOnboarding ? const OnboardingScreen() : const HomeScreen();
      });
      if (!needsOnboarding) {
        _checkPendingDeepLink();
      }
    } else {
      setState(() => startScreen = const LoginScreen());
    }
  }

  void _checkPendingDeepLink() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pending_deep_link');
    if (raw == null) return;
    await prefs.remove('pending_deep_link');

    try {
      final data = Map<String, String>.from(jsonDecode(raw));
      if (data.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppNavigation.handleFcmDeepLink(data);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeNotifier, _localeProvider]),
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeNotifier.value,
        locale: _localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate, // Uncomment after running: flutter gen-l10n
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi'),
          Locale('en'),
        ],
        navigatorKey: AppNavigation.navigatorKey,
        home: startScreen ??
            const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }
}