import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _LoginPage(),
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Username',
                // errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            TextField(
              controller: _passwordController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                child: const Text('Login'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTest,
                child: const Text('Test'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDelete,
                child: const Text('Delete storage'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onLogin() {
    api.login({
      'username': _usernameController.text,
      'password': _passwordController.text,
    });
  }

  void onTest() {
    api.test()
      .then((response) => {
        print(response)
      });
  }

  void onDelete() {
    storage.deleteAll();
  }
}