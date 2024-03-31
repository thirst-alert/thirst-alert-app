import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'screens/auth.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/user.dart';
import 'screens/information.dart';
import 'screens/sensor.dart';
import 'screens/sensor/start.dart';

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
        '/user': (context) => const UserScreen(),
        '/information': (context) => InformationScreen(0),
        // '/viewSensor': (context) => SensorScreen(),
        '/sensor/start': (context) => const SensorStart(),
      },
    );
  }
}