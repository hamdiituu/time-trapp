import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import '../providers/timer_provider.dart';
import '../screens/session_start_screen.dart';

class TrayService with TrayListener {
  static bool _isInitialized = false;
  static Timer? _updateTimer;
  static BuildContext? _globalContext;

  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      _globalContext = context;
      final trayService = TrayService();
      await TrayManager.instance.setIcon('assets/icon_2.png');
      await TrayManager.instance.setToolTip('Time Trapp - Timer');

      // Set up the tray menu
      await _createTrayMenu(context);

      // Register the tray listener
      TrayManager.instance.addListener(trayService);

      // Start update timer (every 5 seconds)
      _startUpdateTimer();

      _isInitialized = true;
      print('Tray initialized successfully');
    } catch (e) {
      print('Error initializing tray: $e');
    }
  }

  static Future<void> _createTrayMenu(BuildContext context) async {
    try {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      final isRunning = timerProvider.isRunning;
      final elapsedTime = timerProvider.formattedElapsedTime;
      final currentSession = timerProvider.currentSession;

      final menu = Menu(
        items: [
          MenuItem(
            key: 'status',
            label: 'Time Trapp - $elapsedTime',
          ),
          MenuItem(
            key: 'start_stop',
            label: isRunning ? 'Seansı Durdur' : 'Seans Başlat',
          ),
          if (currentSession != null) ...[
            MenuItem(
              key: 'purpose',
              label: 'Amaç: ${currentSession.purpose}',
            ),
            MenuItem(
              key: 'goal',
              label: 'Hedef: ${currentSession.goal}',
            ),
          ],
          MenuItem(
            key: 'quit',
            label: 'Çıkış',
          ),
        ],
      );

      await TrayManager.instance.setContextMenu(menu);
    } catch (e) {
      print('Error creating tray menu: $e');
    }
  }

  static Future<void> updateMenu(BuildContext context) async {
    if (!_isInitialized) return;
    await _createTrayMenu(context);
  }

  static void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_globalContext != null) {
        updateMenu(_globalContext!);
      }
    });
  }

  @override
  void onTrayIconMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'status':
        _showStatusDialog();
        break;
      case 'start_stop':
        _toggleSession();
        break;
      case 'quit':
        _quitApp();
        break;
    }
  }

  void _showStatusDialog() {
    if (_globalContext == null) return;
    
    final timerProvider = Provider.of<TimerProvider>(_globalContext!, listen: false);
    final currentSession = timerProvider.currentSession;
    final isRunning = timerProvider.isRunning;
    final elapsedTime = timerProvider.formattedElapsedTime;

    showDialog(
      context: _globalContext!,
      builder: (context) => AlertDialog(
        title: const Text('Timer Durumu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durum: ${isRunning ? "Çalışıyor" : "Durduruldu"}'),
            Text('Süre: $elapsedTime'),
            if (currentSession != null) ...[
              const SizedBox(height: 8),
              Text('Amaç: ${currentSession.purpose}'),
              Text('Hedef: ${currentSession.goal}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _toggleSession() {
    if (_globalContext == null) return;
    
    final timerProvider = Provider.of<TimerProvider>(_globalContext!, listen: false);
    
    if (timerProvider.isRunning) {
      // Stop session
      timerProvider.stopSession();
    } else {
      // Start session - show full screen
      _showStartSessionScreen();
    }
  }

  void _showStartSessionScreen() {
    if (_globalContext == null) return;
    
    Navigator.of(_globalContext!).push(
      MaterialPageRoute(
        builder: (context) => StartSessionScreen(),
      ),
    );
  }

  void _quitApp() {
    exit(0);
  }

  static void dispose() {
    _updateTimer?.cancel();
    _isInitialized = false;
    _globalContext = null;
  }
}
