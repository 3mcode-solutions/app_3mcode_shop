import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_3mcode_shop/app.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await AppConfig.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}
