import 'package:flutter/material.dart';
import '../api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 78),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'lib/assets/thirst-alert-logo.png',
              height: 75.0,
            ),
            const SizedBox(height: 60),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(
                  child: Text("EMAIL"),
                ),
                // errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(
                  child: Text("USERNAME"),
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
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                label: Center(
                  child: Text("REPEAT PASSWORD"),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTest,
            child: const Text('VERIFY'),
          ),
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void onTest() {
    api.test().then((response) => {print(response)});
  }
}
