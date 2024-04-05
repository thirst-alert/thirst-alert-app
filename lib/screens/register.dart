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
  bool validEmail = true;
  bool validPassword = true;
  bool _passwordIsObscured = true;

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

            const SizedBox(height: 30),
            // LEAVE MY CODE ALONE
            // if (!validEmail)
            //   const Card(
            //     elevation: 3,
            //     child: Padding(
            //       padding:
            //           EdgeInsets.all(10),
            //       child: Row(
            //         children: [
            //           Icon(
            //             Icons.error_rounded,
            //             color: attention,
            //           ),
            //           SizedBox(width:10),
            //           Text('Please enter a valid email address.'),
            //         ],
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 30),

            TextField(
              maxLength: 12,
              controller: _usernameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                label: Center(
                  child: Text('USERNAME'),
                ),
                counterText: '',
              ),
              textInputAction: TextInputAction.next
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (text) {
                _emailController.text = text.toLowerCase();
                setState(() {
                  validEmail = _validEmail(_emailController.text);
                });
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                label: const Center(
                  child: Text('EMAIL'),
                ),
                errorMaxLines: 2,
                errorText: validEmail ? null : 'Please enter a valid email address',
              ),
              textInputAction: TextInputAction.next
            ),

            const SizedBox(height: 20),

            TextField(
              maxLength: 32,
              controller: _passwordController,
              onChanged: (text) {
                setState(() {
                  validPassword = _validPassword(_passwordController.text);
                });
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                label: const Center(
                  child: Text('PASSWORD'),
                ),
                counterText: '',
                errorMaxLines: 4,
                errorText: validPassword ? null : 'Passwords need a number, special character, lowercase and uppercase letter',
                suffixIcon: IconButton(
                  icon: Icon(_passwordIsObscured
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(() {
                    _passwordIsObscured = !_passwordIsObscured;
                  }),
                ),
                contentPadding: const EdgeInsets.fromLTRB(48, 16, 0, 16),
              ),
              obscureText: _passwordIsObscured,
              textInputAction: TextInputAction.next
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _repeatPasswordController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                label: const Center(
                  child: Text('REPEAT PASSWORD'),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_passwordIsObscured
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(() {
                    _passwordIsObscured = !_passwordIsObscured;
                  }),
                ),
                contentPadding: const EdgeInsets.fromLTRB(48, 16, 0, 16),
              ),
              obscureText: _passwordIsObscured,
              onSubmitted: (_) {
                if (validEmail && validPassword) return onRegister();
              },
            ),
            const SizedBox(height: 350),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: validEmail && validPassword ? onRegister : null,
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 60),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  bool _validEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  bool _validPassword(String password) {
    bool containsNumber = password.contains(RegExp(r'\d'));
    bool containsSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool containsLowercase = password.contains(RegExp(r'[a-z]'));
    bool containsUppercase = password.contains(RegExp(r'[A-Z]'));
    return containsNumber &&
        containsSpecialChar &&
        containsLowercase &&
        containsUppercase;
  }

  void onRegister() {
    if (_passwordController.text != _repeatPasswordController.text) {
      Error.show(context, 'Passwords do not match');
      return;
    }
    if (_passwordController.text.length < 8) {
      Error.show(context, 'Passwords needs to have at least 8 characters');
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
                      onSubmitted: (_) => onVerify(),
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
        api.login({
          'identity': _emailController.text,
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
}