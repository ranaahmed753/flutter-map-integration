import 'package:flutter/material.dart';
import 'package:map/core/services/map_service.dart';
import 'package:map/root_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapService.instance..setupMap()),
      ],
      child: const RootApp(),
    ),
  );
}
