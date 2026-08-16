import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tebiyu/core/router/app_router.dart';
import 'package:tebiyu/core/theme/app_theme.dart';
import 'package:tebiyu/firebase_options.dart';

/// Temporary theme mode holder.
///
/// Replaced by a Riverpod provider in P5.2 when account settings land.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: TebiyuApp()));
}

/// The root widget for Tebiyu.
class TebiyuApp extends ConsumerWidget {
  /// Creates the root widget.
  const TebiyuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'Tebiyu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          routerConfig: router,
        );
      },
    );
  }
}
