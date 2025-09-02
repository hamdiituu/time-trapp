import 'dart:io';
import 'dart:convert';

// Service for getting system username across different platforms
class UsernameService {
  // Get system username for current platform
  static Future<String> getSystemUsername() async {
    try {
      if (Platform.isWindows) {
        return await _getWindowsUsername();
      } else if (Platform.isMacOS) {
        return await _getMacOSUsername();
      } else if (Platform.isLinux) {
        return await _getLinuxUsername();
      } else {
        // Fallback for other platforms
        return await _getFallbackUsername();
      }
    } catch (e) {
      print('Error getting system username: $e');
      return 'User';
    }
  }

  // Get username on Windows
  static Future<String> _getWindowsUsername() async {
    try {
      // Try using whoami command first
      final result = await Process.run('whoami', []);
      if (result.exitCode == 0) {
        String username = result.stdout.toString().trim();
        // Remove domain prefix if present (e.g., "DOMAIN\username" -> "username")
        if (username.contains('\\')) {
          username = username.split('\\').last;
        }
        return username;
      }
    } catch (e) {
      print('Error with whoami command: $e');
    }

    try {
      // Fallback: try using echo %USERNAME%
      final result = await Process.run('cmd', ['/c', 'echo %USERNAME%']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with echo %USERNAME%: $e');
    }

    return 'User';
  }

  // Get username on macOS
  static Future<String> _getMacOSUsername() async {
    try {
      // Try using whoami command
      final result = await Process.run('whoami', []);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with whoami command: $e');
    }

    try {
      // Fallback: try using id command
      final result = await Process.run('id', ['-un']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with id command: $e');
    }

    try {
      // Another fallback: try using logname command
      final result = await Process.run('logname', []);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with logname command: $e');
    }

    return 'User';
  }

  // Get username on Linux
  static Future<String> _getLinuxUsername() async {
    try {
      // Try using whoami command
      final result = await Process.run('whoami', []);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with whoami command: $e');
    }

    try {
      // Fallback: try using id command
      final result = await Process.run('id', ['-un']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with id command: $e');
    }

    try {
      // Another fallback: try using logname command
      final result = await Process.run('logname', []);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with logname command: $e');
    }

    return 'User';
  }

  // Fallback method for unsupported platforms
  static Future<String> _getFallbackUsername() async {
    try {
      // Try using whoami command as universal fallback
      final result = await Process.run('whoami', []);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Error with fallback whoami command: $e');
    }

    return 'User';
  }

  // Get user's full name (if available)
  static Future<String> getSystemUserFullName() async {
    try {
      if (Platform.isWindows) {
        return await _getWindowsFullName();
      } else if (Platform.isMacOS) {
        return await _getMacOSFullName();
      } else if (Platform.isLinux) {
        return await _getLinuxFullName();
      } else {
        return await getSystemUsername();
      }
    } catch (e) {
      print('Error getting system user full name: $e');
      return await getSystemUsername();
    }
  }

  // Get full name on Windows
  static Future<String> _getWindowsFullName() async {
    try {
      // Try using wmic command to get full name
      final result = await Process.run('wmic', ['useraccount', 'where', 'name="%USERNAME%"', 'get', 'fullname', '/value']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.startsWith('FullName=')) {
            final fullName = line.substring(9).trim();
            if (fullName.isNotEmpty) {
              return fullName;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting Windows full name: $e');
    }

    return await getSystemUsername();
  }

  // Get full name on macOS
  static Future<String> _getMacOSFullName() async {
    try {
      // Try using dscl command to get full name
      final username = await getSystemUsername();
      final result = await Process.run('dscl', ['.', 'read', '/Users/$username', 'RealName']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('RealName:')) {
            final fullName = line.split('RealName:').last.trim();
            if (fullName.isNotEmpty) {
              return fullName;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting macOS full name: $e');
    }

    return await getSystemUsername();
  }

  // Get full name on Linux
  static Future<String> _getLinuxFullName() async {
    try {
      // Try using getent command to get full name
      final username = await getSystemUsername();
      final result = await Process.run('getent', ['passwd', username]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final parts = output.split(':');
        if (parts.length >= 5) {
          final fullName = parts[4].trim();
          if (fullName.isNotEmpty && fullName != username) {
            return fullName;
          }
        }
      }
    } catch (e) {
      print('Error getting Linux full name: $e');
    }

    return await getSystemUsername();
  }
}
