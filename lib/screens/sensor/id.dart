import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../api.dart';
import '../alert.dart';

class SensorId extends StatefulWidget {
  final BluetoothDevice sensor;
  const SensorId({super.key, required this.sensor});

  @override
  SensorIdState createState() => SensorIdState();
}

class SensorIdState extends State<SensorId> {
  late BluetoothDevice sensor;
  late BluetoothCharacteristic idCharacteristic;
  late BluetoothCharacteristic statusCharacteristic;
  final TextEditingController _nameController = TextEditingController();
  bool writingToSensor = false;
  bool validName = true;

  Api api = Api();

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    idCharacteristic = BluetoothCharacteristic(
      remoteId: sensor.remoteId,
      serviceUuid: Guid('61806eea-01a4-4b11-b4bd-6e588e84eea3'),
      characteristicUuid: Guid('db4b9b09-0a07-44c7-8ebf-9ec351851aaa')
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
        title: const Text('Configure Sensor'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                maxLength: 32,
                enabled: !writingToSensor,
                decoration: const InputDecoration(
                    label: Center(
                    child: Text('NAME'),
                  ),
                ),
                textAlign: TextAlign.center,
                onSubmitted: _onSubmitConfiguration,
                // textInputAction: TextInputAction.next
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: writingToSensor ? null : _onConfigureSensor,
                child: writingToSensor ? const CircularProgressIndicator() : const Text('ALL DONE!'),
              )
            ]
          )
        ),
      )
    );
  }

  void _onSubmitConfiguration(String value) {
    if (value.isNotEmpty) {
      _onConfigureSensor();
    }
  }

  void _onConfigureSensor() async {
    setState(() {
      writingToSensor = true;
    });

    final res = await api.createSensor({
      'name': _nameController.text
    });

    if (!res.success) {
      Error.show(context, res.error ?? 'An unknown error occurred. Please try again.');
      setState(() {
        writingToSensor = false;
      });
      return;
    }

    final sensorId = res.data['sensor']['id'];
    if (sensorId == null) {
      Error.show(context, 'An unknown error occurred. Please try again.');
      setState(() {
        writingToSensor = false;
      });
      return;
    }

    Completer<void> writeStatusCompleter = Completer<void>();

    final statusSubscription = statusCharacteristic.onValueReceived.listen((value) async {
      if (value[0] == 79) {
        Success.show(context, 'Sensor configured successfully!', AlertOptions(
          buttonText: 'BACK TO HOME',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.popAndPushNamed(context, '/home');
          }
        ));
      } else {
        Error.show(context, 'Something went wrong while configuring the sensor. Please try again.');
        await api.deleteSensor(sensorId);
      }
      writeStatusCompleter.complete();
    });
    sensor.cancelWhenDisconnected(statusSubscription, delayed:true, next:true);

    await sensor.connect(autoConnect: false);
    await sensor.discoverServices();
    await statusCharacteristic.setNotifyValue(true);
    await idCharacteristic.write(sensorId.codeUnits);
    await writeStatusCompleter.future.timeout(
      const Duration(seconds: 10),
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