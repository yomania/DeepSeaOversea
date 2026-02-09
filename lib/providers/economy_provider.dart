import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:hive/hive.dart';
import '../models/resource_model.dart';
import '../models/unit_model.dart';
import '../models/skill_model.dart';
import '../constants/game_constants.dart';
import '../services/purchase_service.dart';

class EconomyProvider with ChangeNotifier {
  late Box<ResourceModel> _resourceBox;
  late Box<UnitModel> _unitBox;
  late Box<SkillModel> _skillBox; // [NEW] Skill Box

  Timer? _gameTimer;
  DateTime? _lastTick;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Resources map for O(1) access
  Map<String, ResourceModel> _resources = {};
  Map<String, UnitModel> _units = {};
  Map<String, SkillModel> _skills = {}; // [NEW] Skills Map

  double _mineralsPerSecond = 0.0;
  double get mineralsPerSecond => _mineralsPerSecond;

  // [NEW] Level System
  int _level = 1;
  int get level => _level;

  double _xp = 0.0;
  double get xp => _xp;

  double get xpToNextLevel => _level * 1000.0; // Simple linear scaling for now

  // IAP Integration
  PurchaseService? _purchaseService;
  set purchaseService(PurchaseService service) {
    _purchaseService = service;
    _purchaseService?.onPurchaseSuccess = _handlePurchaseSuccess;
    notifyListeners();
  }

  bool _removeAdsPurchased = false;
  bool get removeAdsPurchased => _removeAdsPurchased;

  Future<void> init() async {
    if (_isInitialized) return;

    _resourceBox = await Hive.openBox<ResourceModel>(
      GameConstants.boxResources,
    );
    _unitBox = await Hive.openBox<UnitModel>(GameConstants.boxUnits);
    // [NEW] Open Skill Box (Using a constant for box name would be better, but hardcoding for now)
    _skillBox = await Hive.openBox<SkillModel>('skills');

    _initializeResources();
    _initializeUnits();
    _initializeSkills(); // [NEW]

    _loadLevelData(); // [NEW] Load saved level data

    _recalculateProduction();

    _startGameLoop();
    _isInitialized = true;
    notifyListeners();
  }

  void _initializeResources() {
    if (_resourceBox.isEmpty) {
      _resources[GameConstants.resourceMinerals] = ResourceModel(
        id: GameConstants.resourceMinerals,
        name: 'Minerals',
        description: 'Basic resource found in the ocean.',
      );
      _resourceBox.add(_resources[GameConstants.resourceMinerals]!);
    } else {
      for (var res in _resourceBox.values) {
        _resources[res.id] = res;
      }
    }
  }

  void _handlePurchaseSuccess(String productId) {
    if (productId == PurchaseService.productRemoveAds) {
      _removeAdsPurchased = true;
      // Maybe give a persistent buff?
      _recalculateProduction();
    } else if (productId == PurchaseService.productStarterPack) {
      // Give resources
      _resources[GameConstants.resourceMinerals]?.add(1000.0);
      _resources[GameConstants.resourceGas]?.add(100.0);
    } else if (productId == PurchaseService.productGemPack1) {
      // Give Gems (if implemented) or massive minerals
      _resources[GameConstants.resourceMinerals]?.add(50000.0);
    }
    notifyListeners();
  }

  void _initializeUnits() {
    if (_unitBox.isEmpty) {
      // Manual Clicker (virtual unit)
      _units[GameConstants.unitClick] = UnitModel(
        id: GameConstants.unitClick,
        name: 'Manual Harvest',
        description: 'Click to harvest resources.',
        baseCost: 0,
        baseProduction: 1.0, // Base click power
        count: 1,
        isUnlocked: true,
      );

      // Auto Miner
      _units[GameConstants.unitAutoMiner] = UnitModel(
        id: GameConstants.unitAutoMiner,
        name: 'Auto Miner',
        description: 'Basic automated mining machine.',
        baseCost: 15.0,
        baseProduction: 0.5,
      );

      // Save all
      _units.forEach((key, value) {
        _unitBox.add(value);
      });
    } else {
      for (var unit in _unitBox.values) {
        _units[unit.id] = unit;
      }
    }
  }

