import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import '../providers/timer_provider.dart';

class TrayService with TrayListener {
  static bool _isInitialized = false;

  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      final trayService = TrayService();
      await TrayManager.instance.setIcon('assets/icon.png');
      await TrayManager.instance.setToolTip('Time Trapp - Timer');

      // Set up the tray menu
      await _createTrayMenu(context);

      // Register the tray listener
      TrayManager.instance.addListener(trayService);

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
    // This would need to be implemented with a global context
    print('Show status dialog');
  }

  void _toggleSession() {
    // This would need to be implemented with a global context
    print('Toggle session');
  }

  void _quitApp() {
    exit(0);
  }

  static void dispose() {
    _isInitialized = false;
  }
}
