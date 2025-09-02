import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/start_session_modal.dart';
import '../widgets/session_history_list.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

// Main home screen with timer and session management
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimerProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Time Trapp',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: Colors.grey[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
            tooltip: 'Raporlar',
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Ayarlar',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[800], size: 20),
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Timer Durumu'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'start_stop',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Seans Başlat/Durdur'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'quit',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Çıkış'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                if (timerProvider.settings.userName.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Merhaba, ${timerProvider.settings.userName}!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Timer section
                _buildTimerSection(timerProvider),
                
                const SizedBox(height: 30),
                
                // Action buttons
                _buildActionButtons(timerProvider),
                
                const SizedBox(height: 30),
                
                // Today's summary
                _buildTodaysSummary(timerProvider),
                
                const SizedBox(height: 20),
                
                // Recent sessions
                _buildRecentSessions(timerProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerSection(TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer display
          Text(
            timerProvider.formattedElapsedTime,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w300,
              color: Colors.grey[800],
              fontFamily: 'SF Mono',
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Current session info
          if (timerProvider.currentSession != null)
            Column(
              children: [
                Text(
                  timerProvider.currentSession!.purpose,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  timerProvider.currentSession!.goal,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Text(
              'Henüz aktif bir seans yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TimerProvider timerProvider) {
    return Container(
      height: 56,
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
          onTap: timerProvider.isRunning
              ? () => _showStopConfirmation(timerProvider)
              : () => _showStartSessionModal(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  timerProvider.isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: timerProvider.isRunning ? Colors.red[600] : Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  timerProvider.isRunning ? 'Durdur' : 'Başlat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: timerProvider.isRunning ? Colors.red[600] : Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(TimerProvider timerProvider) {
    return FutureBuilder<Duration>(
      future: timerProvider.getTodaysTotalTime(),
      builder: (context, snapshot) {
        final totalTime = snapshot.data ?? Duration.zero;
        final hours = totalTime.inHours;
        final minutes = totalTime.inMinutes.remainder(60);
        
        return Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugünkü Özet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Toplam: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSessions(TimerProvider timerProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Son Seanslar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        SessionHistoryList(
          onSessionTap: (session) {
            // Handle session tap if needed
          },
        ),
      ],
    );
  }

  void _showStartSessionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StartSessionModal(),
    );
  }

  void _showStopConfirmation(TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seansı Durdur'),
        content: const Text('Çalışma seansınızı durdurmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              timerProvider.stopSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Durdur'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    
    switch (value) {
      case 'status':
        _showStatus();
        break;
      case 'start_stop':
        if (timerProvider.isRunning) {
          _showStopConfirmation(timerProvider);
        } else {
          _showStartSessionModal();
        }
        break;
      case 'quit':
        _quitApp();
        break;
    }
  }

  void _showStatus() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final currentSession = timerProvider.currentSession;
    final isRunning = timerProvider.isRunning;
    final elapsedTime = timerProvider.formattedElapsedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Durumu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durum: ${isRunning ? "Çalışıyor" : "Durduruldu"}'),
            Text('Süre: $elapsedTime'),
            if (currentSession != null) ...[
              const SizedBox(height: 8),
              Text('Amaç: ${currentSession.purpose}'),
              Text('Hedef: ${currentSession.goal}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _quitApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış'),
        content: const Text('Uygulamadan çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              exit(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }
}
