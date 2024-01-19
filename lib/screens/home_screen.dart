import 'dart:async';

import 'package:altor_assignment/services/sensor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store accelerometer data
  List<AccelerometerEvent> _accelerometerValues = [];

  // // StreamSubscription for accelerometer events
  // late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  List<GyroscopeEvent> _gyroscopeValues = [];

  // // StreamSubscription for accelerometer events

  // late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  List<MagnetometerEvent> _magnometerValues = [];
  // late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  late StreamSubscription<Position> _positionStreamSubscription;
  Position? _position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startSensorStream();
    _checkLocationPermission();
    // _accelerometerSubscription = accelerometerEventStream().listen((event) {
    //   setState(() {
    //     // Update the _accelerometerValues list with the latest event
    //     _accelerometerValues = [event];
    //   });
    // });

    // _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
    //   setState(() {
    //     _gyroscopeValues = [event];
    //   });
    // });

    // _magnetometerSubscription = magnetometerEventStream().listen((event) {
    //   setState(() {
    //     _magnometerValues = [event];
    //   });
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _accelerometerSubscription.cancel();
    // _gyroscopeSubscription.cancel();
    // _magnetometerSubscription.cancel();

    //disposeSensorStream();
  }

  void _startLocationFetchingStream() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position? position) {
        setState(() {
          _position = position;
        });
      });
    } else {
      await Geolocator.openLocationSettings();
    }
  }

  void _checkLocationPermission() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else if (locationPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }

    _startLocationFetchingStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    const Text(
                      "Welcome to Altor Test",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Current Time",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      date.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Accelerometer Data:',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>?>(
                stream:
                    FlutterBackgroundService().on("updateAccelerometerData"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    var x = data['data']['x'];
                    var y = data['data']['y'];
                    var z = data['data']['z'];

                    return Text(
                      'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    );
                  } else {
                    return const Text('Loading.....',
                        style: TextStyle(fontSize: 16));
                  }
                }),
            const SizedBox(height: 10),
            const Text(
              'Gyroscope Data:',
              style: TextStyle(fontSize: 20),
            ),
            StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on("updateGyroscopeData"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    var x = data['data']['x'];
                    var y = data['data']['y'];
                    var z = data['data']['z'];

                    return Text(
                      'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    );
                  } else {
                    return const Text('Loading.....',
                        style: TextStyle(fontSize: 16));
                  }
                }),
            const SizedBox(height: 10),
            const Text(
              'Magnometer Data:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on("updateMagnetometerData"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    var x = data['data']['x'];
                    var y = data['data']['y'];
                    var z = data['data']['z'];

                    return Text(
                      'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    );
                  } else {
                    return const Text('Loading.....',
                        style: TextStyle(fontSize: 16));
                  }
                }),
            const Text(
              'Location and Speed',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on("updateLocationData"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    var latititude = data['data']['lat'];
                    var longitude = data['data']['long'];
                    var speed = data['data']['speed'];
                    var altitude = data['data']['altitude'];

                    return Column(
                      children: [
                        Text(
                          'Lat: $latititude, Long: $longitude',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Speed: ${speed.toStringAsFixed(2)} m/sec',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Altitude: ${altitude.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Loading.....',
                        style: TextStyle(fontSize: 16));
                  }
                })
          ],
        ),
      ),
    );
  }
}
