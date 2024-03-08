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
  final TextEditingController _verificationTokenController = TextEditingController(); 

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
                  child: Text('USERNAME OR EMAIL'),  
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: onDelete,
              child: const Text('delete storage'),
            ),
            const SizedBox(height: 20)
          ],          
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

  void onLogin() {
    api.login({
      'identity': _identityController.text,
      'password': _passwordController.text,
      }).then((response) async {
        if (response.success) {
          Navigator.pushNamed(context, '/home');
        } else {
          String errorMessage = response.error ?? 'An unknown error occurred';
          if (errorMessage.contains('Forbidden: Email not verified')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  actionsAlignment: MainAxisAlignment.center,
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Text('Enter the code sent to ${_identityController.text}',
                          textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _verificationTokenController,
                          textAlign: TextAlign.center,
                        ),
                      ]
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
          }
          Error.show(context, errorMessage);
        }
      });
    }

  void onVerify() async {
    api.verify({
      'token': _verificationTokenController.text,
      'identity': _identityController.text,
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
  
  void onRegister() {
    Navigator.pushNamed(context, '/register');
  }

// replace button with RESET PASSWORD
  void onDelete() {
    storage.deleteAll();
  }
}
