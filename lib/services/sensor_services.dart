import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

final StreamController<AccelerometerEvent> _accelerometerController =
    StreamController<AccelerometerEvent>();

Stream<AccelerometerEvent> get accelerometerStream =>
    _accelerometerController.stream;

final StreamController<MagnetometerEvent> _magnometerController =
    StreamController<MagnetometerEvent>();

Stream<MagnetometerEvent> get magnometerStream => _magnometerController.stream;

final StreamController<GyroscopeEvent> _gyroController =
    StreamController<GyroscopeEvent>();

Stream<GyroscopeEvent> get gyroSteam => _gyroController.stream;

void startSensorStream() {
  accelerometerEventStream().listen((event) {
    _accelerometerController.add(event);
  });

  magnetometerEventStream().listen((event) {
    _magnometerController.add(event);
  });

  gyroscopeEventStream().listen((event) {
    _gyroController.add(event);
  });
}

void disposeSensorStream() {
  _accelerometerController.close();
  _magnometerController.close();
  _gyroController.close();
}
