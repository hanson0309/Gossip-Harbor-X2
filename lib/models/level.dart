import 'package:flutter/material.dart';

/// 关卡模型
class Level {
  final int levelNumber;
  final String name;
  final int requiredScore; // 通关所需分数
  final int timeLimit; // 时间限制（秒）
  final int gridSize; // 游戏网格大小
  final int maxFoodTypes; // 最大食物种类
  final int customerCount; // 顾客数量
  final int energyCost; // 消耗体力
  final int coinReward; // 通关奖励金币
  final int expReward; // 通关奖励经验
  bool isUnlocked;
  bool isCompleted;
  int stars; // 0-3星评价

  Level({
    required this.levelNumber,
    required this.name,
    required this.requiredScore,
    required this.timeLimit,
    required this.gridSize,
    required this.maxFoodTypes,
    required this.customerCount,
    required this.energyCost,
    required this.coinReward,
    required this.expReward,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.stars = 0,
  });

  /// 根据关卡数自动生成关卡数据
  factory Level.generate(int levelNumber) {
    // 计算难度系数
    double difficulty = 1 + (levelNumber - 1) * 0.1;
    
    // 每10关一个章节
    int chapter = ((levelNumber - 1) ~/ 10) + 1;
    int levelInChapter = ((levelNumber - 1) % 10) + 1;
    
    // 关卡名称
    String name = '第${chapter}章-${levelInChapter}';
    
    // 根据难度计算各项参数
    int requiredScore = (100 * difficulty).toInt();
    int timeLimit = 180 - (levelNumber ~/ 10) * 10; // 时间逐渐减少
    if (timeLimit < 60) timeLimit = 60; // 最少60秒
    
    int gridSize = 6 + (levelNumber ~/ 20); // 每20关增加一格
    if (gridSize > 9) gridSize = 9; // 最大9x9
    
    int maxFoodTypes = 3 + (levelNumber ~/ 10); // 每10关增加一种食物
    if (maxFoodTypes > 8) maxFoodTypes = 8; // 最多8种
    
    int customerCount = 3 + (levelNumber ~/ 5); // 每5关增加一个顾客
    if (customerCount > 12) customerCount = 12; // 最多12个
    
    int energyCost = 5 + (levelNumber ~/ 10); // 每10关增加1点体力消耗
    
    int coinReward = (50 + levelNumber * 10);
    int expReward = (20 + levelNumber * 5);
    
    return Level(
      levelNumber: levelNumber,
      name: name,
      requiredScore: requiredScore,
      timeLimit: timeLimit,
      gridSize: gridSize,
      maxFoodTypes: maxFoodTypes,
      customerCount: customerCount,
      energyCost: energyCost,
      coinReward: coinReward,
      expReward: expReward,
      isUnlocked: levelNumber == 1, // 只有第一关默认解锁
      isCompleted: false,
      stars: 0,
    );
  }

  /// 获取难度描述
  String getDifficultyText() {
    if (levelNumber <= 10) return '简单';
    if (levelNumber <= 30) return '普通';
    if (levelNumber <= 60) return '困难';
    if (levelNumber <= 85) return '非常困难';
    return '地狱';
  }

  /// 获取难度颜色
  Color getDifficultyColor() {
    if (levelNumber <= 10) return Colors.green;
    if (levelNumber <= 30) return Colors.blue;
    if (levelNumber <= 60) return Colors.orange;
    if (levelNumber <= 85) return Colors.red;
    return Colors.purple;
  }

  /// 根据分数计算星级
  static int calculateStars(int score, int requiredScore) {
    if (score < requiredScore) return 0;
    if (score < requiredScore * 1.5) return 1;
    if (score < requiredScore * 2) return 2;
    return 3;
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'stars': stars,
    };
  }

  factory Level.fromJson(Map<String, dynamic> json, Level template) {
    return Level(
      levelNumber: template.levelNumber,
      name: template.name,
      requiredScore: template.requiredScore,
      timeLimit: template.timeLimit,
      gridSize: template.gridSize,
      maxFoodTypes: template.maxFoodTypes,
      customerCount: template.customerCount,
      energyCost: template.energyCost,
      coinReward: template.coinReward,
      expReward: template.expReward,
      isUnlocked: json['isUnlocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      stars: json['stars'] ?? 0,
    );
  }
}
