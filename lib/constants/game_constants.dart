
class GameConstants {
  // Economy
  static const double initialMinerals = 0.0;
  static const double costGrowthRate = 1.15; // 15% increase per level
  static const double productionTickRate = 1.0; // Seconds between auto-production ticks (for calculation)
  static const int tickMilliseconds = 100; // UI update tick rate (10 times per sec)

  // Resources
  static const String resourceMinerals = 'minerals';
  static const String resourceGas = 'gas';

  // Units
  static const String unitClick = 'manual_click';
  static const String unitAutoMiner = 'auto_miner';
  static const String unitSubmarine = 'submarine';
  static const String unitMiningDrone = 'mining_drone';

  // Depths (in meters)
  static const double depthSunlightZone = 0.0;
  static const double depthTwilightZone = 200.0;
  static const double depthMidnightZone = 1000.0;
  static const double depthAbyssalZone = 4000.0;
  static const double depthHadalZone = 6000.0;
  
  // Hive Boxes
  static const String boxResources = 'resources_box';
  static const String boxUnits = 'units_box';
  static const String boxUpgrades = 'upgrades_box';
  static const String boxSettings = 'settings_box';
}