  // [NEW] Initialize Skill Tree
  void _initializeSkills() {
    if (_skillBox.isEmpty) {
      // Root Skill: Basic Efficiency
      final basicEff = SkillModel(
        id: 'skill_basic_efficiency',
        name: 'Mining Efficiency',
        description: 'Increases global mineral production by 10%.',
        resourceCost: {GameConstants.resourceMinerals: 100},
        effects: {'type': 'global_multiplier', 'value': 1.1},
        x: 0,
        y: 0,
        isUnlocked: true, // Root is always unlocked
      );
      _skills[basicEff.id] = basicEff;

      // Child 1: Auto Miner Boost (Requires Basic Efficiency)
      final autoMinerBoost = SkillModel(
        id: 'skill_autominer_boost',
        name: 'Auto Miner Overclock',
        description: 'Auto Miners produce 20% more.',
        resourceCost: {GameConstants.resourceMinerals: 500},
        requiredSkillIds: ['skill_basic_efficiency'],
        effects: {
          'type': 'unit_multiplier',
          'target': GameConstants.unitAutoMiner,
          'value': 1.2,
        },
        x: -1,
        y: 1,
      );
      _skills[autoMinerBoost.id] = autoMinerBoost;

      // Child 2: Click Power (Requires Basic Efficiency + Level 2)
      final clickBoost = SkillModel(
        id: 'skill_click_boost',
        name: 'Hydraulic Press',
        description: 'Click power doubled.',
        resourceCost: {GameConstants.resourceMinerals: 1000},
        requiredLevel: 2,
        requiredSkillIds: ['skill_basic_efficiency'],
        effects: {
          'type': 'unit_multiplier',
          'target': GameConstants.unitClick,
          'value': 2.0,
        },
        x: 1,
        y: 1,
      );
      _skills[clickBoost.id] = clickBoost;

      _skills.forEach((key, value) {
        _skillBox.add(value);
      });
    } else {
      for (var skill in _skillBox.values) {
        _skills[skill.id] = skill;
      }
    }
  }

  // [NEW] Load Level from persistent storage (SharedPrefs or Hive)
  // For simplicity, we'll assume it's stored in Hive metadata or separate box later.
  // For now, we'll just initialize to 1/0.
  void _loadLevelData() {
    // TODO: Implement actual save/load for XP/Level
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _lastTick = DateTime.now();

    // 10 ticks per second for smooth UI, but logic can be adjusted
    _gameTimer = Timer.periodic(
      Duration(milliseconds: GameConstants.tickMilliseconds),
      (timer) {
        final now = DateTime.now();
        final delta = now.difference(_lastTick!).inMilliseconds / 1000.0;
        _lastTick = now;

        _produceResources(delta);
      },
    );
  }

  void _produceResources(double deltaSeconds) {
    if (_mineralsPerSecond > 0) {
      final production = _mineralsPerSecond * deltaSeconds;
      _resources[GameConstants.resourceMinerals]?.add(production);

      // [NEW] Passive XP Gain (10% of mineral production)
      gainXp(production * 0.1);

      notifyListeners(); // Notify UI to update numbers
    }
  }

  // [NEW] XP Logic
  void gainXp(double amount) {
    _xp += amount;
    if (_xp >= xpToNextLevel) {
      _levelUp();
    }
  }

  void _levelUp() {
    _xp -= xpToNextLevel;
    _level++;
    // TODO: Show level up effect/toast
    // Refresh skills unlocked by level
    _checkSkillUnlockConditions();
  }

  // [NEW] Check if locked skills should be unlocked (viewable/purchasable)
  void _checkSkillUnlockConditions() {
    for (var skill in _skills.values) {
      if (skill.isPurchased) continue;

      // Check if unlocked (visible/purchasable)
      // Condition: All parent skills purchased
      bool parentsPurchased = true;
      for (var parentId in skill.requiredSkillIds) {
        if (_skills[parentId]?.isPurchased != true) {
          parentsPurchased = false;
          break;
        }
      }

      if (parentsPurchased && !skill.isUnlocked) {
        skill.unlock();
      }
    }
    notifyListeners();
  }

  void _recalculateProduction() {
    double mps = 0.0;

    // [NEW] Apply Skill Modifiers
    double globalMultiplier = 1.0;
    Map<String, double> unitMultipliers = {};

    for (var skill in _skills.values) {
      if (skill.isPurchased) {
        final type = skill.effects['type'];
        final value = skill.effects['value'] as double;

        if (type == 'global_multiplier') {
          globalMultiplier *= value;
        } else if (type == 'unit_multiplier') {
          final target = skill.effects['target'] as String;
          unitMultipliers[target] = (unitMultipliers[target] ?? 1.0) * value;
        }
      }
    }

    // Sum up all auto-production units (excluding manual click for MPS)
    for (var unit in _units.values) {
      // Apply unit specific multipliers
      double unitMult = unitMultipliers[unit.id] ?? 1.0;

      if (unit.id != GameConstants.unitClick) {
        mps += unit.baseProduction * unit.count * unitMult;
      }
    }

    // Apply global multipliers (Upgrades, IAP, Skills)
    if (_removeAdsPurchased) {
      globalMultiplier *= 1.2;
    }

    _mineralsPerSecond = mps * globalMultiplier;
  }

  // --- Public Actions ---

  void manualClick() {
    final clickUnit = _units[GameConstants.unitClick];
    double clickPower = clickUnit?.baseProduction ?? 1.0;

    // [NEW] Apply Skill Multipliers for Click
    for (var skill in _skills.values) {
      if (skill.isPurchased &&
          skill.effects['type'] == 'unit_multiplier' &&
          skill.effects['target'] == GameConstants.unitClick) {
        clickPower *= skill.effects['value'];
      }
    }

    _resources[GameConstants.resourceMinerals]?.add(clickPower);
    HapticFeedback.lightImpact(); // Haptic feedback

    // Manual clicks give direct XP
    gainXp(clickPower);

    notifyListeners();
  }

