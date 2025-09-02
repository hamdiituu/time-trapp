import 'package:flutter_test/flutter_test.dart';
import 'package:time_trapp/models/webhook_config.dart';

void main() {
  group('WebhookConfig', () {
    test('should create WebhookConfig with default values', () {
      final config = WebhookConfig(url: '');

      expect(config.url, '');
      expect(config.method, 'POST');
      expect(config.onStart, false);
      expect(config.onStop, false);
      expect(config.onAppOpen, false);
      expect(config.onAppClose, false);
      expect(config.sendDataInBody, true);
      expect(config.isConfigured, isFalse);
    });

    test('should create WebhookConfig with custom values', () {
      final config = WebhookConfig(
        url: 'https://example.com/webhook',
        method: 'GET',
        onStart: true,
        onStop: true,
        onAppOpen: false,
        onAppClose: false,
        sendDataInBody: false,
      );

      expect(config.url, 'https://example.com/webhook');
      expect(config.method, 'GET');
      expect(config.onStart, isTrue);
      expect(config.onStop, isTrue);
      expect(config.onAppOpen, isFalse);
      expect(config.onAppClose, isFalse);
      expect(config.sendDataInBody, isFalse);
      expect(config.isConfigured, isTrue);
    });

    test('should return isConfigured as false when url is empty', () {
      final config = WebhookConfig(
        url: '',
        onStart: true,
        onStop: true,
      );

      expect(config.isConfigured, isFalse);
    });

    test('should return isConfigured as true when url is provided', () {
      final config = WebhookConfig(
        url: 'https://example.com/webhook',
        onStart: false,
        onStop: false,
      );

      expect(config.isConfigured, isTrue);
    });

    test('should convert to JSON correctly', () {
      final config = WebhookConfig(
        url: 'https://example.com/webhook',
        method: 'PUT',
        onStart: true,
        onStop: false,
        onAppOpen: true,
        onAppClose: false,
        sendDataInBody: false,
      );

      final json = config.toJson();

      expect(json['url'], 'https://example.com/webhook');
      expect(json['method'], 'PUT');
      expect(json['onStart'], isTrue);
      expect(json['onStop'], isFalse);
      expect(json['onAppOpen'], isTrue);
      expect(json['onAppClose'], isFalse);
      expect(json['sendDataInBody'], isFalse);
    });

    test('should create from JSON correctly', () {
      final json = {
        'url': 'https://example.com/webhook',
        'method': 'PATCH',
        'onStart': false,
        'onStop': true,
        'onAppOpen': false,
        'onAppClose': true,
        'sendDataInBody': true,
      };

      final config = WebhookConfig.fromJson(json);

      expect(config.url, 'https://example.com/webhook');
      expect(config.method, 'PATCH');
      expect(config.onStart, isFalse);
      expect(config.onStop, isTrue);
      expect(config.onAppOpen, isFalse);
      expect(config.onAppClose, isTrue);
      expect(config.sendDataInBody, isTrue);
    });

    test('should handle empty JSON', () {
      final json = <String, dynamic>{};

      final config = WebhookConfig.fromJson(json);

      expect(config.url, '');
      expect(config.method, 'POST');
      expect(config.onStart, isFalse);
      expect(config.onStop, isFalse);
      expect(config.onAppOpen, isFalse);
      expect(config.onAppClose, isFalse);
      expect(config.sendDataInBody, isTrue);
    });

    test('should create copy with updated values', () {
      final originalConfig = WebhookConfig(
        url: 'https://original.com',
        method: 'POST',
        onStart: true,
      );

      final updatedConfig = originalConfig.copyWith(
        url: 'https://updated.com',
        method: 'GET',
        onStop: true,
      );

      expect(updatedConfig.url, 'https://updated.com');
      expect(updatedConfig.method, 'GET');
      expect(updatedConfig.onStart, isTrue);
      expect(updatedConfig.onStop, isTrue);
      expect(updatedConfig.onAppOpen, isFalse);
      expect(updatedConfig.onAppClose, isFalse);
      expect(updatedConfig.sendDataInBody, isTrue);
    });

    test('should validate HTTP methods', () {
      final validMethods = ['GET', 'POST', 'PUT', 'PATCH'];
      
      for (final method in validMethods) {
        final config = WebhookConfig(url: 'https://example.com', method: method);
        expect(config.method, method);
      }
    });
  });
}
