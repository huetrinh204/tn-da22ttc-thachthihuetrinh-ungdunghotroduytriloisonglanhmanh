import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

// Handler cho background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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
  final LocaleProvider _localeProvider = LocaleProvider();
  
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
    final onboardingDone = prefs.getBool("onboarding_done") ?? false;

    if (token != null && onboardingDone) {
      setState(() => startScreen = const HomeScreen());
    } else if (token != null && !onboardingDone) {
      setState(() => startScreen = const OnboardingScreen());
    } else {
      setState(() => startScreen = const LoginScreen());
    }
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
        home: startScreen ??
            const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }
}