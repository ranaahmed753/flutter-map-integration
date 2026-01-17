import 'package:flutter/material.dart';
import 'package:map/screens/rider_tracking_map_screen.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
    ), // home: RiderTrackingMapScreen(),
    home: RiderTrackingMapScreen(),
    );
  }
}