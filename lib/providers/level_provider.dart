import 'package:flutter/foundation.dart';
import '../models/level.dart';

/// 关卡提供者 - 管理100个关卡的状态
class LevelProvider with ChangeNotifier {
  List<Level> _levels = [];
  int _currentLevel = 1;

  LevelProvider() {
    _initializeLevels();
  }

  List<Level> get levels => _levels;
  int get currentLevel => _currentLevel;
  int get totalLevels => _levels.length;
  
  /// 获取已完成的关卡数
  int get completedLevelsCount => _levels.where((l) => l.isCompleted).length;
  
  /// 获取总星数
  int get totalStars => _levels.fold(0, (sum, level) => sum + level.stars);
  
  /// 获取最大可获得星数
  int get maxStars => _levels.length * 3;

  /// 初始化100个关卡
  void _initializeLevels() {
    _levels = List.generate(100, (index) => Level.generate(index + 1));
    notifyListeners();
  }

  /// 获取指定关卡
  Level? getLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > _levels.length) return null;
    return _levels[levelNumber - 1];
  }

  /// 解锁关卡
  void unlockLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > _levels.length) return;
    _levels[levelNumber - 1].isUnlocked = true;
    notifyListeners();
  }

  /// 完成关卡
  void completeLevel(int levelNumber, int score) {
    if (levelNumber < 1 || levelNumber > _levels.length) return;
    
    Level level = _levels[levelNumber - 1];
    level.isCompleted = true;
    
    // 计算星级
    int newStars = Level.calculateStars(score, level.requiredScore);
    if (newStars > level.stars) {
      level.stars = newStars;
    }
    
    // 解锁下一关
    if (levelNumber < _levels.length) {
      unlockLevel(levelNumber + 1);
      _currentLevel = levelNumber + 1;
    }
    
    notifyListeners();
  }

  /// 重置关卡进度（用于测试或重新开始）
  void resetProgress() {
    _initializeLevels();
    _currentLevel = 1;
    notifyListeners();
  }

  /// 获取章节关卡列表（每10关一章）
  List<List<Level>> getLevelsByChapter() {
    List<List<Level>> chapters = [];
    for (int i = 0; i < _levels.length; i += 10) {
      int end = (i + 10 > _levels.length) ? _levels.length : i + 10;
      chapters.add(_levels.sublist(i, end));
    }
    return chapters;
  }

  /// 获取章节信息
  Map<String, dynamic> getChapterInfo(int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > 10) {
      return {};
    }
    
    int startIndex = (chapterNumber - 1) * 10;
    int endIndex = startIndex + 10;
    if (endIndex > _levels.length) endIndex = _levels.length;
    
    List<Level> chapterLevels = _levels.sublist(startIndex, endIndex);
    int completedCount = chapterLevels.where((l) => l.isCompleted).length;
    int totalStars = chapterLevels.fold(0, (sum, l) => sum + l.stars);
    bool isUnlocked = chapterLevels.any((l) => l.isUnlocked);
    
    return {
      'chapterNumber': chapterNumber,
      'levels': chapterLevels,
      'completedCount': completedCount,
      'totalLevels': chapterLevels.length,
      'totalStars': totalStars,
      'maxStars': chapterLevels.length * 3,
      'isUnlocked': isUnlocked,
    };
  }

  /// 保存进度到JSON
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': _currentLevel,
      'levels': _levels.map((level) => level.toJson()).toList(),
    };
  }

  /// 从JSON加载进度
  void loadFromJson(Map<String, dynamic> json) {
    if (json.containsKey('currentLevel')) {
      _currentLevel = json['currentLevel'];
    }
    
    if (json.containsKey('levels')) {
      List<dynamic> levelsJson = json['levels'];
      for (int i = 0; i < levelsJson.length && i < _levels.length; i++) {
        Level template = _levels[i];
        _levels[i] = Level.fromJson(levelsJson[i], template);
      }
    }
    
    notifyListeners();
  }
}
