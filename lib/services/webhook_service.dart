import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_session.dart';
import '../models/webhook_config.dart';

// Service for handling webhook requests
class WebhookService {
  // Send webhook for session start
  static Future<void> sendSessionStartWebhook(
    TaskSession session,
    WebhookConfig config, {
    String? userName,
  }) async {
    if (!config.onStart || !config.isConfigured) return;

    await _sendWebhook(
      config,
      'session_start',
      {
        'event': 'session_start',
        'sessionId': session.id,
        'purpose': session.purpose,
        'goal': session.goal,
        'link': session.link,
        'startTime': session.startTime.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
        if (userName != null) 'userName': userName,
      },
    );
  }

  // Send webhook for session stop
  static Future<void> sendSessionStopWebhook(
    TaskSession session,
    WebhookConfig config, {
    String? userName,
  }) async {
    if (!config.onStop || !config.isConfigured) return;

    await _sendWebhook(
      config,
      'session_stop',
      {
        'event': 'session_stop',
        'sessionId': session.id,
        'purpose': session.purpose,
        'goal': session.goal,
        'link': session.link,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'duration': session.duration?.inMilliseconds,
        'formattedDuration': session.formattedDuration,
        'timestamp': DateTime.now().toIso8601String(),
        if (userName != null) 'userName': userName,
      },
    );
  }

  // Send webhook for app open
  static Future<void> sendAppOpenWebhook(WebhookConfig config, {String? userName}) async {
    if (!config.onAppOpen || !config.isConfigured) return;

    await _sendWebhook(
      config,
      'app_open',
      {
        'event': 'app_open',
        'timestamp': DateTime.now().toIso8601String(),
        if (userName != null) 'userName': userName,
      },
    );
  }

  // Send webhook for app close
  static Future<void> sendAppCloseWebhook(WebhookConfig config, {String? userName}) async {
    if (!config.onAppClose || !config.isConfigured) return;

    await _sendWebhook(
      config,
      'app_close',
      {
        'event': 'app_close',
        'timestamp': DateTime.now().toIso8601String(),
        if (userName != null) 'userName': userName,
      },
    );
  }

  // Generic webhook sender
  static Future<void> _sendWebhook(
    WebhookConfig config,
    String eventType,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse(config.url);
      http.Response response;

      if (config.sendDataInBody) {
        // Send data in request body
        final headers = {
          'Content-Type': 'application/json',
        };

        switch (config.method.toUpperCase()) {
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: jsonEncode(data),
            );
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: jsonEncode(data),
            );
            break;
          case 'PATCH':
            response = await http.patch(
              uri,
              headers: headers,
              body: jsonEncode(data),
            );
            break;
          default:
            print('Unsupported HTTP method for body: ${config.method}');
            return;
        }
      } else {
        // Send data as query parameters
        final queryParams = data.map((key, value) => MapEntry(key, value.toString()));
        final uriWithParams = uri.replace(queryParameters: queryParams);

        switch (config.method.toUpperCase()) {
          case 'GET':
            response = await http.get(uriWithParams);
            break;
          case 'POST':
            response = await http.post(uriWithParams);
            break;
          case 'PUT':
            response = await http.put(uriWithParams);
            break;
          case 'PATCH':
            response = await http.patch(uriWithParams);
            break;
          default:
            print('Unsupported HTTP method for query: ${config.method}');
            return;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Webhook sent successfully for $eventType');
      } else {
        print('Webhook failed for $eventType: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending webhook for $eventType: $e');
    }
  }

  // Test webhook configuration
  static Future<bool> testWebhook(WebhookConfig config) async {
    try {
      final testData = {
        'event': 'test',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'This is a test webhook from Time Trapp',
      };

      await _sendWebhook(config, 'test', testData);
      return true;
    } catch (e) {
      print('Webhook test failed: $e');
      return false;
    }
  }
}
