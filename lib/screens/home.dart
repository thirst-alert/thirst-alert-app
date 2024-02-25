import 'package:flutter/material.dart';
import '../api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class ItemData {
  final String name;
  final String imagePath;
  ItemData({required this.name, required this.imagePath});
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<ItemData> myItems = [
    ItemData(name: 'My Boo', imagePath: 'lib/assets/a.png'),
    ItemData(name: 'Monstera', imagePath: 'lib/assets/b.jpg'),
    ItemData(name: 'Thirsty Hoe', imagePath: 'lib/assets/c.jpg'),
    ItemData(name: 'Tomatoze', imagePath: 'lib/assets/d.jpg'),
    // Add more items as needed
  ];

  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, _getUserName'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.account_box_rounded),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
          child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: myItems.length,
                itemBuilder: (context, index) {
                  // CANNOT FOR THE LIFE OF ME SET ITS HEIGHT
                  return SizedBox(
                    height: 180.0,
                    child: Card(
                      elevation: 3,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(16.0),
                      // ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              myItems[index].imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ListTile(
                            title: Text(myItems[index].name),
                            trailing: const Icon(Icons.check_circle),
                          ),
                        ],
                      ),
                    )
                  )
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}


  void onLogout() {
    Navigator.pushNamed(context, '/');
  }
}
