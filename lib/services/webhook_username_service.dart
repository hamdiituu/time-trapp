import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'username_service.dart';

// Service for managing webhook username with automatic system detection
class WebhookUsernameService {
  static const String _usernameKey = 'webhook_username';
  static const String _useSystemUsernameKey = 'use_system_username';
  static const String _lastSystemUsernameKey = 'last_system_username';

  // Get the username to use for webhooks
  static Future<String> getWebhookUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useSystemUsername = prefs.getBool(_useSystemUsernameKey) ?? true;
      
      if (useSystemUsername) {
        // Try to get current system username
        final currentSystemUsername = await UsernameService.getSystemUsername();
        
        // Check if system username has changed
        final lastSystemUsername = prefs.getString(_lastSystemUsernameKey);
        
        if (lastSystemUsername != currentSystemUsername) {
          // System username has changed, update it
          await prefs.setString(_lastSystemUsernameKey, currentSystemUsername);
          await prefs.setString(_usernameKey, currentSystemUsername);
          print('System username changed from "$lastSystemUsername" to "$currentSystemUsername"');
        }
        
        return currentSystemUsername;
      } else {
        // Use manually set username
        return prefs.getString(_usernameKey) ?? 'User';
      }
    } catch (e) {
      print('Error getting webhook username: $e');
      return 'User';
    }
  }

  // Set manual username (disables automatic system detection)
  static Future<void> setManualUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setBool(_useSystemUsernameKey, false);
      print('Manual username set: $username');
    } catch (e) {
      print('Error setting manual username: $e');
    }
  }

  // Enable automatic system username detection
  static Future<void> enableSystemUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemUsernameKey, true);
      
      // Get current system username and save it
      final systemUsername = await UsernameService.getSystemUsername();
      await prefs.setString(_usernameKey, systemUsername);
      await prefs.setString(_lastSystemUsernameKey, systemUsername);
      
      print('System username detection enabled: $systemUsername');
    } catch (e) {
      print('Error enabling system username: $e');
    }
  }

  // Check if using system username
  static Future<bool> isUsingSystemUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_useSystemUsernameKey) ?? true;
    } catch (e) {
      print('Error checking system username setting: $e');
      return true;
    }
  }

  // Get current stored username (regardless of source)
  static Future<String> getStoredUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey) ?? 'User';
    } catch (e) {
      print('Error getting stored username: $e');
      return 'User';
    }
  }

  // Check if system username has changed and update if needed
  static Future<bool> checkAndUpdateSystemUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useSystemUsername = prefs.getBool(_useSystemUsernameKey) ?? true;
      
      if (!useSystemUsername) {
        return false; // Not using system username, no update needed
      }
      
      final currentSystemUsername = await UsernameService.getSystemUsername();
      final lastSystemUsername = prefs.getString(_lastSystemUsernameKey);
      
      if (lastSystemUsername != currentSystemUsername) {
        // System username has changed
        await prefs.setString(_lastSystemUsernameKey, currentSystemUsername);
        await prefs.setString(_usernameKey, currentSystemUsername);
        print('System username updated from "$lastSystemUsername" to "$currentSystemUsername"');
        return true; // Username was updated
      }
      
      return false; // No update needed
    } catch (e) {
      print('Error checking system username: $e');
      return false;
    }
  }

  // Initialize webhook username service (call on app startup)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useSystemUsername = prefs.getBool(_useSystemUsernameKey);
      
      if (useSystemUsername == null) {
        // First time setup - enable system username by default
        await enableSystemUsername();
      } else if (useSystemUsername) {
        // Check if system username has changed
        await checkAndUpdateSystemUsername();
      }
    } catch (e) {
      print('Error initializing webhook username service: $e');
    }
  }

  // Get system environment variables for username (platform-specific)
  static Future<String?> getSystemEnvironmentUsername() async {
    try {
      if (Platform.isWindows) {
        return await _getWindowsEnvironmentUsername();
      } else if (Platform.isMacOS || Platform.isLinux) {
        return await _getUnixEnvironmentUsername();
      }
    } catch (e) {
      print('Error getting system environment username: $e');
    }
    return null;
  }

  // Get username from Windows environment variables
  static Future<String?> _getWindowsEnvironmentUsername() async {
    try {
      // Try USERNAME environment variable
      final username = Platform.environment['USERNAME'];
      if (username != null && username.isNotEmpty) {
        return username;
      }
      
      // Try USER environment variable
      final user = Platform.environment['USER'];
      if (user != null && user.isNotEmpty) {
        return user;
      }
    } catch (e) {
      print('Error getting Windows environment username: $e');
    }
    return null;
  }

  // Get username from Unix environment variables (macOS/Linux)
  static Future<String?> _getUnixEnvironmentUsername() async {
    try {
      // Try USER environment variable
      final user = Platform.environment['USER'];
      if (user != null && user.isNotEmpty) {
        return user;
      }
      
      // Try LOGNAME environment variable
      final logname = Platform.environment['LOGNAME'];
      if (logname != null && logname.isNotEmpty) {
        return logname;
      }
    } catch (e) {
      print('Error getting Unix environment username: $e');
    }
    return null;
  }

  // Get comprehensive username (tries multiple sources)
  static Future<String> getComprehensiveUsername() async {
    try {
      // First try system environment variables
      final envUsername = await getSystemEnvironmentUsername();
      if (envUsername != null && envUsername.isNotEmpty) {
        return envUsername;
      }
      
      // Fallback to UsernameService
      return await UsernameService.getSystemUsername();
    } catch (e) {
      print('Error getting comprehensive username: $e');
      return 'User';
    }
  }
}
