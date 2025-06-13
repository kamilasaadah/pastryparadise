import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_helper.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'widgets/adaptive_widgets.dart' as adaptive;

void main() async {
  // Pastikan Flutter diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientasi yang diizinkan (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Jalankan aplikasi dengan provider tema
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Pastikan status bar mengikuti tema
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppTheme.darkBackgroundColor,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppTheme.backgroundColor,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );

    // Selalu gunakan MaterialApp sebagai root, bahkan untuk Cupertino
    // Ini memastikan MaterialLocalizations tersedia
    return MaterialApp(
      title: 'Pastry Paradise',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      // Pastikan localization didukung
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Simulasi loading (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // Check apakah user sudah login
    final user = await DatabaseHelper.instance.getCurrentUser();

    if (!mounted) return;

    // Navigasi ke halaman yang sesuai
    Navigator.of(context).pushReplacement(
      adaptive.adaptivePageRoute(
        builder: (context) => user != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Konten splash screen
    final splashContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/1046/1046857.png',
            height: 120,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          const Text(
            'Pastry Paradise',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const adaptive.AdaptiveProgressIndicator(
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );

    return adaptive.AdaptiveScaffold(
      backgroundColor: AppTheme.primaryColor,
      body: splashContent,
    );
  }
}

