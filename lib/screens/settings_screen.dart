import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/app_settings.dart';
import '../models/webhook_config.dart';
import '../services/webhook_service.dart';

// Settings screen for user preferences and webhook configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _webhookUrlController;
  late TextEditingController _webhookMethodController;
  
  String _selectedMethod = 'POST';
  bool _sendDataInBody = true;
  bool _onStart = false;
  bool _onStop = false;
  bool _onAppOpen = false;
  bool _onAppClose = false;
  
  bool _isLoading = false;
  bool _isTestingWebhook = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _webhookUrlController = TextEditingController();
    _webhookMethodController = TextEditingController();
    
    // Load current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _webhookUrlController.dispose();
    _webhookMethodController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final settings = timerProvider.settings;
    
    _userNameController.text = settings.userName;
    _webhookUrlController.text = settings.webhookConfig.url;
    _webhookMethodController.text = settings.webhookConfig.method;
    
    setState(() {
      _selectedMethod = settings.webhookConfig.method;
      _sendDataInBody = settings.webhookConfig.sendDataInBody;
      _onStart = settings.webhookConfig.onStart;
      _onStop = settings.webhookConfig.onStop;
      _onAppOpen = settings.webhookConfig.onAppOpen;
      _onAppClose = settings.webhookConfig.onAppClose;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      
      final webhookConfig = WebhookConfig(
        url: _webhookUrlController.text.trim(),
        method: _selectedMethod,
        sendDataInBody: _sendDataInBody,
        onStart: _onStart,
        onStop: _onStop,
        onAppOpen: _onAppOpen,
        onAppClose: _onAppClose,
      );
      
      final settings = AppSettings(
        userName: _userNameController.text.trim(),
        webhookConfig: webhookConfig,
        isFirstLaunch: false,
      );
      
      await timerProvider.updateSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testWebhook() async {
    if (_webhookUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Webhook URL\'si gerekli'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isTestingWebhook = true;
    });

    try {
      final webhookConfig = WebhookConfig(
        url: _webhookUrlController.text.trim(),
        method: _selectedMethod,
        sendDataInBody: _sendDataInBody,
        onStart: true, // Enable for test
        onStop: false,
        onAppOpen: false,
        onAppClose: false,
      );
      
      final success = await WebhookService.testWebhook(webhookConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Webhook testi başarılı!' : 'Webhook testi başarısız'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingWebhook = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Settings Section
            _buildSectionTitle('Kullanıcı Ayarları'),
            _buildUserSettingsCard(),
            
            const SizedBox(height: 24),
            
            // Webhook Settings Section
            _buildSectionTitle('Webhook Ayarları'),
            _buildWebhookSettingsCard(),
            
            const SizedBox(height: 24),
            
            // Data Management Section
            _buildSectionTitle('Veri Yönetimi'),
            _buildDataManagementCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                hintText: 'Adınızı girin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebhookSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Webhook URL
            TextField(
              controller: _webhookUrlController,
              decoration: const InputDecoration(
                labelText: 'Webhook URL',
                hintText: 'https://example.com/webhook',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.webhook),
              ),
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 16),
            
            // HTTP Method
            Row(
              children: [
                const Text('HTTP Method: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'GET', child: Text('GET')),
                    DropdownMenuItem(value: 'POST', child: Text('POST')),
                    DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                    DropdownMenuItem(value: 'PATCH', child: Text('PATCH')),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Data sending method
            Row(
              children: [
                const Text('Veri Gönderme: '),
                const SizedBox(width: 8),
                DropdownButton<bool>(
                  value: _sendDataInBody,
                  onChanged: (value) {
                    setState(() {
                      _sendDataInBody = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Body\'de')),
                    DropdownMenuItem(value: false, child: Text('Query\'de')),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Event checkboxes
            const Text(
              'Hangi olaylarda webhook gönderilsin:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            
            CheckboxListTile(
              title: const Text('Seans Başlatıldığında'),
              subtitle: const Text('Çalışma seansı başladığında'),
              value: _onStart,
              onChanged: (value) {
                setState(() {
                  _onStart = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Seans Durdurulduğunda'),
              subtitle: const Text('Çalışma seansı bittiğinde'),
              value: _onStop,
              onChanged: (value) {
                setState(() {
                  _onStop = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Uygulama Açıldığında'),
              subtitle: const Text('Uygulama başlatıldığında'),
              value: _onAppOpen,
              onChanged: (value) {
                setState(() {
                  _onAppOpen = value ?? false;
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Uygulama Kapandığında'),
              subtitle: const Text('Uygulama kapatıldığında'),
              value: _onAppClose,
              onChanged: (value) {
                setState(() {
                  _onAppClose = value ?? false;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Test webhook button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingWebhook ? null : _testWebhook,
                icon: _isTestingWebhook
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isTestingWebhook ? 'Test Ediliyor...' : 'Webhook Test Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Tüm Verileri Sil'),
              subtitle: const Text('Tüm seanslar ve ayarlar silinecek'),
              onTap: () => _showClearDataDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sil'),
        content: const Text(
          'Tüm çalışma seansları ve ayarlar kalıcı olarak silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      
      // Stop current session if running
      if (timerProvider.isRunning) {
        await timerProvider.stopSession();
      }
      
      // Clear all data
      await timerProvider.updateSettings(AppSettings());
      
      // Reset form
      _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm veriler silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
