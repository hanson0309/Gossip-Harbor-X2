import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> achievements = [];
  List<Achievement> unlockedQueue = [];
  int totalCoinsEarned = 0;
  int totalCustomersServed = 0;
  int totalDecorationsOwned = 0;

  AchievementProvider() {
    _initializeAchievements();
    _loadData();
  }

  void _initializeAchievements() {
    achievements = AchievementDatabase.achievements
        .map((a) => Achievement(
              id: a.id,
              title: a.title,
              titleCn: a.titleCn,
              description: a.description,
              emoji: a.emoji,
              reward: a.reward,
              type: a.type,
              target: a.target,
            ))
        .toList();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('achievements_data');

    if (data != null) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(data);
        totalCoinsEarned = jsonData['totalCoinsEarned'] ?? 0;
        totalCustomersServed = jsonData['totalCustomersServed'] ?? 0;
        totalDecorationsOwned = jsonData['totalDecorationsOwned'] ?? 0;

        final List<dynamic> savedAchievements =
            jsonData['achievements'] ?? [];
        for (var saved in savedAchievements) {
          final achievement =
              achievements.firstWhere((a) => a.id == saved['id']);
          achievement.progress = saved['progress'] ?? 0;
          achievement.isUnlocked = saved['isUnlocked'] ?? false;
          if (saved['unlockedAt'] != null) {
            achievement.unlockedAt = DateTime.parse(saved['unlockedAt']);
          }
        }
      } catch (e) {
        // 加载失败时使用默认值
      }
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'totalCoinsEarned': totalCoinsEarned,
      'totalCustomersServed': totalCustomersServed,
      'totalDecorationsOwned': totalDecorationsOwned,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
    await prefs.setString('achievements_data', jsonEncode(data));
  }

  // 更新成就进度
  void updateMergeProgress(int count) {
    _updateAchievements(AchievementType.merge, count);
  }

  void updateLevelProgress(int level) {
    _updateAchievements(AchievementType.level, level, isAbsolute: true);
  }

  void updateCustomerProgress(int count) {
    totalCustomersServed += count;
    _updateAchievements(AchievementType.customer, totalCustomersServed,
        isAbsolute: true);
  }

  void updateCoinsProgress(int coins) {
    totalCoinsEarned += coins;
    _updateAchievements(AchievementType.coins, totalCoinsEarned,
        isAbsolute: true);
  }

  void updateDecorationProgress(int count) {
    totalDecorationsOwned += count;
    _updateAchievements(AchievementType.decoration, totalDecorationsOwned,
        isAbsolute: true);
  }

  void _updateAchievements(AchievementType type, int value,
      {bool isAbsolute = false}) {
    for (var achievement in achievements) {
      if (achievement.type == type && !achievement.isUnlocked) {
        if (isAbsolute) {
          achievement.progress = value;
        } else {
          achievement.updateProgress(value);
        }

        if (achievement.isCompleted) {
          achievement.unlock();
          unlockedQueue.add(achievement);
        }
      }
    }

    _saveData();
    notifyListeners();
  }

  // 清空解锁队列
  List<Achievement> popUnlockedQueue() {
    final queue = List<Achievement>.from(unlockedQueue);
    unlockedQueue.clear();
    return queue;
  }

  // 获取解锁的成就
  List<Achievement> get unlockedAchievements =>
      achievements.where((a) => a.isUnlocked).toList();

  // 获取未解锁的成就
  List<Achievement> get lockedAchievements =>
      achievements.where((a) => !a.isUnlocked).toList();

  // 获取成就统计
  int get totalAchievements => achievements.length;
  int get unlockedCount => unlockedAchievements.length;
  double get completionPercentage => unlockedCount / totalAchievements;

  // 总奖励金币
  int get totalRewards =>
      unlockedAchievements.fold(0, (sum, a) => sum + a.reward);
}
