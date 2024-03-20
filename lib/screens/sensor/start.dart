import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../alert.dart';
import 'package:thirst_alert/screens/sensor/wifi.dart';

class SensorStart extends StatefulWidget {
  const SensorStart({super.key});

  @override
  SensorStartState createState() => SensorStartState();
}

class SensorStartState extends State<SensorStart> {
  bool btStatus = false;
  bool scanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  List<ScanResult> devices = [];

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    if (!(await FlutterBluePlus.isSupported)) {
      Error.show(context, "Bluetooth is not supported on this device.");
      return;
    }

    // Listen for Bluetooth adapter state changes
    _adapterSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        btStatus = true;
        _startScan();
      } else {
        Error.show(context, "Bluetooth is turned off. Enable it and try scanning again.");
        setState(() {
          devices.clear();
        });
      }
    });

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _startScan() async {
    setState(() {
      scanning = true;
    });
    try {
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        setState(() {
          devices = results;
        });
      }, onError: (e) => print(e));

      await FlutterBluePlus.startScan(
        withServices: [Guid('61806eea-01a4-4b11-b4bd-6e588e84eea3')],
        timeout: const Duration(seconds: 5),
      );

      await FlutterBluePlus.isScanning.where((val) => val == false).first;
      if (devices.isEmpty) {
        Error.show(context, "Could not find any devices. Make sure your sensor is in pairing mode and try again.");
      }
    } catch (e) {
      print('Error starting scan: $e');
    } finally {
      setState(() {
        scanning = false;
      });
    }
  }

  void _onRetryScan() {
    if (btStatus) {
      _scanSubscription?.cancel();
      _startScan();
    } else {
      _scanSubscription?.cancel();
      _adapterSubscription?.cancel();
      _initBluetooth();
    }
  }

  void _onDeviceSelected(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SensorWifi(sensor: device)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Sensor'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    // GOTTA SET THIS THEME IN THEME.DART
                    tileColor: Color(0xFF28292F),
                    contentPadding: EdgeInsets.all(20),
                    title: Text(device.platformName),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    onTap: () => scanning ? null : _onDeviceSelected(device),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: scanning ? null : _onRetryScan,
              child: scanning ? const CircularProgressIndicator() : const Text('SCAN AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}