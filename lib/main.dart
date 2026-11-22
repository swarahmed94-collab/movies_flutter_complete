
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using FlutterFire configuration.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local Hive storage.
  final hive = await HiveService.initialize();

  // Configure application dependencies.
  await configureDependencies(hive);

  // Launch the Movies application.
  runApp(const MoviesApp());
}
