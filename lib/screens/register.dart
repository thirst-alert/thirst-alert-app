import 'package:flutter/material.dart';
import '../api.dart';
import 'alert.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _verificationTokenController = TextEditingController();

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
                  child: Text('USERNAME'),
                ),
                // errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              onChanged: (text) {
                _emailController.text = text.toLowerCase();},
              decoration: const InputDecoration(
                label: Center(
                  child: Text('EMAIL'),
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
                  child: Text('PASSWORD'),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _repeatPasswordController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                label: Center(
                  child: Text('REPEAT PASSWORD'),
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
            onPressed: onRegister,
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void onRegister() {
    if (_passwordController.text != _repeatPasswordController.text) {
      Error.show(context, 'Passwords do not match');
      return;
    }
    api.register({
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    }).then((response) {
      if (response.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text('Enter the code sent to ${_emailController.text}',
                      textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _verificationTokenController,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: onVerify,
                  child: const Text('CONFIRM'),
                ),
              ],
            );
          },
        );
      } else {
        String errorMessage = response.error ?? 'An unknown error occurred';
        Error.show(context, errorMessage);
      }
    });
  }

  void onVerify() {
    api.verify({
    'token': _verificationTokenController.text,
    'identity': _emailController.text,
    }).then((response) {
      if (response.success) {
        Navigator.pushNamed(context, '/home');
        Success.show(context, 'Welcome to Thirst Alert!');
      } else {
        String errorMessage = response.error ?? 'An unknown verification error occurred';
        Error.show(context, errorMessage);
      }
    });
  }
}