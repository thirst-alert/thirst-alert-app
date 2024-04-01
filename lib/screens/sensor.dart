import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'alert.dart';
import '../theme.dart';
import 'package:thirst_alert/sensor_manager.dart' show Sensor;
import 'information.dart';
import 'sensor/measurement.dart';
import 'package:mime/mime.dart';

final picker = ImagePicker();

class SensorScreen extends StatefulWidget {
  final Sensor sensor;
  const SensorScreen({super.key, required this.sensor});

  @override
  SensorScreenState createState() => SensorScreenState();
}

class SensorScreenState extends State<SensorScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isNameUpdating = false;
  bool isThirstLevelUpdating = false;

  late Sensor sensor;

  @override
  void initState() {
    sensor = widget.sensor;
    sensor.updateStateCallback = () => setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            sensor.isImageLoading
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
                  image: sensor.image,
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
                    padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                    child: Focus(
                      child: TextField(
                        controller: _nameController,
                        enabled: !isNameUpdating,
                        maxLength: 18,
                        decoration: InputDecoration(
                          hintText: sensor.name,
                          hintStyle: const TextStyle(color: text),
                          suffixIcon: const Icon(Icons.edit),
                          counterText: '',
                        )
                      ),
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          setState(() => isNameUpdating = true);
                          sensor.updateName(_nameController.text)
                            .then((success) {
                              if (!success) {
                                Error.show(context, 'An error occurred while updating the name. Please try again.');
                              }
                              _nameController.text = '';
                              setState(() => isNameUpdating = false);
                            });
                        }
                      },
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
                  child: DropdownButton<int>(
                    value: sensor.thirstLevel,
                    onChanged: !isThirstLevelUpdating
                      ? (thirstLevel) {
                        setState(() => isThirstLevelUpdating = true);
                        sensor.updateThirstLevel(thirstLevel!)
                          .then((success) {
                            if (!success) {
                              Error.show(context, 'An error occurred while updating the thirst level. Please try again.');
                            }
                            setState(() => isThirstLevelUpdating = false);
                          });
                      }
                      : null,
                    items: {
                      'Low': 0,
                      'Medium': 1,
                      'High': 2
                    }.entries.map<DropdownMenuItem<int>>((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.value,
                        enabled: sensor.thirstLevel != entry.value,
                        child: Text(entry.key)
                      );
                    }).toList()
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              ////
              child: SensorChart(sensorId: sensor.sensorId),
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

  void showImageActionSheet(BuildContext context) {
    List<CupertinoActionSheetAction> actions = [
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
    ];

    if (sensor.hasCustomImage) {
      actions.add(
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            sensor.removeImage()
              .then((success) => {
                if (!success) {
                  Error.show(context, 'An error occurred while removing the image. Please try again.')
                }
              });
          },
          child: const Text('Remove photo'),
        ),
      );
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: actions,
      ),
    );
  }

  void pickPhoto(imageSource) async {
    final XFile? pickedImage = await picker.pickImage(source: imageSource);
    if (pickedImage == null) return;

    final String? mimeType = lookupMimeType(pickedImage.path);
    if(mimeType == null || !mimeType.startsWith('image')) {
      Error.show(context, 'Image not supported');
      return;
    }

    final bool success = await sensor.updateImage(pickedImage, mimeType);
    if (!success) {
      Error.show(context, 'An error occurred while uploading the image. Please try again.');
    }
  }
}