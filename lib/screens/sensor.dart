import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../api.dart';
import 'alert.dart';
import 'home.dart';
import '../theme.dart';
import 'information.dart';

const AssetImage defaultImage = AssetImage('lib/assets/b.jpg');
late Directory appDocumentsDir;
final picker = ImagePicker();
final Api api = Api();

class SensorScreen extends StatefulWidget {
  final Sensor sensor;
  const SensorScreen({super.key, required this.sensor});

  @override
  SensorScreenState createState() => SensorScreenState();
}

class SensorScreenState extends State<SensorScreen> {
  final TextEditingController _nameController = TextEditingController();

  dynamic sensorImage = defaultImage;
  bool imageLoading = true;
  late Sensor sensor;
  late String? sensorImageFileName;

  @override
  void initState() {
    sensor = widget.sensor;
    sensorImageFileName = '${identityManager.userId}-${sensor.sensorId}';
    _fetchSensorImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            imageLoading 
            ? const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
            : Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: sensorImage,
                  fit: BoxFit.cover
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    onPressed: () => showImageActionSheet(context),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      )
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
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
            
            const SizedBox(height: 40),
            const Text('PUT CHART HERE'),
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

  void _fetchSensorImage() async {
    if (!sensor.hasCustomImage) {
      return setState(() {
        imageLoading = false;
      });
    }

    appDocumentsDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocumentsDir.path}/$sensorImageFileName');
    if (await file.exists()) {
      return setState(() {
        sensorImage = FileImage(file);
        imageLoading = false;
      });
    }

    final success = await api.downloadSensorImage(identityManager.userId!, sensor.sensorId);

    if (!success) {
      await api.patchSensor(sensor.sensorId, {'hasCustomImage': false});
      return setState(() {
        imageLoading = false;
      });
    } else {
      setState(() {
        sensorImage = FileImage(file).evict();
        imageLoading = false;
      });
    }
  }

  void showImageActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              pickPhoto(ImageSource.camera);
            },
            child: const Text('Take a photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              pickPhoto(ImageSource.gallery);
            },
            child: const Text('Pick an image from your gallery'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              removePhoto();
            },
            child: const Text('Remove photo'),
          )
        ],
      ),
    );
  }

  void pickPhoto(imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) return;

    setState(() {
      imageLoading = true;
    });
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    await pickedFile.saveTo('${appDocumentsDir.path}/$sensorImageFileName');

    bool success = await api.uploadSensorImage(identityManager.userId!, sensor.sensorId);
    if (!success) {
      await File('${appDocumentsDir.path}/$sensorImageFileName').delete();
      Error.show(context, 'An error occurred while uploading the image. Please try again.');
      setState(() {
        imageLoading = false;
      });
      return;
    }

    if (!sensor.hasCustomImage) {
      final res = await api.patchSensor(sensor.sensorId, {'hasCustomImage': true});
      if (!res.success) {
        await File('${appDocumentsDir.path}/$sensorImageFileName').delete();
        // delete from gcs
        Error.show(context, 'An error occurred while uploading the image. Please try again.');
        setState(() {
          imageLoading = false;
        });
        return;
      }
    }
    
    // set to current sensorImage
    await FileImage(File('${appDocumentsDir.path}/$sensorImageFileName')).evict();
    setState(() {
      sensorImage = FileImage(File('${appDocumentsDir.path}/$sensorImageFileName'));
      imageLoading = false;
    });
  }

  void removePhoto() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocumentsDir.path}/$sensorImageFileName');

    if (!await file.exists()) return; // until i find a way to remove the removePhoto button if !sensor.hasCustomImage

    await file.delete();
    await api.patchSensor(sensor.sensorId, {'hasCustomImage': false});
    sensor.hasCustomImage = false;
    // need to delete from gcs here
    setState(() {
      sensorImage = const AssetImage('lib/assets/b.jpg');
    });
  }
}