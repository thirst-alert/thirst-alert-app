import 'package:flutter/material.dart';
import 'package:thirst_alert/screens/information.dart';
import '../api.dart';
import 'alert.dart';
import '../theme.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  int selectTab = 0;

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Your Account'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical:60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // UNFINISHED:
            // Change password
            // Share

            TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InformationScreen(0)
                  )
                );
              }, child: const Row(
                children: [
                  Icon(Icons.support_agent_rounded),
                  SizedBox(width: 10),
                  Text('Get Help'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformationScreen(1)
                    ),
                  );
                }, child: const Row(
                children: [
                  Icon(Icons.menu_book_rounded),
                  SizedBox(width: 10),
                  Text('Device Guidelines'),
                ],
              ),
            ),

            const SizedBox(height: 20),  

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InformationScreen(1)),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.privacy_tip_rounded),
                  SizedBox(width: 10),
                  Text('Terms & Conditions'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton (
              onPressed: onShare,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SHARE'),
                  SizedBox(width: 10),
                  Icon(Icons.share_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onChangePassword,
              child: const Text('CHANGE MY PASSWORD'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      actionsAlignment: MainAxisAlignment.center,
                      title: const Text('Are you sure?'),
                      content: const Text(
                          'Confirming will remove all your account and device details.\nYou will not be able to log back in.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            onDelete();
                            Navigator.of(context).pop();
                          },
                          child: const Text('CONFIRM'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('DELETE MY ACOUNT',
              style: TextStyle(
                color: attention
              )),
            ),
            const SizedBox(height: 20),
          ],          
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

  void onDelete() {
    api.deleteUser().then((response) {
      if (response.success) {
        Navigator.pushNamed(context, '/');
        Success.show(context, 'Account deleted');
      } else {
        String errorMessage =
            response.error ?? 'An unknown verification error occurred';
        Error.show(context, errorMessage);
      }
    });
  }

  void onShare() {
    Navigator.pushNamed(context, '/');
  }

  void onChangePassword() {
    Navigator.pushNamed(context, '/');
  }
}
