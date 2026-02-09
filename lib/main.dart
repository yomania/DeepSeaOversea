
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'constants/game_constants.dart';
import 'models/resource_model.dart';
import 'models/unit_model.dart';
import 'models/upgrade_model.dart';
import 'providers/economy_provider.dart';
import 'services/purchase_service.dart';
import 'services/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(ResourceModelAdapter());
  Hive.registerAdapter(UnitModelAdapter());
  Hive.registerAdapter(UpgradeModelAdapter());
  
  // Run Background Service
  BackgroundService.initialize();
  BackgroundService.registerPeriodicTask();
  
  runApp(const DeepSeaApp());
}

class DeepSeaApp extends StatefulWidget {
  const DeepSeaApp({super.key});

  @override
  State<DeepSeaApp> createState() => _DeepSeaAppState();
}

class _DeepSeaAppState extends State<DeepSeaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
       // Save timestamp when app goes background
       _saveLastSeen();
    } else if (state == AppLifecycleState.resumed) {
       // Recalculate generic offline earnings if WorkManager didn't run
       // (Provider will verify this)
    }
  }
  
  Future<void> _saveLastSeen() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setString('last_seen_time', DateTime.now().toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseService()..init()),
        ChangeNotifierProxyProvider<PurchaseService, EconomyProvider>(
          create: (context) => EconomyProvider()..init(), // Init handles basic setup
          update: (context, purchase, economy) {
            if (economy == null) throw ArgumentError.notNull('economy');
            economy.purchaseService = purchase;
            return economy;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Deep Sea Odyssey',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FFFF), // Cyan/Neon Blue
            surface: Color(0xFF050505), // Deep Black
            background: Color(0xFF000000),
            secondary: Color(0xFF0088AA),
          ),
          fontFamily: 'Roboto', // Default for now, can change to custom font later
        ),
        home: const GameScreen(),
      ),
    );
  }
}
