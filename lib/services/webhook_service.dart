import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/task_session.dart';
import '../models/webhook_config.dart';

// Service for handling webhook requests
class WebhookService {
  static http.Client? _client;

  // Set custom client for testing
  static void setClient(http.Client client) {
    _client = client;
  }

  // Get client instance
  static http.Client get _httpClient => _client ?? http.Client();
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
            response = await _httpClient.post(
              uri,
              headers: headers,
              body: jsonEncode(data),
            );
            break;
          case 'PUT':
            response = await _httpClient.put(
              uri,
              headers: headers,
              body: jsonEncode(data),
            );
            break;
          case 'PATCH':
            response = await _httpClient.patch(
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
            response = await _httpClient.get(uriWithParams);
            break;
          case 'POST':
            response = await _httpClient.post(uriWithParams);
            break;
          case 'PUT':
            response = await _httpClient.put(uriWithParams);
            break;
          case 'PATCH':
            response = await _httpClient.patch(uriWithParams);
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
  static Future<Map<String, dynamic>> testWebhook(WebhookConfig config) async {
    if (!config.isConfigured) {
      return {
        'success': false,
        'error': 'Webhook URL is not configured',
        'details': 'Please enter a valid webhook URL'
      };
    }

    // Validate URL format
    try {
      final uri = Uri.parse(config.url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return {
          'success': false,
          'error': 'Invalid URL format',
          'details': 'URL must start with http:// or https://'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Invalid URL format',
        'details': 'Please check the URL format'
      };
    }
    
    try {
      final testData = {
        'event': 'test',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'This is a test webhook from Time Trapp',
        'app': 'Time Trapp',
        'version': '1.0.0',
      };

      final uri = Uri.parse(config.url);
      http.Response response;

      // Create a client with timeout and special settings for localhost
      final client = http.Client();
      
      // Special handling for localhost URLs
      final isLocalhost = uri.host == 'localhost' || 
                         uri.host == '127.0.0.1' || 
                         uri.host.startsWith('192.168.') ||
                         uri.host.startsWith('10.') ||
                         uri.host.startsWith('172.');
      
      try {
        if (config.sendDataInBody) {
          final headers = {'Content-Type': 'application/json'};
          
          switch (config.method.toUpperCase()) {
            case 'POST':
              response = await client.post(
                uri, 
                headers: headers, 
                body: jsonEncode(testData)
              ).timeout(const Duration(seconds: 10));
              break;
            case 'PUT':
              response = await client.put(
                uri, 
                headers: headers, 
                body: jsonEncode(testData)
              ).timeout(const Duration(seconds: 10));
              break;
            case 'PATCH':
              response = await client.patch(
                uri, 
                headers: headers, 
                body: jsonEncode(testData)
              ).timeout(const Duration(seconds: 10));
              break;
            default:
              return {
                'success': false,
                'error': 'Unsupported HTTP method',
                'details': 'Method ${config.method} is not supported for body requests'
              };
          }
        } else {
          final queryParams = testData.map((key, value) => MapEntry(key, value.toString()));
          final uriWithParams = uri.replace(queryParameters: queryParams);
          
          switch (config.method.toUpperCase()) {
            case 'GET':
              response = await client.get(uriWithParams).timeout(const Duration(seconds: 10));
              break;
            case 'POST':
              response = await client.post(uriWithParams).timeout(const Duration(seconds: 10));
              break;
            case 'PUT':
              response = await client.put(uriWithParams).timeout(const Duration(seconds: 10));
              break;
            case 'PATCH':
              response = await client.patch(uriWithParams).timeout(const Duration(seconds: 10));
              break;
            default:
              return {
                'success': false,
                'error': 'Unsupported HTTP method',
                'details': 'Method ${config.method} is not supported'
              };
          }
        }

        final success = response.statusCode >= 200 && response.statusCode < 300;
        
        return {
          'success': success,
          'statusCode': response.statusCode,
          'responseBody': response.body.length > 200 
              ? '${response.body.substring(0, 200)}...' 
              : response.body,
          'message': success 
              ? 'Webhook test successful!' 
              : 'Webhook test failed with status ${response.statusCode}'
        };
      } finally {
        client.close();
      }
    } on SocketException catch (e) {
      String errorMessage = 'Network error';
      String details = 'Unable to establish network connection';
      
      // Special handling for localhost errors
      final isLocalhost = config.url.contains('localhost') || 
                         config.url.contains('127.0.0.1') ||
                         config.url.contains('192.168.') ||
                         config.url.contains('10.') ||
                         config.url.contains('172.');
      
      if (e.message.contains('Connection refused')) {
        errorMessage = 'Connection refused';
        if (isLocalhost) {
          details = 'The local server at ${config.url} is not running. Please start your local server first.';
        } else {
          details = 'The server at ${config.url} is not running or not accepting connections';
        }
      } else if (e.message.contains('Operation not permitted')) {
        errorMessage = 'Connection not permitted';
        if (isLocalhost) {
          details = 'Cannot connect to localhost. Try using 127.0.0.1 instead of localhost, or check if your local server is running.';
        } else {
          details = 'Network access to ${config.url} is blocked or the server is not accessible';
        }
      } else if (e.message.contains('No route to host')) {
        errorMessage = 'No route to host';
        if (isLocalhost) {
          details = 'Cannot reach localhost. Make sure your local server is running and accessible.';
        } else {
          details = 'Cannot reach the server at ${config.url}. Check if the URL is correct';
        }
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'details': details,
        'originalError': e.toString()
      };
    } on http.ClientException catch (e) {
      String errorMessage = 'Connection failed';
      String details = 'Unable to connect to the webhook URL';
      
      // Special handling for localhost errors
      final isLocalhost = config.url.contains('localhost') || 
                         config.url.contains('127.0.0.1') ||
                         config.url.contains('192.168.') ||
                         config.url.contains('10.') ||
                         config.url.contains('172.');
      
      if (e.message.contains('Connection refused')) {
        errorMessage = 'Connection refused';
        if (isLocalhost) {
          details = 'The local server at ${config.url} is not running. Please start your local server first.';
        } else {
          details = 'The server at ${config.url} is not running or not accepting connections';
        }
      } else if (e.message.contains('Operation not permitted')) {
        errorMessage = 'Connection not permitted';
        if (isLocalhost) {
          details = 'Cannot connect to localhost. Try using 127.0.0.1 instead of localhost, or check if your local server is running.';
        } else {
          details = 'Network access to ${config.url} is blocked or the server is not accessible';
        }
      } else if (e.message.contains('No route to host')) {
        errorMessage = 'No route to host';
        if (isLocalhost) {
          details = 'Cannot reach localhost. Make sure your local server is running and accessible.';
        } else {
          details = 'Cannot reach the server at ${config.url}. Check if the URL is correct';
        }
      } else if (e.message.contains('Connection timed out')) {
        errorMessage = 'Connection timeout';
        if (isLocalhost) {
          details = 'The local server at ${config.url} did not respond in time. Make sure it is running and accessible.';
        } else {
          details = 'The server at ${config.url} did not respond in time';
        }
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'details': details,
        'originalError': e.toString()
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error',
        'details': 'An unexpected error occurred: ${e.toString()}',
        'originalError': e.toString()
      };
    }
  }
}
