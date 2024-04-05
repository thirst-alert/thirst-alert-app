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
  bool _passwordIsObscured = true;

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                textInputAction: TextInputAction.next
              ),
      
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    label: const Center(
                    child: Text('PASSWORD'),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordIsObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() {
                        _passwordIsObscured = !_passwordIsObscured;
                      }
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(48, 16, 0, 16),
                ),
                obscureText: _passwordIsObscured,
                onSubmitted: (_) => onLogin(),
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
                onPressed: () {
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
                                TextField(
                                  controller: _identityController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    label: Center(
                                      child: Text('ACCOUNT EMAIL'),)
                                  ),
                                ),
                              ],
                            )
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: onResetPassword,
                            child: const Text('RESET PASSWORD'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('RESET MY PASSWORD'),
              ),
              const SizedBox(height: 20)
            ],          
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
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
          if (errorMessage.contains('Email not verified')) {
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
                          onSubmitted: (_) => onVerify(),
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

  void onVerify() {
    api.verify({
    'token': _verificationTokenController.text,
    'identity': _identityController.text,
    }).then((response) {
      if (response.success) {
        api.login({
          'identity': _identityController.text,
          'password': _passwordController.text,
        }).then((response) {
          if (response.success) {
            Navigator.pushNamed(context, '/home');
            Success.show(context, 'Welcome to Thirst Alert!');
          } else {
            String errorMessage = response.error ?? 'An unknown error occurred';
            Error.show(context, errorMessage);
          }
        });
      } else {
        String errorMessage = response.error ?? 'An unknown verification error occurred';
        Error.show(context, errorMessage);
      }
    });
  }
  
  void onRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void onResetPassword() {
    api.resetPassword({
      'email': _identityController.text
    }).then((response) {      
      if (response.success) {
        Success.show(context, 'We sent you an email to reset your password');
      } else {
        String errorMessage = response.error ?? 'An unknown error occurred. Please make sure your email is correct.';
        Error.show(context, errorMessage);
      }
    });
  }
}