  void manualClickWithBonus(double multiplier) {
    final clickUnit = _units[GameConstants.unitClick];
    double clickPower = clickUnit?.baseProduction ?? 1.0;

    // Apply Skill Multipliers for Click
    for (var skill in _skills.values) {
      if (skill.isPurchased &&
          skill.effects['type'] == 'unit_multiplier' &&
          skill.effects['target'] == GameConstants.unitClick) {
        clickPower *= skill.effects['value'];
      }
    }

    _resources[GameConstants.resourceMinerals]?.add(clickPower * multiplier);
    HapticFeedback.mediumImpact(); // Stronger haptic for bonus

    gainXp(clickPower * multiplier);
    notifyListeners();
  }

  bool canAffordUnit(String unitId) {
    final unit = _units[unitId];
    final minerals = _resources[GameConstants.resourceMinerals]?.amount ?? 0;
    if (unit == null) return false;
    return minerals >= unit.currentCost;
  }

  void buyUnit(String unitId) {
    final unit = _units[unitId];
    final mineralsRes = _resources[GameConstants.resourceMinerals];

    if (unit != null && mineralsRes != null) {
      final cost = unit.currentCost;
      if (mineralsRes.amount >= cost) {
        mineralsRes.subtract(cost);
        unit.purchase();
        _recalculateProduction();
        notifyListeners();
      }
    }
  }

  // [NEW] Skill Purchase Logic
  bool canAffordSkill(String skillId) {
    final skill = _skills[skillId];
    if (skill == null) return false;
    if (skill.isPurchased) return false;
    if (!skill.isUnlocked) return false; // Must be unlocked (parents bought)
    if (_level < skill.requiredLevel) return false; // Level requirements

    // Check Resource Costs
    for (var entry in skill.resourceCost.entries) {
      final res = _resources[entry.key];
      if (res == null || res.amount < entry.value) {
        return false;
      }
    }
    return true;
  }

  void buySkill(String skillId) {
    final skill = _skills[skillId];
    if (skill == null || !canAffordSkill(skillId)) return;

    // Deduct Resources
    for (var entry in skill.resourceCost.entries) {
      _resources[entry.key]?.subtract(entry.value);
    }

    skill.purchase();

    // Recursively unlock children
    _checkSkillUnlockConditions();

    _recalculateProduction();
    notifyListeners();
  }

  double getResourceAmount(String resourceId) {
    return _resources[resourceId]?.amount ?? 0.0;
  }

  UnitModel? getUnit(String unitId) {
    return _units[unitId];
  }

  // [NEW]
  SkillModel? getSkill(String skillId) {
    return _skills[skillId];
  }

  List<SkillModel> get visibleSkills {
    return _skills.values.toList();
  }

  List<UnitModel> get visibleUnits {
    // Return units that should be shown in the store
    return _units.values.where((u) => u.id != GameConstants.unitClick).toList();
  }

  // --- Debug / Test Mode ---

  void debugLevelUp() {
    _levelUp();
  }

  void debugAddMinerals(double amount) {
    _resources[GameConstants.resourceMinerals]?.add(amount);
    notifyListeners();
  }

  void debugSubMinerals(double amount) {
    _resources[GameConstants.resourceMinerals]?.subtract(amount);
    notifyListeners();
  }

  String getProductionBreakdown() {
    final buffer = StringBuffer();
    double totalMps = 0.0;

    // 1. Base Unit Production
    buffer.writeln('--- Base Production ---');
    for (var unit in _units.values) {
      if (unit.id != GameConstants.unitClick && unit.count > 0) {
        final unitTotal = unit.baseProduction * unit.count;
        totalMps += unitTotal;
        buffer.writeln(
          '${unit.name} (x${unit.count}): +${unitTotal.toStringAsFixed(1)}/s',
        );
      }
    }

    if (totalMps == 0) buffer.writeln('(No automated units)');

    // 2. Multipliers
    buffer.writeln('\n--- Multipliers ---');
    double globalMult = 1.0;

    if (_removeAdsPurchased) {
      globalMult *= 1.2;
      buffer.writeln('Ad Removal: x1.2');
    }

    for (var skill in _skills.values) {
      if (skill.isPurchased) {
        if (skill.effects['type'] == 'global_multiplier') {
          final val = skill.effects['value'] as double;
          globalMult *= val;
          buffer.writeln('${skill.name}: x$val');
        } else if (skill.effects['type'] == 'unit_multiplier') {
          // Unit specific (complicated to show efficiently in summary, seeing global helps mostly)
          final target = skill.effects['target'];
          final val = skill.effects['value'];
          buffer.writeln('${skill.name} ($target): x$val');
        }
      }
    }

    buffer.writeln(
      '\nTotal Multiplier Effect: x${globalMult.toStringAsFixed(2)}',
    );

    return buffer.toString();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
