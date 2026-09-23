import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'services/offline_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final offlineService = OfflineService();
  await offlineService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider.value(value: offlineService),
      ],
      child: const MaziShalaApp(),
    ),
  );
}

class MaziShalaApp extends StatelessWidget {
  const MaziShalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'माझी शाळा - Mazi Shala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: langProvider.locale,
      supportedLocales: const [
        Locale('mr', ''), // Marathi (Default)
        Locale('en', ''), // English
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
