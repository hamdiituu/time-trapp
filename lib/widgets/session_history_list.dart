import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../models/task_session.dart';

// Widget for displaying session history
class SessionHistoryList extends StatefulWidget {
  final Function(TaskSession)? onSessionTap;
  final int maxItems;

  const SessionHistoryList({
    super.key,
    this.onSessionTap,
    this.maxItems = 5,
  });

  @override
  State<SessionHistoryList> createState() => SessionHistoryListState();
}

class SessionHistoryListState extends State<SessionHistoryList> {
  List<TaskSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // Method to refresh sessions (can be called externally)
  void refreshSessions() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final sessions = await timerProvider.getTodaysSessions();
    
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sessions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_outlined,
                    size: 32,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz bugün için seans yok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk çalışma seansınızı başlatın!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Sort sessions by start time (newest first)
        _sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        
        // Limit to maxItems
        final displaySessions = _sessions.take(widget.maxItems).toList();

        return Column(
          children: displaySessions.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onSessionTap?.call(session),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: session.isActive 
                                ? Colors.green[50] 
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            session.isActive ? Icons.play_arrow_rounded : Icons.check_rounded,
                            color: session.isActive ? Colors.green[600] : Colors.blue[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.purpose,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.goal,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatSessionTime(session),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  if (session.duration != null) ...[
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      session.formattedDuration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (session.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
  }

  String _formatSessionTime(TaskSession session) {
    final startTime = DateFormat('HH:mm').format(session.startTime);
    if (session.endTime != null) {
      final endTime = DateFormat('HH:mm').format(session.endTime!);
      return '$startTime - $endTime';
    }
    return '$startTime - Devam ediyor';
  }
}
