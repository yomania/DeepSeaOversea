import 'package:hive/hive.dart';

part 'skill_model.g.dart';

@HiveType(typeId: 3)
class SkillModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  /// 스킬 해금에 필요한 자원 비용 (Resource Cost)
  /// 예: {'minerals': 1000, 'gas': 50}
  @HiveField(3)
  final Map<String, double> resourceCost;

  /// 스킬 해금에 필요한 레벨 (Required Level)
  /// 0이면 레벨 제한 없음
  @HiveField(4)
  final int requiredLevel;

  /// 선행 스킬 ID 목록 (Prerequisite Skill IDs)
  /// 이 목록에 있는 모든 스킬을 구매해야 해금 가능
  @HiveField(5)
  final List<String> requiredSkillIds;

  /// 스킬 효과 (Skill Effects)
  /// 예: {'type': 'production_multiplier', 'target': 'auto_miner', 'value': 1.5}
  @HiveField(6)
  final Map<String, dynamic> effects;

  /// UI 상의 X 좌표 (X Position in UI)
  @HiveField(7)
  final double x;

  /// UI 상의 Y 좌표 (Y Position in UI)
  @HiveField(8)
  final double y;

  @HiveField(9)
  bool isPurchased;

  @HiveField(10)
  bool isUnlocked; // 선행 조건이 충족되어 구매 가능한 상태인지 여부

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    this.resourceCost = const {},
    this.requiredLevel = 0,
    this.requiredSkillIds = const [],
    this.effects = const {},
    this.x = 0.0,
    this.y = 0.0,
    this.isPurchased = false,
    this.isUnlocked = false,
  });

  // [Reasoning]
  // 스킬 구매 처리를 위한 헬퍼 메서드.
  // 상태 변경 후 save()를 호출하여 Hive에 즉시 반영합니다.
  void purchase() {
    isPurchased = true;
    save();
  }

  void unlock() {
    if (!isUnlocked) {
      isUnlocked = true;
      save();
    }
  }
}
