import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'webhook_service.dart';

// Service for handling app lifecycle events
class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  BuildContext? _context;
  bool _hasSentAppOpenWebhook = false;

  void initialize(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (_context == null) return;

    final timerProvider = Provider.of<TimerProvider>(_context!, listen: false);
    final webhookConfig = timerProvider.settings.webhookConfig;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Send app close webhook when app is paused or detached
        if (webhookConfig.onAppClose && webhookConfig.isConfigured) {
          WebhookService.sendAppCloseWebhook(
            webhookConfig,
            userName: timerProvider.settings.userName,
          );
        }
        // Reset the flag when app is closed
        _hasSentAppOpenWebhook = false;
        break;
      case AppLifecycleState.resumed:
        // Send app open webhook when app is resumed (only once per session)
        if (webhookConfig.onAppOpen && 
            webhookConfig.isConfigured && 
            !_hasSentAppOpenWebhook) {
          WebhookService.sendAppOpenWebhook(
            webhookConfig,
            userName: timerProvider.settings.userName,
          );
          _hasSentAppOpenWebhook = true;
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., phone call, notification panel)
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }
}
