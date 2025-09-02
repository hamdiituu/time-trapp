// Task session model for tracking work sessions
class TaskSession {
  final String id;
  final String purpose; // What are you working on
  final String goal; // What is your goal
  final String? link; // Optional link
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;

  TaskSession({
    required this.id,
    required this.purpose,
    required this.goal,
    this.link,
    required this.startTime,
    this.endTime,
    this.duration,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purpose': purpose,
      'goal': goal,
      'link': link,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inMilliseconds,
    };
  }

  // Create from JSON
  factory TaskSession.fromJson(Map<String, dynamic> json) {
    return TaskSession(
      id: json['id'],
      purpose: json['purpose'],
      goal: json['goal'],
      link: json['link'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
    );
  }

  // Create a copy with updated fields
  TaskSession copyWith({
    String? id,
    String? purpose,
    String? goal,
    String? link,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
  }) {
    return TaskSession(
      id: id ?? this.id,
      purpose: purpose ?? this.purpose,
      goal: goal ?? this.goal,
      link: link ?? this.link,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
    );
  }

  // Check if session is currently active
  bool get isActive => endTime == null;

  // Get formatted duration
  String get formattedDuration {
    if (duration == null) return '0:00:00';
    
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
