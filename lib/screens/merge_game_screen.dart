import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/level_provider.dart';
import '../models/level.dart';
import '../widgets/food_tile.dart';
import '../utils/page_transitions.dart';
import 'decoration_screen.dart';
import 'achievement_screen.dart';

class MergeGameScreen extends StatefulWidget {
  final bool isLevelMode;
  final Level? level;

  const MergeGameScreen({
    Key? key,
    this.isLevelMode = false,
    this.level,
  }) : super(key: key);

  @override
  State<MergeGameScreen> createState() => _MergeGameScreenState();
}

class _MergeGameScreenState extends State<MergeGameScreen> {
  Timer? _gameTimer;
  int? _remainingSeconds;
  int _currentScore = 0;
  bool _isLevelFinished = false;

  @override
  void initState() {
    super.initState();

    final gameProvider = context.read<GameProvider>();
    gameProvider.resetForNewGame();

    if (widget.isLevelMode && widget.level != null) {
      final level = widget.level!;
      _remainingSeconds = level.timeLimit;
      gameProvider.setMaxConcurrentCustomers(level.customerCount);
    } else {
      // 自由模式使用默认的顾客上限
      gameProvider.setMaxConcurrentCustomers(3);
    }

    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final gameProvider = context.read<GameProvider>();
      final restaurantProvider = context.read<RestaurantProvider>();
      
      // 更新顾客耐心
      gameProvider.updateCustomerPatience();
      
      // 更新体力（每秒检查一次）
      restaurantProvider.updateEnergy();

      // 关卡模式倒计时
      if (widget.isLevelMode && !_isLevelFinished && _remainingSeconds != null) {
        if (_remainingSeconds! > 0) {
          setState(() {
            _remainingSeconds = _remainingSeconds! - 1;
          });
          if (_remainingSeconds! <= 0) {
            final success = widget.level != null && _currentScore >= widget.level!.requiredScore;
            _onLevelEnd(success);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransitions.scaleTransition(const AchievementScreen()),
          );
        },
        backgroundColor: Colors.amber[600],
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isLevelMode) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                PageTransitions.slideAndFadeTransition(const DecorationScreen()),
              );
            }
          },
        ),
        title: Text(
          widget.isLevelMode && widget.level != null ? '关卡 ${widget.level!.levelNumber}' : '🍽️',
          style: const TextStyle(fontSize: 28),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[600]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          Consumer<RestaurantProvider>(
            builder: (context, restaurant, child) {
              final isEnergyFull = restaurant.restaurant.energy >= restaurant.restaurant.maxEnergy;
              final minutesUntilFull = restaurant.restaurant.getMinutesUntilFullEnergy();
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusChip(
                      Icons.bolt,
                      '${restaurant.restaurant.energy}/${restaurant.restaurant.maxEnergy}',
                      Colors.blue[600]!,
                    ),
                    if (!isEnergyFull && minutesUntilFull > 0) ...[
                      const SizedBox(width: 4),
                      _buildStatusChip(
                        Icons.access_time,
                        '${minutesUntilFull}m',
                        Colors.orange[600]!,
                      ),
                    ],
                    const SizedBox(width: 6),
                    _buildStatusChip(
                      Icons.monetization_on,
                      '${restaurant.restaurant.coins}',
                      Colors.amber[700]!,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.isLevelMode && widget.level != null)
            _buildLevelStatusBar(),

          // 顶部：顾客横向排列
          Consumer<GameProvider>(
            builder: (context, game, child) {
              return Container(
                height: 160,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.orange[50]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: game.customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 6),
                            Text(
                              '等待顾客中...',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: game.customers.length,
                        itemBuilder: (context, index) {
                          final customer = game.customers[index];
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildCustomerCard(context, customer, game),
                          );
                        },
                      ),
              );
            },
          ),
          
          // 游戏网格
          Expanded(
            child: Consumer<GameProvider>(
              builder: (context, game, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 5 / 7, // 5列7行的比例
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.orange[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1.8,
                        ),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 35,
                        itemBuilder: (context, index) {
                          int row = index ~/ 5;
                          int col = index % 5;
                          
                          // 左下角第一个格子作为生成按钮 (位置: 30)
                          if ((row == 6 && col == 0)) {
                            return Consumer<RestaurantProvider>(
                              builder: (context, restaurant, child) {
                                return _buildGenerateButtonTile(
                                  context,
                                  game,
                                  restaurant,
                                  row,
                                  col,
                                );
                              },
                            );
                          }
                          
                          final food = game.getFoodAt(row, col);
                          final isSelected = game.selectedRow == row && 
                                           game.selectedCol == col;
                          
                          return DragTarget<Map<String, dynamic>>(
                            onWillAccept: (data) => true,
                            onAccept: (data) {
                              final fromRow = data['row'] as int;
                              final fromCol = data['col'] as int;
                              game.dragTile(fromRow, fromCol, row, col);
                            },
                            builder: (context, candidateData, rejectedData) {
                              return FoodTile(
                                food: food,
                                isSelected: isSelected,
                                isDragTarget: candidateData.isNotEmpty,
                                row: row,
                                col: col,
                                onTap: () => game.selectTile(row, col),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildLevelStatusBar() {
    final level = widget.level!;
    final remaining = _remainingSeconds ?? level.timeLimit;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeText =
        '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.redAccent, size: 20),
              const SizedBox(width: 4),
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                '$_currentScore / ${level.requiredScore}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addScore(int value) {
    if (!widget.isLevelMode || _isLevelFinished) return;

    setState(() {
      _currentScore += value;
    });

    if (widget.level != null && _currentScore >= widget.level!.requiredScore) {
      _onLevelEnd(true);
    }
  }

  void _onLevelEnd(bool success) {
    if (!widget.isLevelMode || widget.level == null) return;
    if (_isLevelFinished) return;

    _isLevelFinished = true;
    _gameTimer?.cancel();

    final level = widget.level!;
    final levelProvider = context.read<LevelProvider>();
    final restaurant = context.read<RestaurantProvider>();

    if (success) {
      levelProvider.completeLevel(level.levelNumber, _currentScore);
      restaurant.earnCoins(level.coinReward);
      restaurant.earnExperience(level.expReward);
    }

    final reachedScore = _currentScore >= level.requiredScore;
    final stars = reachedScore
        ? Level.calculateStars(_currentScore, level.requiredScore)
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(success ? '关卡通过！' : '挑战结束'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('得分：$_currentScore / ${level.requiredScore}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              if (success) ...[
                const SizedBox(height: 12),
                Text('奖励：${level.coinReward} 金币，${level.expReward} 经验'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('返回关卡选择'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(IconData icon, String text, Color color) {
    // 根据图标类型选择不同的动画
    Widget animatedIcon;
    
    if (icon == Icons.bolt) {
      // 闪电图标：脉冲+缩放动画
      animatedIcon = Icon(icon, color: color, size: 16)
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.yellow.withOpacity(0.5))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
        );
    } else if (icon == Icons.access_time) {
      // 时钟图标：轻微旋转
      animatedIcon = Icon(icon, color: color, size: 16)
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(
          begin: 0,
          end: 0.05,
          duration: 1000.ms,
        )
        .then()
        .rotate(
          begin: 0.05,
          end: -0.05,
          duration: 1000.ms,
        )
        .then()
        .rotate(
          begin: -0.05,
          end: 0,
          duration: 1000.ms,
        );
    } else if (icon == Icons.monetization_on) {
      // 金币图标：上下跳动
      animatedIcon = Icon(icon, color: color, size: 16)
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: -3,
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .moveY(
          begin: -3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
    } else {
      // 其他图标：无动画
      animatedIcon = Icon(icon, color: color, size: 16);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          animatedIcon,
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, customer, GameProvider game) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) {
        if (data == null) return false;
        if (customer.isServed) return false;
        final dynamic food = data['food'];
        final dynamic level = food?.level;
        if (level is int) {
          return level == customer.requestedFood.level;
        }
        return false;
      },
      onAccept: (data) {
        final fromRow = data['row'] as int;
        final fromCol = data['col'] as int;
        final served = game.serveCustomerWithTile(customer, fromRow, fromCol);
        if (served) {
          final restaurant = context.read<RestaurantProvider>();
          final reward = customer.requestedFood.price + customer.tip;
          restaurant.earnCoins(reward);
          restaurant.earnExperience(customer.requestedFood.level * 10);
          if (widget.isLevelMode) {
            _addScore(reward);
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasFoodReady = game.hasFoodForCustomer(customer);
        final isHover = candidateData.isNotEmpty;
        final highlight = hasFoodReady && !customer.isServed;

        Widget statusIcon;
        if (customer.isServed) {
          statusIcon = const Icon(Icons.check_circle, color: Colors.green, size: 18);
        } else if (highlight) {
          statusIcon = Icon(Icons.check_circle, color: Colors.green[500], size: 16)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.12, 1.12),
                duration: 600.ms,
              );
        } else {
          statusIcon = Icon(Icons.check_circle, color: Colors.grey[300], size: 16);
        }

        return Card(
          elevation: isHover ? 5 : 3,
          shadowColor: highlight
              ? Colors.green.withOpacity(0.4)
              : Colors.orange.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.orange[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(customer.avatar, style: const TextStyle(fontSize: 34))
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.05, 1.05),
                              duration: 1200.ms,
                              curve: Curves.easeInOut,
                            ),
                        Positioned(
                          right: -2,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: customer.patiencePercentage > 0.5
                                  ? Colors.green[400]
                                  : customer.patiencePercentage > 0.25
                                      ? Colors.orange[400]
                                      : Colors.red[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              customer.patiencePercentage > 0.5
                                  ? '🙂'
                                  : customer.patiencePercentage > 0.25
                                      ? '😐'
                                      : '😡',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            customer.nameCn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Text(
                                    customer.requestedFood.emoji,
                                    style: const TextStyle(fontSize: 19),
                                  ),
                                  Positioned(
                                    right: -2,
                                    top: -6,
                                    child: statusIcon,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '💰${customer.requestedFood.price + customer.tip}',
                                  style: const TextStyle(fontSize: 14, color: Colors.amber),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (!customer.isServed) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: customer.patiencePercentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          customer.patiencePercentage > 0.5
                              ? Colors.green
                              : customer.patiencePercentage > 0.25
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ] else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenerateButtonTile(
    BuildContext context,
    GameProvider game,
    RestaurantProvider restaurant,
    int row,
    int col,
  ) {
    final energyCost = 1;
    final canGenerate = restaurant.restaurant.energy >= energyCost;

    return GestureDetector(
      onTap: canGenerate
          ? () {
              if (restaurant.useEnergyToGenerateFood(energyCost)) {
                game.generateRandomFood();
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: canGenerate
            ? LinearGradient(
                colors: [Colors.amber[200]!, Colors.amber[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: canGenerate ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canGenerate ? Colors.amber[600]! : Colors.grey[400]!,
            width: 2,
          ),
          boxShadow: canGenerate
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canGenerate ? Icons.add_circle : Icons.block,
                  size: 22,
                  color: canGenerate ? Colors.orange[900] : Colors.grey[600],
                ),
                const SizedBox(height: 3),
                Text(
                  canGenerate ? '⚡$energyCost' : '无能量',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: canGenerate ? Colors.orange[900] : Colors.grey[600],
                  ),
                ),
                Text(
                  '生成',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: canGenerate ? Colors.orange[800] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
