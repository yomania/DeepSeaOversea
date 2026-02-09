
import 'package:hive/hive.dart';

part 'upgrade_model.g.dart';

@HiveType(typeId: 2)
class UpgradeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double cost;

  @HiveField(4)
  final double multiplier; // Multiplier to production (e.g., 2.0 for 2x)

  @HiveField(5)
  final String targetUnitId; // ID of the unit this upgrade applies to. Null/Empty if global.

  @HiveField(6)
  bool isPurchased;

  @HiveField(7)
  bool isUnlocked;

  UpgradeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.multiplier,
    required this.targetUnitId,
    this.isPurchased = false,
    this.isUnlocked = false,
  });

  void purchase() {
    isPurchased = true;
    save();
  }
}
