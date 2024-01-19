import 'dart:async';
import 'dart:ui';

import 'package:altor_assignment/services/sensor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStart,
          onBackground: onIosBackground),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: true, autoStart: true));
}

Position? _position;

List<AccelerometerEvent> _accelerometerValues = [];

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  startServices(service);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Altor",
            content: (_position == null)
                ? "Loading Speed"
                : "You are moving at ${_position!.speed.toStringAsFixed(2)} m/sec");
      }
    }

    print("Background service running");

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "Samsung",
      },
    );
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void startServices(ServiceInstance service) async {
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  _accelerometerSubscription = accelerometerEventStream().listen((event) {
    // Update the _accelerometerValues list with the latest event
    _accelerometerValues = [event];

    Map<String, double> eventData = {
      'x': event.x.toDouble(),
      'y': event.y.toDouble(),
      'z': event.z.toDouble(),
    };

    service.invoke(
      'updateAccelerometerData',
      {"data": eventData},
    );
  });

  List<GyroscopeEvent> _gyroscopeValues = [];
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
    _gyroscopeValues = [event];

    Map<String, double> eventData = {
      'x': event.x.toDouble(),
      'y': event.y.toDouble(),
      'z': event.z.toDouble(),
    };

    service.invoke(
      'updateGyroscopeData',
      {"data": eventData},
    );
  });

  List<MagnetometerEvent> _magnometerValues = [];
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  _magnetometerSubscription = magnetometerEventStream().listen((event) {
    _magnometerValues = [event];

    Map<String, double> eventData = {
      'x': event.x.toDouble(),
      'y': event.y.toDouble(),
      'z': event.z.toDouble(),
    };

    service.invoke(
      'updateMagnetometerData',
      {"data": eventData},
    );
  });

  late StreamSubscription<Position> _positionStreamSubscription;

  LocationPermission locationPermission = await Geolocator.checkPermission();

  if (locationPermission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  } else if (locationPermission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
  } else {
    if (await Geolocator.isLocationServiceEnabled()) {
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position? position) {
        _position = position;

        print(_position!.latitude);
        print(_position!.longitude);

        Map<String, double> eventData = {
          'lat': _position!.latitude,
          'long': _position!.longitude,
          'speed': _position!.speed
        };

        service.invoke(
          'updateLocationData',
          {"data": eventData},
        );
      });
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}
