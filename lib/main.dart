import 'package:flutter/material.dart';
import 'app/routes/app_routes.dart';

void main() {
  runApp(const NumjiApp());
}

class NumjiApp extends StatelessWidget {
  const NumjiApp({super.key}); // Esta es la forma moderna

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Numji',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}
