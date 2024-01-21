import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 

  @override
  void initState() {
    super.initState();

    //Check if Location Permissions has been enabled
    _checkLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkLocationPermission() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {

      // Requesting for location Permission
      await Geolocator.requestPermission();

      // Checking if user has allowed the requested permission or not
      _checkLocationPermission();
    } else if (locationPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      FlutterBackgroundService().invoke('getLocation');
    }
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

            //Data for Current Time
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

            //Acclerometer Data
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

            // Gyroscope Data
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

            // Magnetometer Data
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

                //Location Data
            const Text(
              'Location and Speed',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on("updateLocationData"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data?['data'];

                    //Checking if location has not been turned off -->
                    if (data != null) {
                      var latititude = data['lat'];
                      var longitude = data['long'];
                      var speed = data['speed'];
                      var altitude = data['altitude'];

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
                      // Location Turned off -->
                      return const Text(
                        "Location Updates stopped. Turn on Location",
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      );
                    }
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
