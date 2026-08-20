import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'services/shizuku_service.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/info_popup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PCLogoApp());
}

class PCLogoApp extends StatelessWidget {
  const PCLogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C3AED);
    return ChangeNotifierProvider(
      create: (_) => ShizukuService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PC Logo',
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF0B0C10),
          useMaterial3: true,
          cardTheme: const CardThemeData(color: Color(0xFF151820)),
        ),
        home: const StartupGate(),
      ),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _splash = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1150), () async {
      if (!mounted) return;
      setState(() => _splash = false);
      await _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;
    final shizuku = context.read<ShizukuService>();
    await shizuku.startMonitoring();
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final showInfo = !(prefs.getBool('info_seen') ?? false);
    if (showInfo && mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const InfoPopup(),
      );
      await prefs.setBool('info_seen', true);
    }
    if (!mounted) return;
    if (!shizuku.isReady) {
      final ok = await shizuku.requestPermission();
      if (!ok && mounted) await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_splash) return SplashScreen(onDone: () {});
    return const HomeScreen();
  }
}
