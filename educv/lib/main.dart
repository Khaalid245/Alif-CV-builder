import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable google_fonts network fetching — use system fonts only
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load correct .env based on build mode
  try {
    await dotenv.load(
      fileName: kReleaseMode
          ? 'assets/env/.env.production'
          : 'assets/env/.env',
    );
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

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
