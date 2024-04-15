import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';

Future<void> uploadFileToDrive(String filePath, String name) async {

  final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "crypto-metric-401417",
    "private_key_id": "390a490f9cb77a5b93da2c1e2c7dc156a87da7cb",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDCIbFPGuAEbsY9\np15A6gEDkvmLqPwyJaEiXIa8g0q/BvJ4NWVk0T/MG0O5KljEUZEgvsuVkNyQWuZK\n1IyKOQUMml6Iv05r7mEt5C+fYwloYlR//ax80Uhp5NoN6Pt9lGIDsvI4X9Y/AO+W\no0Y3TA314nUcqvyVGyhTylEqGAlHRrd9BojGqZ4JGwMPKfvn/I0FvVo6DLx6PnJv\nZXReBYkFfsh8lupHSQ6kZv7AX33jZPgQamSW6GvEaQ2ptw8lKmXy+b/xvbANP3SX\nb8L9TOOwvmlQk8FSIUATPYmGKCjNYfRpfgJJEzlW5WF0P6x9A/GtJZtsJaw0jVyo\niqZemFRzAgMBAAECggEAXAFD203NZcxqP8YWsYU1vc/mXP5VqB6VY4eeg7Flt2s/\ndyE3ULSrG7zAN/2N3F0b/vzt15C0N+YcxtI9WTT046g1rXGdZSGxBOLkfxGc38/a\nZF6BZRZ6z1Ua0wTcTAQK/93LVlR1YZ677hSrroFpDGOrRU70LmaUkkGMffquSwyw\nCbDFIi2xc+4neIC6SdVtfIk87gTFTYh0IfQV39EOp3DjwWR8IB4KW5mdeePo9oc+\nudcJcXz6zFTUJaeXclqt7xmCi2Kiae1L1aH5TBMftOHx90nmPS3Zi0Y/8rEhAIVG\n2koxgyP59syMa2aMRvYQx5hjVP9ymDtCygmlOVDnwQKBgQD7dI5/h/iPGJb7Nidb\nnuA4azJ02unldMO/oqI0fiMXNCIneOEJDRTM7aa4t3B0S+wc+agnowyHK5y0vZuD\nHQnF4qMILSFTdZEi76xC+KQNCcZfAof5n6DAVOuPu9Tq4bK+v0qYmXyQatkHIhCg\nujZ3GkoXGmw0DtA2lNF2Ic+YOQKBgQDFo+iRLrYr58hHwGoGbwbXNV925oYDvZf1\n785tXy89n+m1I7AZCbkAD2dIaabYlJokw7JabAq9H3HHce2+p74+ue7aitchLcF1\niKjWYO9LOoWmM9ZTW/WDuS3IZVV8ey1ikkpC+E39AG9dDs4Fv41sWb8bXoa791ZD\nJP7KeO8aCwKBgE3Wi9HghknNg9cpsU9ERAZS8KCJr4Ou/HVS48E6FqS1J6luWsLR\ngNHa8xQU/MOTSPjDM5FpgJRLJMwyMXSJxZ+zA2KhjcJnD1FwPbPRgf7jOrvoba0R\nA9LltrGcpFE9Ina3gmDwikWuPZZeriUC359IzQyPylTnDP8IXDqkRr3JAoGBAKVo\njZ7cSkiqnps2dUXXLBF3MONxAR4mUgTZ45jzvbTEnjMkoCAEXBmpypX3HlVK4Ur9\noco9fCtWIsJ6HjCfcQBMWpP6+RtikPPOIQfybrM2Ul6MKcbwQqUwmRmLfaVF7fD+\nYDp2V8bz00A9wL1c2H6jCeddEERGN6LQVpGb7viLAoGASG+yzminAGMKfdQVoBvY\nhh05vUeaVZX3vfQE5Edc9wlBQ2J+XJ2nb7/BB2HFjBkpupbHHi9vs4X4u3+EPDk8\nnJoDHsAc5poNf743E3YPyf9lCNxUdzM/QgfHp/Q5db2cB/n2MRf8tuxrwBCJdYRL\nzE0Sf+SGupFC/20mAeU4z3A=\n-----END PRIVATE KEY-----\n",
    "client_email": "tracking-app@crypto-metric-401417.iam.gserviceaccount.com",
    "client_id": "104056513674077058183",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/tracking-app%40crypto-metric-401417.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
  );

  final client = http.Client();
  final credentials = await clientViaServiceAccount(
    serviceAccountCredentials,
    ['https://www.googleapis.com/auth/drive'],
  );

  final driveApi = drive.DriveApi(credentials);
  final file = File(filePath);
  final media = drive.Media(file.openRead(), file.lengthSync());

  final driveFile = drive.File();
  driveFile.name = name;

  try {
    final createdFile = await driveApi.files.create(driveFile, uploadMedia: media);
    print('File uploaded successfully!');
    final fileId = createdFile.id;

    final fileUrl = 'https://drive.google.com/file/d/$fileId';
    log(fileUrl);
    final permission = drive.Permission();
    permission.emailAddress = "f20213098@hyderabad.bits-pilani.ac.in";
    permission.type = 'user'; // 'user' or 'group'

    permission.role = 'writer'; // 'owner', 'organizer', 'fileOrganizer', 'writer', 'commenter', 'reader'

    await driveApi.permissions.create(permission, fileId!);
  } catch (e) {
    log('Error uploading file: $e');
  } finally {
    client.close();
  }
}

