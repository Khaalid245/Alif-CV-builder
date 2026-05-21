import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local development config. Release builds should pass public config
  // with --dart-define instead of bundling environment files.
  try {
    if (!kReleaseMode) {
      await dotenv.load(fileName: 'assets/env/.env');
    }
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Optimize performance for keyboard animations
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
