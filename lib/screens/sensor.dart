import 'dart:math';
import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
// import 'alert.dart';
import 'home.dart';
import 'information.dart';
import 'sensor/measurement.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  SensorScreenState createState() => SensorScreenState();
}

class SensorScreenState extends State<SensorScreen> {
  final TextEditingController _nameController = TextEditingController();

  Api api = Api();

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Sensor sensor = args['sensor'];
    String selectedThirstLevel = 'Low';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Your Sensor'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pushNamed(
          context,
          '/home',),
        ),
      ),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                //   image: AssetImage(sensor.img),
                  image: AssetImage('lib/assets/b.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: () {
                    // ADD FUNCTIONALITY
                  },
                  child: const Icon(
                    Icons.add_a_photo_rounded,
                    )
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: sensor.name,
                        hintStyle: const TextStyle(color: text),
                        suffixIcon: const Icon(Icons.edit),
                      ),
                      // ADD FUNCTIONALITY - UsPDATE NAME ONCHANGED
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 30, 0),
                  child: Transform.rotate(
                    angle:
                        -90 * pi / 180,
                    child: const Icon(
                      Icons.battery_3_bar_rounded,
                      color: accent,
                      size: 40,
                    ),
                  ),
                  // ADD FUNCTIONALITY
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding (
                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: Text('Thirst Level'),
                ),
                Padding (padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                  child: DropdownButton<String>(
                    value: selectedThirstLevel,
                    // doesn't update, but needs a lot of change anyway once we take the real value
                    onChanged: (String? newThirstLevel) {
                      setState(() {
                        selectedThirstLevel = newThirstLevel!;
                        // ADD FUNCTIONALITY
                      });
                    },
                    items: <String>['Low', 'Medium', 'High'].map<DropdownMenuItem<String>>((String thirstLevel){
                      return DropdownMenuItem<String>(
                        value: thirstLevel,
                        child: Text(thirstLevel),
                        );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Temperature'),
                      // ADD FUNCTIONALITY
                      Text('15 °C'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Moisture'),
                      // ADD FUNCTIONALITY
                      Text('50 %'),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: SensorChart(),
              ),

            const SizedBox(height: 40),

            TextButton(
              onPressed: () {
                // ADD FUNCTIONALITY
              },
              child: const Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded),
                    SizedBox(width: 10),
                    Text('Clear Device History'),
                ],
              ),
            ),
            
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InformationScreen(0)));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent_rounded),
                  SizedBox(width: 10),
                  Text('Get Help'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
