import 'package:flutter/material.dart';
import 'package:thirst_alert/theme.dart';
import '../api.dart';
import 'alert.dart';
import 'package:thirst_alert/screens/sensor.dart';
import 'package:thirst_alert/sensor_manager.dart' show Sensor;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const  iosInitializationSetting = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(iOS: iosInitializationSetting);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
    );
    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}

final LocalNotificationService localNotificationService = LocalNotificationService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Api api = Api();

  List<Sensor> mySensors = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Sensor.initDocumentsDir();

    api.getSensors().then((response) {
      if (response.success) {
        final sensorsData = response.data;
        setState(() {
          mySensors = List<Sensor>.from(sensorsData['sensors'].map((sensor) =>
              Sensor.fromMap(sensor, () {
                setState(() {});
              })));
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
      // this should actually only render while a "loading" variable is true.
      // if !loading && mySensors.isEmpty() then show something like
      // "Add a new sensor using the plus button below!"
      return const Center(child: CircularProgressIndicator());
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hello, ${identityManager.username ?? ''}'),
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
                          child: Card(
                          elevation: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: sensor.isImageLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: sensor.image,
                                            fit: BoxFit.cover
                                          ),
                                        ),
                                      )
                                ),
                                ListTile(
                                  title: Text(sensor.name),
                                  trailing: sensor.active == true 
                                  ? const Icon(Icons.favorite, color: accent) 
                                  : const Icon(Icons.water_drop, color: attention),
                                ),
                              ],
                            ),
                          )
                        )
                      )
                    );
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
      ),
    );
  }

  void onAddSensor() async {
    Navigator.pushNamed(context, '/sensor/start');
  }

  void onViewSensor(Sensor sensor) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SensorScreen(sensor: sensor)),
    );
  }

  void onLogout() {
    try {
      identityManager.clearUserData();
      Navigator.pushNamed(context, '/');
      Success.show(context, 'Logged out successfully');
    } catch (e) {
      Error.show(context, 'Something went wrong');
    }
  }

  void onInitNotifications() async {
    await localNotificationService.init();
  }

  void onSendNotification() async {
    await localNotificationService.showNotification('ThirstAlert', 'Your Monstera is thirsty!');
  }
}
