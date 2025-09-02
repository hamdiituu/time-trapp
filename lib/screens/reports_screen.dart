import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../models/task_session.dart';

// Reports screen for viewing daily and hourly work statistics
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'daily'; // 'daily' or 'hourly'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _viewMode = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'daily',
                child: Text('Günlük Görünüm'),
              ),
              const PopupMenuItem(
                value: 'hourly',
                child: Text('Saatlik Görünüm'),
              ),
            ],
            child: const Icon(Icons.view_module),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(),
          
          // View mode selector
          _buildViewModeSelector(),
          
          // Content
          Expanded(
            child: _viewMode == 'daily' 
                ? _buildDailyView() 
                : _buildHourlyView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 'daily'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _viewMode == 'daily' 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Günlük',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _viewMode == 'daily' ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 'hourly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _viewMode == 'hourly' 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Saatlik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _viewMode == 'hourly' ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyView() {
    return FutureBuilder<List<TaskSession>>(
      future: _getSessionsForDate(_selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        final sessions = snapshot.data ?? [];
        final totalDuration = _calculateTotalDuration(sessions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              _buildSummaryCard(totalDuration, sessions.length),
              
              const SizedBox(height: 20),
              
              // Sessions list
              if (sessions.isEmpty)
                _buildEmptyState()
              else
                _buildSessionsList(sessions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHourlyView() {
    return FutureBuilder<Map<int, Duration>>(
      future: _getHourlyData(_selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        final hourlyData = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saatlik Dağılım',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              if (hourlyData.isEmpty)
                _buildEmptyState()
              else
                _buildHourlyChart(hourlyData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(Duration totalDuration, int sessionCount) {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Toplam Süre',
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                  Icons.timer,
                ),
                _buildSummaryItem(
                  'Seans Sayısı',
                  sessionCount.toString(),
                  Icons.play_circle_outline,
                ),
                _buildSummaryItem(
                  'Ortalama',
                  sessionCount > 0 
                      ? '${(totalDuration.inMinutes / sessionCount).round()} dk'
                      : '0 dk',
                  Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionsList(List<TaskSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seanslar',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        
        ...sessions.map((session) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.work, color: Colors.white),
            ),
            title: Text(session.purpose),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.goal),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('HH:mm').format(session.startTime)} - ${session.endTime != null ? DateFormat('HH:mm').format(session.endTime!) : 'Devam ediyor'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: session.duration != null
                ? Text(
                    session.formattedDuration,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                : null,
          ),
        )),
      ],
    );
  }

  Widget _buildHourlyChart(Map<int, Duration> hourlyData) {
    final maxDuration = hourlyData.values.fold(Duration.zero, (a, b) => a > b ? a : b);
    
    return Column(
      children: hourlyData.entries.map((entry) {
        final hour = entry.key;
        final duration = entry.value;
        final percentage = maxDuration.inMinutes > 0 
            ? duration.inMinutes / maxDuration.inMinutes 
            : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  '${duration.inMinutes} dk',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bu tarih için veri yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çalışma seanslarınızı başlatarak veri oluşturun',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<List<TaskSession>> _getSessionsForDate(DateTime date) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return timerProvider.getSessionsForDateRange(startOfDay, endOfDay);
  }

  Future<Map<int, Duration>> _getHourlyData(DateTime date) async {
    final sessions = await _getSessionsForDate(date);
    final hourlyData = <int, Duration>{};
    
    for (final session in sessions) {
      if (session.duration != null) {
        final startHour = session.startTime.hour;
        final endHour = session.endTime?.hour ?? DateTime.now().hour;
        
        for (int hour = startHour; hour <= endHour; hour++) {
          final hourStart = DateTime(date.year, date.month, date.day, hour);
          final hourEnd = hourStart.add(const Duration(hours: 1));
          
          final sessionStart = session.startTime.isAfter(hourStart) ? session.startTime : hourStart;
          final sessionEnd = session.endTime != null && session.endTime!.isBefore(hourEnd) 
              ? session.endTime! 
              : hourEnd;
          
          if (sessionStart.isBefore(sessionEnd)) {
            final duration = sessionEnd.difference(sessionStart);
            hourlyData[hour] = (hourlyData[hour] ?? Duration.zero) + duration;
          }
        }
      }
    }
    
    return hourlyData;
  }

  Duration _calculateTotalDuration(List<TaskSession> sessions) {
    return sessions.fold(Duration.zero, (total, session) {
      return total + (session.duration ?? Duration.zero);
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
}
