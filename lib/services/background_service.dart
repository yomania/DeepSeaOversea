import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resource_model.dart';
import '../models/unit_model.dart';
import '../constants/game_constants.dart';

const String taskOfflineProduction = "com.deepsea.odyssey.offline_production";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskOfflineProduction) {
      await _calculateOfflineProduction();
    }
    return Future.value(true);
  });
}

Future<void> _calculateOfflineProduction() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ResourceModelAdapter());
  Hive.registerAdapter(UnitModelAdapter());

  // Open Boxes
  final resourceBox = await Hive.openBox<ResourceModel>(
    GameConstants.boxResources,
  );
  final unitBox = await Hive.openBox<UnitModel>(GameConstants.boxUnits);
  final settingsBox = await Hive.openBox(
    GameConstants.boxSettings,
  ); // Generic box for timestamps

  // Get Last Seen
  final prefs = await SharedPreferences.getInstance();
  final lastSeenStr = prefs.getString('last_seen_time');

  if (lastSeenStr == null) return;

  final lastSeen = DateTime.parse(lastSeenStr);
  final now = DateTime.now();
  final diffSeconds = now.difference(lastSeen).inSeconds;

  if (diffSeconds <= 0) return;

  // Calculate MPS (Minerals Per Second)
  double mps = 0.0;
  for (var unit in unitBox.values) {
    if (unit.id != GameConstants.unitClick) {
      mps += unit.totalProduction;
    }
  }

  // Add Rewards
  final production = mps * diffSeconds;

  if (production > 0) {
    if (resourceBox.containsKey(GameConstants.resourceMinerals)) {
      final minerals = resourceBox.get(GameConstants.resourceMinerals)!;
      minerals.amount += production;
      await minerals.save();

      // Store notification flag or local notification here if needed
      // For now, we just save the data. The UI will pick it up on resume.
    }
  }

  // Update last seen so accessing UI doesn't double dip too much (though UI logic should handle handle resume)
  await prefs.setString('last_seen_time', now.toIso8601String());

  await resourceBox.close();
  await unitBox.close();
  await settingsBox.close();
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // TODO: Turn off for production
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      taskOfflineProduction,
      frequency: const Duration(minutes: 15), // Android minimum
      // constraints: Constraints(
      //   networkType: NetworkType.not_required,
      // ),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
