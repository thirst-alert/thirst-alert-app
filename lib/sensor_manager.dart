import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'api.dart';
import 'identity_manager.dart';
import 'package:flutter/material.dart';

final Api api = Api();
final IdentityManager identityManager = IdentityManager();
late Directory appDocumentsDir;
const AssetImage defaultSensorImage = AssetImage('lib/assets/b.jpg');

class Sensor {
  final String sensorId;
  String name;
  int thirstLevel;
  bool hasCustomImage;
  bool active;
  dynamic image = defaultSensorImage;
  bool isImageLoading = false;
  late String imagePath;
  VoidCallback updateStateCallback;

  factory Sensor.fromMap(Map<String, dynamic> sensor, VoidCallback updateStateCallback) {
    return Sensor(
      sensorId: sensor['id'],
      name: sensor['name'],
      thirstLevel: sensor['thirstLevel'],
      active: sensor['active'],
      hasCustomImage: sensor['hasCustomImage'],
      isImageLoading: sensor['hasCustomImage'],
      updateStateCallback: updateStateCallback,
    );
  }

  static Future<void> initDocumentsDir() async {
    appDocumentsDir = await getApplicationDocumentsDirectory();
  }

  Future<void> _fetchImage() async {
    final File file = File(imagePath);
    if (await file.exists()) {
      image = FileImage(file);
      isImageLoading = false;
      return updateStateCallback();
    }

    final success = await api.downloadSensorImage(identityManager.userId!, sensorId);

    if (!success) {
      await api.patchSensor(sensorId, {'hasCustomImage': false});
      isImageLoading = false;
      return updateStateCallback();
    }

    image = FileImage(file);
    isImageLoading = false;
    updateStateCallback();
  }

  Future<bool> updateImage(XFile pickedImage, String mimeType) async {
    isImageLoading = true;
    updateStateCallback();
    await pickedImage.saveTo(imagePath);
    bool success = await api.uploadSensorImage(identityManager.userId!, sensorId, mimeType);
    if (!success) {
      await File(imagePath).delete();
      isImageLoading = false;
      updateStateCallback();
      return false;
    }

    if (!hasCustomImage) {
      final res = await api.patchSensor(sensorId, {'hasCustomImage': true});
      if (!res.success) {
        await File(imagePath).delete();
        // delete from gcs
        isImageLoading = false;
        updateStateCallback();
        return false;
      }
      hasCustomImage = true;
    }
    
    final FileImage newImage = FileImage(File(imagePath));
    await newImage.evict();
    image = newImage;
    isImageLoading = false;
    updateStateCallback();
    return true;
  }

  Future<bool> removeImage() async {
    isImageLoading = true;
    updateStateCallback();
    final File file = File(imagePath);
    if (!await file.exists()) {
      image = defaultSensorImage;
      isImageLoading = false;
      updateStateCallback();
      return true;
    }

    await file.delete();
    final res = await api.patchSensor(sensorId, {'hasCustomImage': false});
    if (!res.success) {
      isImageLoading = false;
      updateStateCallback();
      return false;
    }

    hasCustomImage = false;
    image = defaultSensorImage;
    isImageLoading = false;
    updateStateCallback();
    return true;
  }

  Future<bool> updateName(String newName) async {
   final res = await api.patchSensor(sensorId, {'name': newName});
    if (!res.success) {
      updateStateCallback();
      return false;
    }
    name = newName;
    updateStateCallback();
    return true;
  }

  Future<bool> updateThirstLevel(int newThirstLevel) async {
    final res = await api.patchSensor(sensorId, {'thirstLevel': newThirstLevel});
    if (!res.success) {
      updateStateCallback();
      return false;
    }
    thirstLevel = newThirstLevel;
    updateStateCallback();
    return true;
  }
  
  Sensor({
    required this.sensorId,
    required this.name,
    required this.thirstLevel,
    required this.hasCustomImage,
    required this.active,
    required this.isImageLoading,
    required this.updateStateCallback
  }) {
    imagePath = '${appDocumentsDir.path}/${identityManager.userId}-$sensorId';
    if (hasCustomImage) {
      _fetchImage();
    }
  }
}
