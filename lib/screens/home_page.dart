import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_compass_app/neu_circle.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Builder(
        builder: (context) {
          if (_hasPermission) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        },
      ),
    );
  }

  // compass widget
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          // for the error
          if (snapshot.hasError) {
            return Text("Error readinf heading" + snapshot.error.toString());
          }

          // for the connection
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          double? direction = snapshot.data!.heading;

          if (direction == null) {
            return const Center(
              child: Text("Device does not have sensors"),
            );
          }

          return NeuCircle(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(25.0),
                child: Transform.rotate(
                    angle: direction * (pi / 180) * -1,
                    child: Image.asset(
                      "assets/compass.png",
                      color: Colors.white,
                      fit: BoxFit.fill,
                    )),
              ),
            ),
          );
        });
  }

  // Permission widget
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text("Request Permission"),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
