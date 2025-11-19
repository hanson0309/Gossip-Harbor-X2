import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/level_provider.dart';
import '../models/level.dart';
import '../providers/restaurant_provider.dart';
import '../utils/page_transitions.dart';
import 'merge_game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[400]!,
              Colors.purple[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              _buildChapterTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    10,
                    (index) => _buildChapterView(index + 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '🎯 关卡挑战',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Consumer<LevelProvider>(
            builder: (context, levelProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${levelProvider.totalStars}/${levelProvider.maxStars}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildStats() {
    return Consumer<LevelProvider>(
      builder: (context, levelProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '当前关卡',
                '${levelProvider.currentLevel}',
                Icons.flag,
                Colors.blue,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                '已完成',
                '${levelProvider.completedLevelsCount}/100',
                Icons.check_circle,
                Colors.green,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem(
                '完成度',
                '${(levelProvider.completedLevelsCount / 100 * 100).toInt()}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale();
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 50,
      child: Consumer<LevelProvider>(
        builder: (context, levelProvider, child) {
          return TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: List.generate(10, (index) {
              final chapterInfo = levelProvider.getChapterInfo(index + 1);
              final isUnlocked = chapterInfo['isUnlocked'] ?? false;
              
              return Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '第${index + 1}章',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                      if (isUnlocked)
                        Text(
                          '${chapterInfo['totalStars']}⭐',
                          style: const TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildChapterView(int chapterNumber) {
    return Consumer<LevelProvider>(
      builder: (context, levelProvider, child) {
        final chapterInfo = levelProvider.getChapterInfo(chapterNumber);
        final levels = chapterInfo['levels'] as List<Level>? ?? [];
        
        if (levels.isEmpty) {
          return const Center(
            child: Text(
              '暂无关卡',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            return _buildLevelCard(levels[index], index);
          },
        );
      },
    );
  }

  Widget _buildLevelCard(Level level, int index) {
    return GestureDetector(
      onTap: level.isUnlocked ? () => _showLevelDetail(level) : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: level.isUnlocked
                ? [Colors.white, Colors.grey[100]!]
                : [Colors.grey[400]!, Colors.grey[500]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 锁定图标
            if (!level.isUnlocked)
              const Center(
                child: Icon(Icons.lock, size: 48, color: Colors.white70),
              ),
            
            // 关卡内容
            if (level.isUnlocked)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 关卡号和难度
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: level.getDifficultyColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '第${level.levelNumber}关',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (level.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 难度标签
                    Text(
                      level.getDifficultyText(),
                      style: TextStyle(
                        color: level.getDifficultyColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // 星级
                    Row(
                      children: List.generate(3, (i) {
                        return Icon(
                          i < level.stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    
                    const Spacer(),
                    
                    // 关卡信息
                    _buildLevelInfo(Icons.timer, '${level.timeLimit}秒'),
                    const SizedBox(height: 4),
                    _buildLevelInfo(Icons.grid_3x3, '${level.gridSize}x${level.gridSize}'),
                    const SizedBox(height: 4),
                    _buildLevelInfo(Icons.people, '${level.customerCount}位顾客'),
                    
                    const Spacer(),
                    
                    // 奖励
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${level.coinReward}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.bolt, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '-${level.energyCost}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).scale(),
    );
  }

  Widget _buildLevelInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showLevelDetail(Level level) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [level.getDifficultyColor().withOpacity(0.3), Colors.white],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '关卡 ${level.levelNumber}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: level.getDifficultyColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level.getDifficultyText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 关卡详情
              _buildDetailRow('目标分数', '${level.requiredScore}分', Icons.emoji_events),
              _buildDetailRow('时间限制', '${level.timeLimit}秒', Icons.timer),
              _buildDetailRow('网格大小', '${level.gridSize}x${level.gridSize}', Icons.grid_3x3),
              _buildDetailRow('食物种类', '${level.maxFoodTypes}种', Icons.restaurant),
              _buildDetailRow('顾客数量', '${level.customerCount}位', Icons.people),
              _buildDetailRow('消耗体力', '${level.energyCost}', Icons.bolt),
              
              const SizedBox(height: 24),
              
              // 奖励
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎁 通关奖励',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${level.coinReward} 金币',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${level.expReward} 经验',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 开始按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startLevel(level);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: level.getDifficultyColor(),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '开始挑战',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _startLevel(Level level) {
    // TODO: 跳转到游戏界面，传入关卡信息
    final restaurant = context.read<RestaurantProvider>();

    if (!restaurant.useEnergy(level.energyCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('体力不足，无法开始关卡'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageTransitions.slideAndFadeTransition(
        MergeGameScreen(
          isLevelMode: true,
          level: level,
        ),
      ),
    );
  }
}
