import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:to_do_flutter_app/app_shell.dart';
import 'package:to_do_flutter_app/core/settings/app_settings.dart';
import 'package:to_do_flutter_app/core/theme/app_theme.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(const Duration(milliseconds: 800));

  final appSettings = await AppSettings.create();

  runApp(ZenStudioApp(appSettings: appSettings));
  FlutterNativeSplash.remove();
}

class ZenStudioApp extends StatelessWidget {
  const ZenStudioApp({super.key, required this.appSettings});

  final AppSettings appSettings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider<AppSettings>.value(value: appSettings),
      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, _) {
          ThemeMode themeMode;
          switch (settings.themeMode) {
            case ThemeModePreference.system:
              themeMode = ThemeMode.system;
              break;
            case ThemeModePreference.light:
              themeMode = ThemeMode.light;
              break;
            case ThemeModePreference.dark:
              themeMode = ThemeMode.dark;
              break;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zen Studio',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const AppShell(),
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}
