/// Plant type model with asset folder mapping
class PlantType {
  final String id;
  final String nameKey; // Localization key
  final String descriptionKey; // Localization key
  final String emoji;
  final String assetFolder;
  final int maxStages;
  final bool useNumberedFiles; // true = 1.png, false = 1_hatgiong.png

  const PlantType({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.emoji,
    required this.assetFolder,
    required this.maxStages,
    this.useNumberedFiles = true,
  });

  /// Get asset path for a specific stage/level
  String getAssetPath(int stage) {
    final clampedStage = stage.clamp(1, maxStages);
    
    if (useNumberedFiles) {
      // Standard format: 1.png, 2.png, etc.
      return '$assetFolder$clampedStage.png';
    } else {
      // Seedling format with Vietnamese names
      final seedlingNames = [
        '1_hatgiong', '2_hatnaymam', '3_mamnon', '4_caynon', '5_caycon',
        '6_caynho', '7_caydanglon', '8_caytruongthanh', '9_cayphattrientot',
        '10_cayrahoa', '11_caykettrainon', '12_caytrailondan', 
        '13_caykettraichin', '14_caysaiqua', '15_caytruongthanh'
      ];
      if (clampedStage <= seedlingNames.length) {
        return '$assetFolder${seedlingNames[clampedStage - 1]}.png';
      }
      return '$assetFolder$clampedStage.png';
    }
  }

  /// Available plant types
  static const PlantType bamboo = PlantType(
    id: 'bamboo',
    nameKey: 'plantBamboo',
    descriptionKey: 'plantDescBamboo',
    emoji: '🎋',
    assetFolder: 'assets/images/tree/tre/',
    maxStages: 15,
    useNumberedFiles: true, // Bamboo uses numbered files like other plants
  );

  static const PlantType cactus = PlantType(
    id: 'cactus',
    nameKey: 'plantCactus',
    descriptionKey: 'plantDescCactus',
    emoji: '🌵',
    assetFolder: 'assets/images/tree/xuongrong/',
    maxStages: 13,
    useNumberedFiles: true,
  );

  static const PlantType sakura = PlantType(
    id: 'flower',
    nameKey: 'plantFlower',
    descriptionKey: 'plantDescFlower',
    emoji: '🌸',
    assetFolder: 'assets/images/tree/anhdao/',
    maxStages: 14,
    useNumberedFiles: true,
  );

  static const PlantType sunflower = PlantType(
    id: 'sunflower',
    nameKey: 'plantSunflower',
    descriptionKey: 'plantDescSunflower',
    emoji: '🌻',
    assetFolder: 'assets/images/tree/huongduong/',
    maxStages: 16,
    useNumberedFiles: true,
  );

  /// Get stage name localization key for this plant type
  /// Returns key like "bamboLevel1", "cactusLevel1", etc.
  String getStageNameKey(int stage) {
    final clampedStage = stage.clamp(1, maxStages);
    // Convert plant ID to prefix: bamboo → bambo, cactus → cactus, flower → sakura, sunflower → sunflower
    String prefix;
    switch (id) {
      case 'bamboo':
        prefix = 'bamboo';
        break;
      case 'cactus':
        prefix = 'cactus';
        break;
      case 'flower':
        prefix = 'sakura';
        break;
      case 'sunflower':
        prefix = 'sunflower';
        break;
      default:
        prefix = id;
    }
    return '${prefix}Level$clampedStage';
  }

  /// Get all available plant types (4 types only)
  static const List<PlantType> all = [
    bamboo,
    cactus,
    sakura,
    sunflower,
  ];

  /// Find plant type by id
  static PlantType? fromId(String id) {
    try {
      return all.firstWhere((type) => type.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get plant type or fallback to bamboo
  static PlantType fromIdOrDefault(String? id) {
    if (id == null) return bamboo;
    return fromId(id) ?? bamboo;
  }
}
