import 'package:flutter/material.dart';
import 'package:thirst_alert/theme.dart';
import '../api.dart';
import 'alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class Sensor {
  final String sensorId;
  final String name;
  // final String img;
  final bool active;
  Sensor(
      {required this.sensorId,
      required this.name,
      // required this.img,
      this.active = true});
}

class HomeScreenState extends State<HomeScreen> {
  Api api = Api();

  Future<String?> _getUserName() async {
    return await storage.read(key: 'username');
  }

  late List<Sensor>? mySensors;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    api.getSensors().then((response) {
      if (response.success) {
        final sensorsData = response.data;
        setState(() {
          mySensors = List<Sensor>.from(sensorsData['sensors'].map((sensor) =>
              Sensor(sensorId: sensor['id'], name: sensor['name'])));
        });
      } else {
        String errorMessage = response.error ?? 'An unknown error occurred.';
        Error.show(context, errorMessage);
      }
    }).catchError((error) {
      setState(() {
        // mySensors = [];
        print(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (mySensors == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: _getUserName(),
          builder: (context, snapshot) {
            final username = snapshot.data ?? '';
            return Text('Hello, $username');
          },
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                Navigator.pushNamed(context, '/user');
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
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
                itemCount: mySensors!.length,
                itemBuilder: (context, index) {
                  final sensor = mySensors![index];
                  return GestureDetector(
                      onTap: () {
                        onViewSensor(sensor);
                      },
                      child: SizedBox(
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
                                              'lib/assets/b.jpg', // Path to default image
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    // Expanded(
                                    //   child: sensor.img.isNotEmpty
                                    //               ? Image.asset(
                                    //                   sensor.img,
                                    //                   fit: BoxFit.cover,
                                    //                 )
                                    //               : Image.asset(
                                    //                  'lib/assets/b.jpg', // Path to default image
                                    //                   fit: BoxFit.cover,
                                    //                 ),
                                    //         ),
                                    ListTile(
                                      title: Text(sensor.name),
                                      trailing: sensor.active == true 
                                      ? const Icon(Icons.favorite, color: accent) 
                                      : const Icon(Icons.water_drop, color: attention),
                                    ),
                                  ],
                                ),
                              ))));
                },
              ),
            ),
            SizedBox(
              height: 60,
              width: 60,
              child: ElevatedButton(
                onPressed: onAddSensor,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onAddSensor() async {
    Navigator.pushNamed(context, '/sensor/start');
  }

  void onViewSensor(Sensor sensor) async {
    api.viewSensor(sensor.sensorId).then((response) {
      if (response.success) {
        Navigator.pushNamed(
          context,
          '/viewSensor',
          arguments: {
            'sensor': sensor
          },
        );
      } else {
        String errorMessage = response.error ?? 'An unknown error occurred.';
        Error.show(context, errorMessage);
      }
    });
  }

  void onLogout() {
    try {
      storage.deleteAll();
      Navigator.pushNamed(context, '/');
      Success.show(context, 'Logged out successfully');
    } catch (e) {
      Error.show(context, 'Something went wrong');
    }
  }
}
