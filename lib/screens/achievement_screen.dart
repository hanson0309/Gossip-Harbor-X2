import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.emoji_events, size: 26),
            SizedBox(width: 8),
            Text(
              '成就殿堂',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, achievementProvider, child) {
          return Column(
            children: [
              // 成就统计概览
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFFA000), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            '已解锁',
                            '${achievementProvider.unlockedCount}',
                            Icons.emoji_events,
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatCard(
                            '总成就',
                            '${achievementProvider.totalAchievements}',
                            Icons.star,
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatCard(
                            '总奖励',
                            '${achievementProvider.totalRewards}',
                            Icons.monetization_on,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 进度条
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🎯 总体完成度',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${(achievementProvider.completionPercentage * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: achievementProvider.completionPercentage,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 成就列表
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[600],
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          padding: const EdgeInsets.all(4),
                          tabs: const [
                            Tab(text: '🏆 已解锁'),
                            Tab(text: '🔒 未解锁'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAchievementList(
                              achievementProvider.unlockedAchievements,
                              true,
                            ),
                            _buildAchievementList(
                              achievementProvider.lockedAchievements,
                              false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements, bool isUnlocked) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.grey[100] : Colors.amber[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? Icons.emoji_events_outlined : Icons.emoji_events,
                size: 80,
                color: isUnlocked ? Colors.grey[400] : Colors.amber[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUnlocked ? '还没有解锁任何成就' : '🎉 恭喜！所有成就都已解锁！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.grey[700] : Colors.amber[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked ? '继续努力，完成挑战解锁成就！' : '你是真正的大师！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement, isUnlocked)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 50))
            .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isUnlocked
          ? LinearGradient(
              colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: isUnlocked ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
              ? Colors.amber.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
            blurRadius: isUnlocked ? 15 : 8,
            spreadRadius: isUnlocked ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnlocked ? Color(0xFFFFD54F) : Colors.grey[200]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // 图标
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: isUnlocked
                  ? LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: isUnlocked ? null : Colors.grey[200],
                shape: BoxShape.circle,
                boxShadow: isUnlocked ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: TextStyle(
                    fontSize: 36,
                    color: isUnlocked ? null : Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.titleCn,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.amber[900] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 进度条或解锁时间
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '已解锁 • 奖励: ${achievement.reward} 💰',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '进度: ${achievement.progress}/${achievement.target}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(achievement.progressPercentage * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: achievement.progressPercentage,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFB300),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
