import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // List to store accelerometer data
  List<AccelerometerEvent> _accelerometerValues = [];

  // StreamSubscription for accelerometer events
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  _accelerometerSubscription = accelerometerEventStream().listen((event) {
    // Update the _accelerometerValues list with the latest event
    _accelerometerValues = [event];
  });
  DartPluginRegistrant.ensureInitialized();
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
          content: 'X: ${_accelerometerValues[0].x.toStringAsFixed(2)}, '
              'Y: ${_accelerometerValues[0].y.toStringAsFixed(2)}, '
              'Z: ${_accelerometerValues[0].z.toStringAsFixed(2)}',
        );
      }
    }

    print("Background service running");

    service.invoke('update');
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
