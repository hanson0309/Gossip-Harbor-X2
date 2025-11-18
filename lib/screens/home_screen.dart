import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/restaurant_provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/dialog_box.dart';
import 'merge_game_screen.dart';
import 'decoration_screen.dart';
import 'achievement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownWelcome = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_hasShownWelcome) {
      _hasShownWelcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
        _checkAchievements();
      });
    }
  }

  void _checkAchievements() {
    final achievementProvider = context.read<AchievementProvider>();
    Future.delayed(const Duration(milliseconds: 500), () {
      final unlockedAchievements = achievementProvider.popUnlockedQueue();
      for (var achievement in unlockedAchievements) {
        _showAchievementUnlocked(achievement);
      }
    });
  }

  void _showAchievementUnlocked(achievement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[300]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                '🎉 成就解锁！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.titleCn,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '+${achievement.reward} 金币',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<RestaurantProvider>().earnCoins(achievement.reward);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                ),
                child: const Text('领取奖励'),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StoryDialog(
        character: 'Quinn Castillo',
        characterCn: '奎因·卡斯蒂略',
        avatar: '👩‍🍳',
        message: '欢迎来到海滨小镇！我是奎因，刚刚回到家乡接手父亲的餐厅。'
            '餐厅需要重新装修，也需要准备美味的食物来招待顾客。'
            '你能帮我一起经营这家餐厅吗？',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementScreen()),
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.emoji_events),
      ).animate().scale(delay: 500.ms, duration: 400.ms),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[300]!,
              Colors.orange[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 游戏标题
              const Text(
                '🏖️ 浪漫餐厅',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              const Text(
                'Gossip Harbor',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              
              const SizedBox(height: 40),
              
              // 餐厅信息卡片
              Consumer<RestaurantProvider>(
                builder: (context, restaurant, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              '等级',
                              '${restaurant.restaurant.level}',
                              Icons.star,
                              Colors.amber,
                            ),
                            _buildStatCard(
                              '体力',
                              '${restaurant.restaurant.energy}/${restaurant.restaurant.maxEnergy}',
                              Icons.bolt,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              '金币',
                              '${restaurant.restaurant.coins}',
                              Icons.monetization_on,
                              Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 经验进度条
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '经验值',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${restaurant.restaurant.experience}/${restaurant.restaurant.experienceToNextLevel}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: restaurant.restaurant.experience /
                                  restaurant.restaurant.experienceToNextLevel,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0);
                },
              ),
              
              const SizedBox(height: 40),
              
              // 游戏按钮
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGameButton(
                            '🎮 开始游戏',
                            '合成食材，招待顾客',
                            Colors.green,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MergeGameScreen(),
                                ),
                              );
                            },
                          ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 16),
                          _buildGameButton(
                            '🏠 装修餐厅',
                            '打造你的梦想餐厅',
                            Colors.purple,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DecorationScreen(),
                                ),
                              );
                            },
                          ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 16),
                          _buildGameButton(
                            '📖 故事剧情',
                            '解开小镇的秘密',
                            Colors.blue,
                            () {
                              _showStoryDialog();
                            },
                          ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideX(begin: -0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 版本信息
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'v1.0.0 - Made with Flutter 💙',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryDialog() {
    showDialog(
      context: context,
      builder: (context) => StoryDialog(
        character: 'Quinn Castillo',
        characterCn: '奎因·卡斯蒂略',
        avatar: '👩‍🍳',
        message: '父亲的餐厅在一场神秘的火灾中被烧毁了...\n'
            '小镇上的人们都在议论纷纷，但没人知道真相。\n'
            '我回到这里，不仅要重建餐厅，还要找出真相！\n\n'
            '（更多剧情正在开发中...）',
      ),
    );
  }
}
