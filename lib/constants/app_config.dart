class AppConfig {
  // 디버그 모드 활성화 여부 (Is debug mode enabled?)
  // true: 디버그 배너 표시, 치트/테스트 메뉴 접근 가능
  // false: 배너 숨김, 치트 메뉴 숨김 (프로덕션 모드)
  static const bool isDebugMode = false;

  // 디버그 배너 표시 여부 (Show debug banner?)
  static bool get showDebugBanner => isDebugMode;

  // 치트/테스트 기능 활성화 여부 (Enable cheats/test features?)
  static bool get enableCheats => isDebugMode;

  // 로그 출력 여부 (Enable logging?)
  static bool get enableLogging => isDebugMode;
}
