
import 'package:hive/hive.dart';

part 'unit_model.g.dart';

@HiveType(typeId: 1)
class UnitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double baseCost;

  @HiveField(4)
  final double baseProduction; // Production per second

  @HiveField(5)
  final double costGrowthRate; // Usually around 1.15

  @HiveField(6)
  int count;

  @HiveField(7)
  bool isUnlocked;

  UnitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.baseProduction,
    this.costGrowthRate = 1.15,
    this.count = 0,
    this.isUnlocked = false,
  });

  double get currentCost {
    // Cost = Base * (Growth ^ Count)
    // We can interpret this as the cost for the NEXT unit.
    return baseCost * (costGrowthRate * count > 0 ?  _pow(costGrowthRate, count) : 1.0);
  }
  
  // Simple power function helper if not using dart:math for this specifically or to keep logic contained
  double _pow(double x, int exponent) {
    double res = 1.0;
    for (int i = 0; i < exponent; i++) {
      res *= x;
    }
    return res;
  }

  double get totalProduction => baseProduction * count;

  void purchase() {
    count++;
    save();
  }
}
