import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive local storage ───────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Firebase init ────────────────────────────────────────────────────────
  // NOTE: options: DefaultFirebaseOptions.currentPlatform is omitted because
  // firebase_options.dart is a placeholder until `flutterfire configure` is
  // run. Once the real options file is generated, restore:
  //   options: DefaultFirebaseOptions.currentPlatform
  await Firebase.initializeApp();

  // ── Crashlytics ──────────────────────────────────────────────────────────
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    const ProviderScope(
      child: TutorMeApp(),
    ),
  );
}

class TutorMeApp extends ConsumerWidget {
  const TutorMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TutorMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
