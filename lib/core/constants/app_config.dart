/// App-wide constants that are not user-facing copy.
abstract final class AppConfig {
  static const version = '1.0.0';
  static const dbFileName = 'roznamcha.sqlite';
  static const shopRowId = 1;
  static const settingsRowId = 1;

  /// Pass `--dart-define=SEED_SAMPLE=true` to fill a new shop with demo data.
  static const seedSampleData = bool.fromEnvironment('SEED_SAMPLE');

  /// Longer ranges are drawn as weekly bars so the chart stays readable.
  static const chartDailyLimit = 62;
}
