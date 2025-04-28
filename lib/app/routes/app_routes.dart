import 'package:flutter/material.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/recognition/camera_screen.dart'; // <- Agrega esto

class AppRoutes {
  static const initialRoute = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/home': (BuildContext context) => const HomeScreen(),
      '/camera':
          (BuildContext context) => const CameraScreen(), // <- Nueva ruta
    };
  }
}
