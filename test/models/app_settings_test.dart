import 'package:flutter_test/flutter_test.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/webhook_config.dart';

void main() {
  group('AppSettings', () {
    test('should create AppSettings with default values', () {
      final settings = AppSettings();

      expect(settings.userName, '');
      expect(settings.webhookConfig, isA<WebhookConfig>());
    });

    test('should create AppSettings with custom values', () {
      final webhookConfig = WebhookConfig(
        url: 'https://example.com/webhook',
        method: 'POST',
        onStart: true,
        onStop: true,
        onAppOpen: false,
        onAppClose: false,
        sendDataInBody: true,
      );

      final settings = AppSettings(
        userName: 'Test User',
        webhookConfig: webhookConfig,
      );

      expect(settings.userName, 'Test User');
      expect(settings.webhookConfig, webhookConfig);
    });

    test('should convert to JSON correctly', () {
      final webhookConfig = WebhookConfig(
        url: 'https://example.com/webhook',
        method: 'POST',
        onStart: true,
        onStop: false,
        onAppOpen: true,
        onAppClose: false,
        sendDataInBody: true,
      );

      final settings = AppSettings(
        userName: 'Test User',
        webhookConfig: webhookConfig,
      );

      final json = settings.toJson();

      expect(json['userName'], 'Test User');
      expect(json['webhookConfig'], isA<Map<String, dynamic>>());
      expect(json['webhookConfig']['url'], 'https://example.com/webhook');
      expect(json['webhookConfig']['method'], 'POST');
      expect(json['webhookConfig']['onStart'], isTrue);
      expect(json['webhookConfig']['onStop'], isFalse);
      expect(json['webhookConfig']['onAppOpen'], isTrue);
      expect(json['webhookConfig']['onAppClose'], isFalse);
      expect(json['webhookConfig']['sendDataInBody'], isTrue);
    });

    test('should create from JSON correctly', () {
      final json = {
        'userName': 'Test User',
        'webhookConfig': {
          'url': 'https://example.com/webhook',
          'method': 'POST',
          'onStart': true,
          'onStop': false,
          'onAppOpen': true,
          'onAppClose': false,
          'sendDataInBody': true,
        },
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.userName, 'Test User');
      expect(settings.webhookConfig.url, 'https://example.com/webhook');
      expect(settings.webhookConfig.method, 'POST');
      expect(settings.webhookConfig.onStart, isTrue);
      expect(settings.webhookConfig.onStop, isFalse);
      expect(settings.webhookConfig.onAppOpen, isTrue);
      expect(settings.webhookConfig.onAppClose, isFalse);
      expect(settings.webhookConfig.sendDataInBody, isTrue);
    });

    test('should handle empty JSON', () {
      final json = <String, dynamic>{};

      final settings = AppSettings.fromJson(json);

      expect(settings.userName, '');
      expect(settings.webhookConfig, isA<WebhookConfig>());
    });

    test('should create copy with updated values', () {
      final originalSettings = AppSettings(userName: 'Original User');

      final updatedSettings = originalSettings.copyWith(
        userName: 'Updated User',
      );

      expect(updatedSettings.userName, 'Updated User');
      expect(updatedSettings.webhookConfig, originalSettings.webhookConfig);
    });
  });
}