void main() {
  runApp(const MaterialApp(home: SensorApp()));
}

class SensorApp extends StatefulWidget {
  const SensorApp({super.key});

  @override
  _SensorAppState createState() => _SensorAppState();
}

class _SensorAppState extends State<SensorApp> {
  List<List<dynamic>> sensorData = [];
  List<List<dynamic>> timestamps = [];
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  bool isRecording = false;
  bool isPopupVisible = false;

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  void startRecording() {
    sensorData.clear();
    timestamps.clear();
    sensorData.add(['Date','Timestamp', 'X', 'Y', 'Z', 'Label']);
    timestamps.add(['Timestamp']);
    setState(() {
      isRecording = true;
      isPopupVisible = true;
    });
    _accelerometerSubscription = Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) => accelerometerEvents.first).listen((event) {
      setState(() {
        sensorData.add([DateTime.now().millisecondsSinceEpoch, event.x, event.y, event.z, "Accelero"]);
      });
    });
    _gyroscopeSubscription = Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) => gyroscopeEvents.first).listen((event) {
      setState(() {
        sensorData.add([DateTime.now().millisecondsSinceEpoch, event.x, event.y, event.z, "Gyro"]);
      });
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isPopupVisible = false;
      });
    });
  }

  void stopRecording() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    setState(() {
      isRecording = false;
      isPopupVisible = true;
    });
    saveToCSV(sensorData, 'sensor_data.csv');
    saveToCSV(timestamps, 'timestamps.csv');
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isPopupVisible = false;
      });
    });
  }

  void addTimestamp() {
    DateTime now = DateTime.now();
    setState(() {
      timestamps.add([
        DateFormat('yyyy-MM-dd').format(now), // Format date as YYYY-MM-DD
        DateFormat('hh:mm:ss:SSS a').format(now) // Format time as HH:MM:SS AM/PM
      ]);
    });
  }

  Future<void> saveToCSV(List<List<dynamic>> data, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$fileName');

    // Format timestamps in the 'HH:mm:ss a' format
    final timeFormat = DateFormat('HH:mm:ss:SSS a');

    // Format dates in the 'yyyy-MM-dd' format
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Format each row in the data list
    final formattedData = data.map((row) {
      if (row.isNotEmpty && row.first is int) {
        // Assuming the first element in each row is the timestamp
        final timestamp = DateTime.fromMillisecondsSinceEpoch(row.first);
        final formattedTime = timeFormat.format(timestamp);
        final formattedDate = dateFormat.format(timestamp);
        return [formattedDate, formattedTime, ...row.sublist(1)];
      } else {
        return row;
      }
    }).toList();

    // Convert formatted data to CSV string
    String csvData = const ListToCsvConverter().convert(formattedData);

    // Write CSV data to file
    await file.writeAsString(csvData);

    // Upload file to Google Drive
    await uploadFileToDrive('$path/$fileName', fileName);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor App')),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isRecording ? null : startRecording,
                  child: const Text('Start Recording'),
                ),
                ElevatedButton(
                  onPressed: isRecording ? stopRecording : null,
                  child: const Text('Stop Recording'),
                ),
                ElevatedButton(
                  onPressed: addTimestamp,
                  child: const Text('Add Timestamp'),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: isPopupVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: const Offset(0.0, 0.0),
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.fastOutSlowIn,
              )),
              child: Container(
                width: double.infinity,
                color: Colors.black.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          isRecording ? 'Recording Started' : 'Recording Stopped',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isRecording ? 'Recording data...' : 'Data saved successfully.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
