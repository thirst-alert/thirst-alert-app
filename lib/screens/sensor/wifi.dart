import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thirst_alert/screens/sensor/id.dart';
import '../alert.dart';

class SensorWifi extends StatefulWidget {
  final BluetoothDevice sensor;
  const SensorWifi({super.key, required this.sensor});

  @override
  SensorWifiState createState() => SensorWifiState();
}

class SensorWifiState extends State<SensorWifi> {
  late BluetoothDevice sensor;
  late BluetoothCharacteristic apCharacteristic;
  late BluetoothCharacteristic statusCharacteristic;
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordIsObscured = true;
  bool writingToSensor = false;

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    apCharacteristic = BluetoothCharacteristic(
      remoteId: sensor.remoteId,
      serviceUuid: Guid('61806eea-01a4-4b11-b4bd-6e588e84eea3'),
      characteristicUuid: Guid('270e61b7-9986-4eb4-a686-d7750dcd1435')
    );
    statusCharacteristic = BluetoothCharacteristic(
      remoteId: sensor.remoteId,
      serviceUuid: Guid('61806eea-01a4-4b11-b4bd-6e588e84eea3'),
      characteristicUuid: Guid('a00879e9-ad2e-4431-b7fb-1fccebe98b6b')
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Wi-Fi Network'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _ssidController,
                enabled: !writingToSensor,
                decoration: const InputDecoration(
                    label: Center(
                    child: Text('SSID'),
                  ),
                ),
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                enabled: !writingToSensor,
                decoration: InputDecoration(
                  label: const Center(
                    child: Text('PASSWORD')
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordIsObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() {
                      _passwordIsObscured = !_passwordIsObscured;
                    }),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(48, 16, 0, 16),
                ),
                textAlign: TextAlign.center,
                obscureText: _passwordIsObscured,
                onSubmitted: _onSubmitPassword
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: writingToSensor ? null : _onAssignAP,
                child: writingToSensor ? const CircularProgressIndicator() : const Text('ASSIGN WI-FI TO SENSOR'),
              )
            ]
          )
        ),
      )
    );
  }

  void _onSubmitPassword(String value) {
    if (_ssidController.text.isNotEmpty && value.isNotEmpty) {
      _onAssignAP();
    }
  }

  void _onAssignAP() async {
    setState(() {
      writingToSensor = true;
    });
    Completer<void> writeStatusCompleter = Completer<void>();

    final statusSubscription = statusCharacteristic.onValueReceived.listen((value) {
      if (value[0] == 79) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SensorId(sensor: sensor)),
        );
      } else {
        Error.show(context, 'The sensor couldn\'t connect to the Wi-Fi network you provided. Please try again.');
      }
      writeStatusCompleter.complete();
    });
    sensor.cancelWhenDisconnected(statusSubscription, delayed:true, next:true);

    await sensor.connect(autoConnect: false);
    await sensor.discoverServices();
    await statusCharacteristic.setNotifyValue(true);
    await apCharacteristic.write([_ssidController.text.length, ..._ssidController.text.codeUnits, ..._passwordController.text.codeUnits]);
    await writeStatusCompleter.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        Error.show(context, 'The sensor didn\'t respond. Please try again.');
      }
    );
    await sensor.disconnect();
    setState(() {
      writingToSensor = false;
    });
  }
}