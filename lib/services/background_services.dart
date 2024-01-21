import 'dart:async';
import 'dart:ui';

import 'package:altor_assignment/models/altor_model.dart';
import 'package:altor_assignment/services/database_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

List<GyroscopeEvent> _gyroscopeValues = [];

List<MagnetometerEvent> _magnometerValues = [];

StreamSubscription<Position>? _positionStreamSubscription;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp();

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

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Altor",
            content: (_position == null)
                ? "Loading Speed"
                : "You are moving at ${_position!.speed.toStringAsFixed(2)} m/sec");
      }

      service.on('getLocation').listen((event) {
        print("Invoking location");

        print("Enabled");
        _positionStreamSubscription =
            Geolocator.getPositionStream().listen((Position? position) {
          _position = position;

          print(_position!.latitude);

          Map<String, double> eventData = {
            'lat': _position!.latitude,
            'long': _position!.longitude,
            'speed': _position!.speed,
            "altitude": _position!.altitude
          };

          service.invoke(
            'updateLocationData',
            {"data": eventData},
          );
        }, onError: (e) {
          _position = null;
        });
      });

      if (_position != null) {
        var altorModel = AltorModel(accelerometer: [
          _accelerometerValues[0].x,
          _accelerometerValues[0].y,
          _accelerometerValues[0].z,
        ], gyroscope: [
          _gyroscopeValues[0].x,
          _gyroscopeValues[0].y,
          _gyroscopeValues[0].z,
        ], magnometer: [
          _magnometerValues[0].x,
          _magnometerValues[0].y,
          _magnometerValues[0].z,
        ], coordinates: [
          _position!.latitude,
          _position!.longitude
        ], speed: _position!.speed, altitude: _position!.altitude);
        await DatabaseService().addAltorModel(altorModel);
      }
    }

    print("Background Service Running ");

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
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
}
