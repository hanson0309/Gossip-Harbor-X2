class Restaurant {
  int level;
  int coins;
  int experience;
  int energy; // 体力值
  int maxEnergy; // 最大体力值
  DateTime lastEnergyUpdate; // 上次体力更新时间
  String floorType;
  String wallpaperType;
  List<String> unlockedFurniture;
  
  Restaurant({
    this.level = 1,
    this.coins = 100,
    this.experience = 0,
    this.energy = 50,
    this.maxEnergy = 50,
    DateTime? lastEnergyUpdate,
    this.floorType = 'wood',
    this.wallpaperType = 'white',
    this.unlockedFurniture = const [],
  }) : lastEnergyUpdate = lastEnergyUpdate ?? DateTime.now();

  int get experienceToNextLevel => level * 100;
  
  bool get canLevelUp => experience >= experienceToNextLevel;
  
  // 体力恢复速度：每1分钟恢复1点
  static const int energyRecoveryMinutes = 1;
  
  bool get isEnergyFull => energy >= maxEnergy;

  void addCoins(int amount) {
    coins += amount;
  }

  void spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
    }
  }

  void addExperience(int amount) {
    experience += amount;
    while (canLevelUp) {
      levelUp();
    }
  }

  void levelUp() {
    experience -= experienceToNextLevel;
    level++;
    // 升级时增加最大体力值
    maxEnergy += 5;
  }

  // 更新体力值（基于时间自动恢复）
  void updateEnergy() {
    if (energy >= maxEnergy) {
      energy = maxEnergy;
      lastEnergyUpdate = DateTime.now();
      return;
    }
    
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    
    if (minutesPassed >= energyRecoveryMinutes) {
      final energyToRecover = minutesPassed ~/ energyRecoveryMinutes;
      energy = (energy + energyToRecover).clamp(0, maxEnergy);
      
      // 更新时间，保留余数
      final remainderMinutes = minutesPassed % energyRecoveryMinutes;
      lastEnergyUpdate = now.subtract(Duration(minutes: remainderMinutes));
    }
  }

  // 消耗体力
  bool useEnergy(int amount) {
    if (energy >= amount) {
      energy -= amount;
      lastEnergyUpdate = DateTime.now();
      return true;
    }
    return false;
  }

  // 获取下次恢复体力的剩余时间（分钟）
  int getMinutesUntilNextEnergy() {
    if (energy >= maxEnergy) return 0;
    
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    final remainingMinutes = energyRecoveryMinutes - (minutesPassed % energyRecoveryMinutes);
    return remainingMinutes;
  }

  // 获取体力回满的剩余时间（分钟）
  int getMinutesUntilFullEnergy() {
    if (energy >= maxEnergy) return 0;
    
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    final energyNeeded = maxEnergy - energy;
    
    // 计算已经可以恢复的体力
    final energyRecovered = minutesPassed ~/ energyRecoveryMinutes;
    final actualEnergyNeeded = energyNeeded - energyRecovered;
    
    if (actualEnergyNeeded <= 0) return 0;
    
    // 计算还需要多少分钟才能回满
    final remainingMinutes = actualEnergyNeeded * energyRecoveryMinutes;
    return remainingMinutes;
  }

  void changeFloor(String type) {
    floorType = type;
  }

  void changeWallpaper(String type) {
    wallpaperType = type;
  }

  void unlockFurniture(String furnitureId) {
    if (!unlockedFurniture.contains(furnitureId)) {
      unlockedFurniture = [...unlockedFurniture, furnitureId];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'coins': coins,
      'experience': experience,
      'energy': energy,
      'maxEnergy': maxEnergy,
      'lastEnergyUpdate': lastEnergyUpdate.toIso8601String(),
      'floorType': floorType,
      'wallpaperType': wallpaperType,
      'unlockedFurniture': unlockedFurniture,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      level: json['level'] ?? 1,
      coins: json['coins'] ?? 100,
      experience: json['experience'] ?? 0,
      energy: json['energy'] ?? 50,
      maxEnergy: json['maxEnergy'] ?? 50,
      lastEnergyUpdate: json['lastEnergyUpdate'] != null
          ? DateTime.parse(json['lastEnergyUpdate'])
          : DateTime.now(),
      floorType: json['floorType'] ?? 'wood',
      wallpaperType: json['wallpaperType'] ?? 'white',
      unlockedFurniture: List<String>.from(json['unlockedFurniture'] ?? []),
    );
  }
}

// 装修选项
class DecorationOptions {
  static final Map<String, Map<String, dynamic>> floors = {
    'wood': {'name': 'Wooden Floor', 'nameCn': '木地板', 'color': 0xFFD2691E, 'price': 0},
    'tile': {'name': 'Tile Floor', 'nameCn': '瓷砖地板', 'color': 0xFFE0E0E0, 'price': 500},
    'marble': {'name': 'Marble Floor', 'nameCn': '大理石地板', 'color': 0xFFF5F5DC, 'price': 1500},
    'carpet': {'name': 'Carpet', 'nameCn': '地毯', 'color': 0xFFDC143C, 'price': 2500},
  };

  static final Map<String, Map<String, dynamic>> wallpapers = {
    'white': {'name': 'White Wall', 'nameCn': '白墙', 'color': 0xFFFFFFF0, 'price': 0},
    'blue': {'name': 'Blue Wall', 'nameCn': '蓝墙', 'color': 0xFF87CEEB, 'price': 500},
    'green': {'name': 'Green Wall', 'nameCn': '绿墙', 'color': 0xFF90EE90, 'price': 1000},
    'pink': {'name': 'Pink Wall', 'nameCn': '粉墙', 'color': 0xFFFFB6C1, 'price': 1500},
    'gold': {'name': 'Gold Wall', 'nameCn': '金墙', 'color': 0xFFFFD700, 'price': 3000},
  };

  static final Map<String, Map<String, dynamic>> furniture = {
    'table_basic': {'name': 'Basic Table', 'nameCn': '基础桌子', 'emoji': '🪑', 'price': 200},
    'table_fancy': {'name': 'Fancy Table', 'nameCn': '豪华桌子', 'emoji': '🛋️', 'price': 800},
    'plant': {'name': 'Plant', 'nameCn': '植物', 'emoji': '🪴', 'price': 300},
    'lamp': {'name': 'Lamp', 'nameCn': '灯', 'emoji': '💡', 'price': 400},
    'painting': {'name': 'Painting', 'nameCn': '画', 'emoji': '🖼️', 'price': 600},
  };
}
