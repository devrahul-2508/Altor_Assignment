// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class AltorModel {
  final List<double> accelerometer;
  final List<double> gyroscope;
  final List<double> magnometer;
  final List<double> coordinates;
  final double speed;
  final double altitude;
  AltorModel({
    required this.accelerometer,
    required this.gyroscope,
    required this.magnometer,
    required this.coordinates,
    required this.speed,
    required this.altitude,
  });

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'accelerometer': accelerometer,
      'gyroscope': gyroscope,
      'magnometer': magnometer,
      'coordinates': coordinates,
      'speed': speed,
      'altitude': altitude,
    };
  }

  factory AltorModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> map) {
    return AltorModel(
      accelerometer: List<double>.from((map['accelerometer'] as List<double>)),
      gyroscope: List<double>.from((map['gyroscope'] as List<double>)),
      magnometer: List<double>.from((map['magnometer'] as List<double>)),
      coordinates: List<double>.from((map['coordinates'] as List<double>)),
      speed: map['speed'] as double,
      altitude: map['altitude'] as double,
    );
  }
}
