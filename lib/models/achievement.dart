class Achievement {
  final String id;
  final String title;
  final String titleCn;
  final String description;
  final String emoji;
  final int reward; // 金币奖励
  final AchievementType type;
  final int target; // 目标值
  int progress; // 当前进度
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.titleCn,
    required this.description,
    required this.emoji,
    required this.reward,
    required this.type,
    required this.target,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);
  
  bool get isCompleted => progress >= target && !isUnlocked;

  void updateProgress(int value) {
    if (!isUnlocked) {
      progress = (progress + value).clamp(0, target);
    }
  }

  void unlock() {
    isUnlocked = true;
    unlockedAt = DateTime.now();
    progress = target;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    int? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      titleCn: titleCn,
      description: description,
      emoji: emoji,
      reward: reward,
      type: type,
      target: target,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementType {
  merge,      // 合成次数
  level,      // 达到等级
  customer,   // 服务顾客
  coins,      // 赚取金币
  decoration, // 装修次数
  story,      // 解锁剧情
}

class AchievementDatabase {
  static final List<Achievement> achievements = [
    // 合成成就
    Achievement(
      id: 'merge_10',
      title: 'Beginner Chef',
      titleCn: '初级厨师',
      description: '完成10次合成',
      emoji: '👨‍🍳',
      reward: 100,
      type: AchievementType.merge,
      target: 10,
    ),
    Achievement(
      id: 'merge_50',
      title: 'Skilled Chef',
      titleCn: '熟练厨师',
      description: '完成50次合成',
      emoji: '👨‍🍳',
      reward: 500,
      type: AchievementType.merge,
      target: 50,
    ),
    Achievement(
      id: 'merge_100',
      title: 'Master Chef',
      titleCn: '大师厨师',
      description: '完成100次合成',
      emoji: '🌟',
      reward: 1000,
      type: AchievementType.merge,
      target: 100,
    ),
    
    // 等级成就
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      titleCn: '冉冉新星',
      description: '达到5级',
      emoji: '⭐',
      reward: 200,
      type: AchievementType.level,
      target: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Famous Chef',
      titleCn: '名厨',
      description: '达到10级',
      emoji: '🌟',
      reward: 500,
      type: AchievementType.level,
      target: 10,
    ),
    Achievement(
      id: 'level_20',
      title: 'Legendary Chef',
      titleCn: '传奇厨师',
      description: '达到20级',
      emoji: '✨',
      reward: 2000,
      type: AchievementType.level,
      target: 20,
    ),
    
    // 顾客成就
    Achievement(
      id: 'customer_10',
      title: 'Good Service',
      titleCn: '优质服务',
      description: '服务10位顾客',
      emoji: '😊',
      reward: 150,
      type: AchievementType.customer,
      target: 10,
    ),
    Achievement(
      id: 'customer_50',
      title: 'Customer Favorite',
      titleCn: '顾客最爱',
      description: '服务50位顾客',
      emoji: '💖',
      reward: 600,
      type: AchievementType.customer,
      target: 50,
    ),
    Achievement(
      id: 'customer_100',
      title: 'Town Celebrity',
      titleCn: '小镇名人',
      description: '服务100位顾客',
      emoji: '🏆',
      reward: 1500,
      type: AchievementType.customer,
      target: 100,
    ),
    
    // 金币成就
    Achievement(
      id: 'coins_1000',
      title: 'Money Maker',
      titleCn: '赚钱高手',
      description: '累计赚取1000金币',
      emoji: '💰',
      reward: 200,
      type: AchievementType.coins,
      target: 1000,
    ),
    Achievement(
      id: 'coins_5000',
      title: 'Business Tycoon',
      titleCn: '商业大亨',
      description: '累计赚取5000金币',
      emoji: '💎',
      reward: 800,
      type: AchievementType.coins,
      target: 5000,
    ),
    
    // 装修成就
    Achievement(
      id: 'decoration_3',
      title: 'Interior Designer',
      titleCn: '室内设计师',
      description: '购买3件装修物品',
      emoji: '🎨',
      reward: 300,
      type: AchievementType.decoration,
      target: 3,
    ),
    Achievement(
      id: 'decoration_8',
      title: 'Renovation Expert',
      titleCn: '装修专家',
      description: '购买8件装修物品',
      emoji: '🏠',
      reward: 1000,
      type: AchievementType.decoration,
      target: 8,
    ),
  ];

  static Achievement? getAchievementById(String id) {
    try {
      return achievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}
