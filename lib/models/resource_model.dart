
import 'package:hive/hive.dart';

part 'resource_model.g.dart';

@HiveType(typeId: 0)
class ResourceModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  double amount;
  
  @HiveField(3)
  final String description;

  ResourceModel({
    required this.id,
    required this.name,
    this.amount = 0.0,
    required this.description,
  });

  void add(double value) {
    amount += value;
    save(); // Hive auto-save
  }

  void subtract(double value) {
    if (amount >= value) {
      amount -= value;
      save();
    }
  }
}
