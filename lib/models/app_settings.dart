import 'webhook_config.dart';

// Application settings model
class AppSettings {
  final String userName;
  final WebhookConfig webhookConfig;
  final bool isFirstLaunch;

  AppSettings({
    this.userName = '',
    WebhookConfig? webhookConfig,
    this.isFirstLaunch = true,
  }) : webhookConfig = webhookConfig ?? WebhookConfig(url: '');

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'webhookConfig': webhookConfig.toJson(),
      'isFirstLaunch': isFirstLaunch,
    };
  }

  // Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userName: json['userName'] ?? '',
      webhookConfig: json['webhookConfig'] != null 
          ? WebhookConfig.fromJson(json['webhookConfig'])
          : WebhookConfig(url: ''),
      isFirstLaunch: json['isFirstLaunch'] ?? true,
    );
  }

  // Create a copy with updated fields
  AppSettings copyWith({
    String? userName,
    WebhookConfig? webhookConfig,
    bool? isFirstLaunch,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      webhookConfig: webhookConfig ?? this.webhookConfig,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
