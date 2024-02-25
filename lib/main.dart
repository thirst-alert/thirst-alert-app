import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'theme.dart';
import 'screens/auth.dart';
import 'screens/register.dart';
import 'screens/home.dart';

Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thirst Alert',
      theme: myTheme,
      routes: {
        '/': (context) => const LoginScreen(),
        '/register':(context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
     },
    );
  }
}