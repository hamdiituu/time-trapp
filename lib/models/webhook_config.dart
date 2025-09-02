// Webhook configuration model
class WebhookConfig {
  final String url;
  final String method; // GET, POST, PUT, etc.
  final bool sendDataInBody; // true for body, false for query params
  final bool onStart;
  final bool onStop;
  final bool onAppOpen;
  final bool onAppClose;

  WebhookConfig({
    required this.url,
    this.method = 'POST',
    this.sendDataInBody = true,
    this.onStart = false,
    this.onStop = false,
    this.onAppOpen = false,
    this.onAppClose = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'method': method,
      'sendDataInBody': sendDataInBody,
      'onStart': onStart,
      'onStop': onStop,
      'onAppOpen': onAppOpen,
      'onAppClose': onAppClose,
    };
  }

  // Create from JSON
  factory WebhookConfig.fromJson(Map<String, dynamic> json) {
    return WebhookConfig(
      url: json['url'],
      method: json['method'] ?? 'POST',
      sendDataInBody: json['sendDataInBody'] ?? true,
      onStart: json['onStart'] ?? false,
      onStop: json['onStop'] ?? false,
      onAppOpen: json['onAppOpen'] ?? false,
      onAppClose: json['onAppClose'] ?? false,
    );
  }

  // Create a copy with updated fields
  WebhookConfig copyWith({
    String? url,
    String? method,
    bool? sendDataInBody,
    bool? onStart,
    bool? onStop,
    bool? onAppOpen,
    bool? onAppClose,
  }) {
    return WebhookConfig(
      url: url ?? this.url,
      method: method ?? this.method,
      sendDataInBody: sendDataInBody ?? this.sendDataInBody,
      onStart: onStart ?? this.onStart,
      onStop: onStop ?? this.onStop,
      onAppOpen: onAppOpen ?? this.onAppOpen,
      onAppClose: onAppClose ?? this.onAppClose,
    );
  }

  // Check if webhook is configured
  bool get isConfigured => url.isNotEmpty;

  // Check if any event is enabled
  bool get hasEnabledEvents => onStart || onStop || onAppOpen || onAppClose;
}
