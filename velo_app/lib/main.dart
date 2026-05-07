import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'router/app_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VeloApp(),
    ),
  );
}

class VeloApp extends ConsumerStatefulWidget {
  const VeloApp({super.key});

  @override
  ConsumerState<VeloApp> createState() => _VeloAppState();
}

class _VeloAppState extends ConsumerState<VeloApp> {
  @override
  void initState() {
    super.initState();
    HomeWidget.widgetClicked.listen(_launchFromWidget);
    _checkForWidgetLaunch();
  }

  void _checkForWidgetLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _launchFromWidget(uri);
  }

  void _launchFromWidget(Uri? uri) {
    if (uri != null && uri.scheme == 'velo' && uri.host == 'add_fuel') {
      final carId = uri.queryParameters['carId'];
      if (carId != null && carId.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(routerProvider).push('/car/$carId?action=add_fuel');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Velo Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'),
      ],
      locale: const Locale('en', 'GB'),
    );
  }
}
