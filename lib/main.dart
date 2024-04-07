import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'screens/auth.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/user.dart';
import 'screens/information.dart';
import 'screens/sensor/start.dart';
import 'identity_manager.dart';
import 'api.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  await dotenv.load();
  bool isLoggedIn = false;
  final identityManager = IdentityManager();
  await identityManager.initFromStorage();
  if (identityManager.accessToken != null) {
    final Api api = Api();
    final ApiResponse res = await api.me();
    if (res.success) isLoggedIn = true;
  }
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thirst Alert',
      theme: myTheme,
      initialRoute: isLoggedIn ? '/home' : '/',
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => const LoginScreen(),
        '/register':(context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/user': (context) => const UserScreen(),
        '/information': (context) => InformationScreen(0),
        '/sensor/start': (context) => const SensorStart(),
      },
    );
  }
}