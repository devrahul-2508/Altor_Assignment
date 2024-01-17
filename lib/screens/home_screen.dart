import 'dart:async';

import 'package:flutter/material.dart';
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

  // StreamSubscription for accelerometer events
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  List<GyroscopeEvent> _gyroscopeValues = [];

  // StreamSubscription for accelerometer events

  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  List<MagnetometerEvent> _magnometerValues = [];
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  late StreamSubscription<Position> _positionStreamSubscription;
  Position? _position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _checkLocationPermission();
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        // Update the _accelerometerValues list with the latest event
        _accelerometerValues = [event];
      });
    });

    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      setState(() {
        _gyroscopeValues = [event];
      });
    });

    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      setState(() {
        _magnometerValues = [event];
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    _magnetometerSubscription.cancel();
  }

  void _startLocationFetchingStream() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position? position) {
        _position = position;
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
            Text(
              'Accelerometer Data:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            if (_accelerometerValues.isNotEmpty)
              Text(
                'X: ${_accelerometerValues[0].x.toStringAsFixed(2)}, '
                'Y: ${_accelerometerValues[0].y.toStringAsFixed(2)}, '
                'Z: ${_accelerometerValues[0].z.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              )
            else
              Text('No data available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Gyrosocopic Data:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            if (_gyroscopeValues.isNotEmpty)
              Text(
                'X: ${_gyroscopeValues[0].x.toStringAsFixed(2)}, '
                'Y: ${_gyroscopeValues[0].y.toStringAsFixed(2)}, '
                'Z: ${_gyroscopeValues[0].z.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              )
            else
              Text('No data available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Magnometer Data:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            if (_magnometerValues.isNotEmpty)
              Text(
                'X: ${_magnometerValues[0].x.toStringAsFixed(2)}, '
                'Y: ${_magnometerValues[0].y.toStringAsFixed(2)}, '
                'Z: ${_magnometerValues[0].z.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              )
            else
              Text('No data available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (_position != null)
              Text(
                ' ${_position?.latitude}, '
                ' ${_position?.longitude}, ',
                style: TextStyle(fontSize: 16),
              )
            else
              Text('No data available', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
