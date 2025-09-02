import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/timer_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'services/webhook_service.dart';
import 'services/app_lifecycle_service.dart';
import 'services/menu_bar_service.dart';

void main() {
  runApp(const TimeTrappApp());
}

class TimeTrappApp extends StatelessWidget {
  const TimeTrappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerProvider(),
      child: MaterialApp(
        title: 'Time Trapp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    AppLifecycleService().dispose();
    MenuBarService().dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Initialize locale data for intl package
    await initializeDateFormatting('tr_TR', null);
    
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    await timerProvider.initialize();
    
    // Initialize app lifecycle service
    AppLifecycleService().initialize(context);
    
    // Initialize menu bar service
    MenuBarService().initialize(context);
    
    // Send app open webhook if configured
    if (timerProvider.settings.webhookConfig.onAppOpen) {
      await WebhookService.sendAppOpenWebhook(timerProvider.settings.webhookConfig);
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Time Trapp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        // Show onboarding if first launch
        if (timerProvider.settings.isFirstLaunch) {
          return const OnboardingScreen();
        }
        
        // Show home screen
        return const HomeScreen();
      },
    );
  }
}
