import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/task_session.dart';

// Service for managing macOS system tray
class MenuBarService {
  static final MenuBarService _instance = MenuBarService._internal();
  factory MenuBarService() => _instance;
  MenuBarService._internal();

  Timer? _updateTimer;
  BuildContext? _context;
  SystemTray? _systemTray;
  Menu? _menu;

  void initialize(BuildContext context) {
    _context = context;
    _setupSystemTray();
    _startUpdateTimer();
  }

  Future<void> _setupSystemTray() async {
    _systemTray = SystemTray();
    _menu = Menu();

    // Set system tray icon
    await _systemTray!.initSystemTray(
      title: "Time Trapp",
      iconPath: "assets/icon.png", // You'll need to add an icon
    );

    // Create menu items
    await _menu!.buildFrom([
      MenuItemLabel(
        label: 'Time Trapp',
        onClicked: (menuItem) => _showApp(),
      ),
      MenuItemLabel(
        label: 'Timer Status',
        onClicked: (menuItem) => _showStatus(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Start Session',
        onClicked: (menuItem) => _startSession(),
      ),
      MenuItemLabel(
        label: 'Stop Session',
        onClicked: (menuItem) => _stopSession(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) => _quitApp(),
      ),
    ]);

    await _systemTray!.setContextMenu(_menu!);
    await _systemTray!.setToolTip("Time Trapp - Time Tracker");
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSystemTray();
    });
  }

  Future<void> _updateSystemTray() async {
    if (_context == null || _menu == null) return;

    final timerProvider = Provider.of<TimerProvider>(_context!, listen: false);
    final currentSession = timerProvider.currentSession;
    final isRunning = timerProvider.isRunning;
    final elapsedTime = timerProvider.formattedElapsedTime;

    // Update system tray tooltip with current status
    await _systemTray?.setToolTip(
      "Time Trapp\n"
      "Status: ${isRunning ? "Running" : "Stopped"}\n"
      "Time: $elapsedTime\n"
      "${currentSession != null ? "Purpose: ${currentSession.purpose}" : ""}",
    );

    // Update menu items
    await _menu!.buildFrom([
      MenuItemLabel(
        label: 'Time Trapp - $elapsedTime',
        onClicked: (menuItem) => _showApp(),
      ),
      MenuItemLabel(
        label: 'Status: ${isRunning ? "Running" : "Stopped"}',
        onClicked: (menuItem) => _showStatus(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: isRunning ? 'Stop Session' : 'Start Session',
        onClicked: (menuItem) => isRunning ? _stopSession() : _startSession(),
      ),
      if (currentSession != null) ...[
        MenuItemLabel(
          label: 'Purpose: ${currentSession.purpose}',
          onClicked: (menuItem) => _showStatus(),
        ),
        MenuItemLabel(
          label: 'Goal: ${currentSession.goal}',
          onClicked: (menuItem) => _showStatus(),
        ),
      ],
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) => _quitApp(),
      ),
    ]);

    await _systemTray!.setContextMenu(_menu!);
  }

  void _showApp() {
    // Show the main application window
    // This would need to be implemented based on your window management
  }

  void _showStatus() {
    if (_context == null) return;
    
    final timerProvider = Provider.of<TimerProvider>(_context!, listen: false);
    final currentSession = timerProvider.currentSession;
    final isRunning = timerProvider.isRunning;
    final elapsedTime = timerProvider.formattedElapsedTime;

    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: const Text('Timer Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${isRunning ? "Running" : "Stopped"}'),
            Text('Time: $elapsedTime'),
            if (currentSession != null) ...[
              const SizedBox(height: 8),
              Text('Purpose: ${currentSession.purpose}'),
              Text('Goal: ${currentSession.goal}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startSession() {
    if (_context == null) return;
    
    final timerProvider = Provider.of<TimerProvider>(_context!, listen: false);
    
    // Show a simple dialog to get session details
    showDialog(
      context: _context!,
      builder: (context) => _SessionDialog(
        onStart: (purpose, goal, link) {
          timerProvider.startSession(
            purpose: purpose,
            goal: goal,
            link: link,
          );
        },
      ),
    );
  }

  void _stopSession() {
    if (_context == null) return;
    
    final timerProvider = Provider.of<TimerProvider>(_context!, listen: false);
    timerProvider.stopSession();
  }

  void _quitApp() {
    // Quit the application
    exit(0);
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}

// Simple dialog for starting a session from menu bar
class _SessionDialog extends StatefulWidget {
  final Function(String purpose, String goal, String? link) onStart;

  const _SessionDialog({required this.onStart});

  @override
  State<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<_SessionDialog> {
  final _purposeController = TextEditingController();
  final _goalController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    _goalController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _purposeController,
            decoration: const InputDecoration(
              labelText: 'Purpose *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Goal *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              labelText: 'Link (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_purposeController.text.trim().isNotEmpty &&
                _goalController.text.trim().isNotEmpty) {
              widget.onStart(
                _purposeController.text.trim(),
                _goalController.text.trim(),
                _linkController.text.trim().isEmpty
                    ? null
                    : _linkController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
