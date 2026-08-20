import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/request_handler.dart';
import '../models/log_entry.dart';
import '../models/server_config.dart';
import '../services/config_service.dart';
import '../services/port_service.dart';
import '../services/shizuku_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/info_popup.dart';
import '../widgets/server_status_card.dart';
import 'log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final RequestHandler _handler;
  late final PortService _ports;
  late final ConfigService _config;
  final List<LogEntry> _logs = [];
  GameVariant _game = GameVariant.normal;
  int? _port;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final shizuku = context.read<ShizukuService>();
    _handler = RequestHandler(onLog: _appendLog);
    _ports = PortService();
    _config = ConfigService(shizuku);
    shizuku.addListener(_shizukuChanged);
  }

  void _appendLog(LogEntry entry) {
    if (!mounted) return;
    setState(() {
      _logs.add(entry);
      if (_logs.length > 500) _logs.removeAt(0);
    });
  }

  void _shizukuChanged() {
    final service = context.read<ShizukuService>();
    if (!service.isReady && _handler.isRunning) {
      unawaited(_stopInternal(showMessage: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shizuku terputus. Server dihentikan.')));
      }
    }
  }

  Future<void> _startInternal() async {
    final shizuku = context.read<ShizukuService>();
    if (!shizuku.isReady) {
      final ok = await shizuku.requestPermission();
      if (!ok) {
        if (mounted) await SystemNavigator.pop();
        return;
      }
    }

    setState(() => _busy = true);
    try {
      final port = await _ports.findAvailablePort();
      final config = ServerConfig(
        port: port,
        game: _game,
        configPath: _game == GameVariant.normal ? AppConstants.normalConfigPath : AppConstants.maxConfigPath,
      );
      await _config.writeConfig(config);
      await _handler.start(port);
      setState(() => _port = port);
      _appendLog(LogEntry(timestamp: DateTime.now(), level: LogLevel.success, message: 'Config ditulis ke ${config.configPath}'));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Service aktif di port $port')));
    } catch (e) {
      _appendLog(LogEntry(timestamp: DateTime.now(), level: LogLevel.error, message: 'Start gagal: $e'));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start gagal: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopInternal({bool showMessage = true}) async {
    final shizuku = context.read<ShizukuService>();
    setState(() => _busy = true);
    try {
      await _handler.stop();
      final path = _game == GameVariant.normal ? AppConstants.normalConfigPath : AppConstants.maxConfigPath;
      if (shizuku.isReady) await _config.deleteConfig(path);
      _port = null;
      _appendLog(LogEntry(timestamp: DateTime.now(), level: LogLevel.info, message: 'localconfig.json dihapus'));
      if (showMessage && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service dihentikan.')));
    } catch (e) {
      _appendLog(LogEntry(timestamp: DateTime.now(), level: LogLevel.error, message: 'Stop gagal: $e'));
      if (showMessage && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stop gagal: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle() async {
    if (_handler.isRunning) {
      await _stopInternal();
    } else {
      await _startInternal();
    }
  }

  Future<void> _showGamePicker() async {
    final choice = await showDialog<GameVariant>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih game'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioListTile(value: GameVariant.normal, groupValue: _game, onChanged: (v) => Navigator.pop(context, v), title: const Text('Free Fire Normal')),
          RadioListTile(value: GameVariant.max, groupValue: _game, onChanged: (v) => Navigator.pop(context, v), title: const Text('Free Fire MAX')),
        ]),
      ),
    );
    if (choice != null && !_handler.isRunning) setState(() => _game = choice);
  }

  Future<bool> _ensureShizuku() async {
    final shizuku = context.read<ShizukuService>();
    await shizuku.refresh();
    if (shizuku.isReady) return true;
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Shizuku diperlukan'),
        content: const Text('Sambungkan Shizuku lalu berikan izin PC Logo. Jika ditolak, aplikasi akan ditutup.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back / Close')),
          FilledButton(onPressed: () async => Navigator.pop(context, await shizuku.requestPermission()), child: const Text('Sambungkan')),
        ],
      ),
    );
    if (result != true && mounted) {
      await SystemNavigator.pop();
    }
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final shizuku = context.watch<ShizukuService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Logs',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogScreen(entries: List.unmodifiable(_logs), onClear: () => setState(_logs.clear)))),
            icon: const Icon(Icons.article_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ServerStatusCard(ready: shizuku.isReady, running: _handler.isRunning, port: _port),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                title: const Text('Game target'),
                subtitle: Text(_game == GameVariant.normal ? 'Free Fire Normal' : 'Free Fire MAX'),
                leading: const Icon(Icons.sports_esports_outlined),
                trailing: IconButton(onPressed: _handler.isRunning ? null : _showGamePicker, icon: const Icon(Icons.swap_horiz)),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedActionButton(
              label: _handler.isRunning ? 'Stop Service' : 'Start Service',
              icon: _handler.isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              busy: _busy,
              onPressed: shizuku.isReady ? _toggle : _ensureShizuku,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => showDialog<void>(context: context, builder: (_) => const InfoPopup()),
              icon: const Icon(Icons.info_outline),
              label: const Text('About PC Logo'),
            ),
            const SizedBox(height: 20),
            const Text('Server diagnostik menyediakan /Ping dan /health. Endpoint login game tidak diproses.'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    final shizuku = context.read<ShizukuService>();
    shizuku.removeListener(_shizukuChanged);
    unawaited(_handler.stop());
    super.dispose();
  }
}
