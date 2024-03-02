import 'package:flutter/material.dart';
import '../api.dart';
import 'alert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'lib/assets/thirst-alert-logo.png',
              height: 75.0,
            ),
            const SizedBox(height: 60),
            TextField(
              controller: _identityController,
              decoration: const InputDecoration(
                  label: Center(
                  child: Text("USERNAME OR EMAIL"),  
                ),
                // errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  label: Center(
                  child: Text("PASSWORD"),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton (
              onPressed: onLogin,
              child: const Text('LOGIN'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRegister,
              child: const Text('REGISTER'),
            ),
            // MAKE HEIGHT 60 WHEN YOU REMOVE TEMP BUTTONS
            const SizedBox(height: 5),
            TextButton(
              onPressed: onTest,
              child: const Text('home'),
            ),
            TextButton(
              onPressed: onDelete,
              child: const Text('delete storage'),
            ),
          ],          
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

  void onLogin() {
    api.login({
      'identity': _identityController.text,
      'password': _passwordController.text,
    }).then((response) {
      if (response.success) {
        Navigator.pushNamed(context, '/home');
      } else {
        String errorMessage = response.error ?? "An unknown error occurred";
        Error.show(context, errorMessage);
      }
    });
  }
  void onRegister() {
      Navigator.pushNamed(context, '/register');
    }

  void onTest() {
        Navigator.pushNamed(context, '/home');
    }

  void onDelete() {
      storage.deleteAll();
    }
  }