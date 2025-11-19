import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant.dart';
import '../widgets/dialog_box.dart';
import '../utils/page_transitions.dart';
import 'merge_game_screen.dart';

class DecorationScreen extends StatefulWidget {
  const DecorationScreen({Key? key}) : super(key: key);

  @override
  State<DecorationScreen> createState() => _DecorationScreenState();
}

class _DecorationScreenState extends State<DecorationScreen> {
  String selectedTab = 'floor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransitions.slideAndFadeTransition(const MergeGameScreen()),
            );
          },
        ),
        title: Row(
          children: const [
            Icon(Icons.palette, size: 24),
            SizedBox(width: 8),
            Text(
              '餐厅装修',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurant, child) {
          return Column(
            children: [
              // 金币显示
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFDE7), Color(0xFFFFF3E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.orange[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.monetization_on, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${restaurant.restaurant.coins}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '金币',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF6C00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 餐厅预览
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(DecorationOptions.wallpapers[
                          restaurant.restaurant.wallpaperType
                        ]!['color']).withOpacity(0.98),
                        Color(DecorationOptions.wallpapers[
                          restaurant.restaurant.wallpaperType
                        ]!['color']).withOpacity(0.92),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE1BEE7), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.18),
                        blurRadius: 18,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 地板
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 110,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(DecorationOptions.floors[
                                  restaurant.restaurant.floorType
                                ]!['color']).withOpacity(0.98),
                                Color(DecorationOptions.floors[
                                  restaurant.restaurant.floorType
                                ]!['color']).withOpacity(0.9),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.65),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // 家具
                      Center(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: restaurant.restaurant.unlockedFurniture
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final furnitureId = entry.value;
                            final furniture = DecorationOptions.furniture[furnitureId]!;
                            return Text(
                              furniture['emoji'],
                              style: const TextStyle(fontSize: 48),
                            )
                                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                .moveY(
                                  begin: 0,
                                  end: -6,
                                  duration: 1200.ms,
                                  delay: (index * 120).ms,
                                  curve: Curves.easeInOut,
                                );
                          }).toList(),
                        ),
                      ),
                      
                      // 餐厅名称
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Color(0xFFF3E5F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Color(0xFFBA68C8), width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏖️',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '浪漫海滨餐厅',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    Text(
                                      'Lv.${restaurant.restaurant.level}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9C27B0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // 人气条
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 130,
                        child: _buildPopularityBar(restaurant.restaurant),
                      ),

                      // 顾客预览
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 78,
                        child: _buildPreviewCustomers(restaurant.restaurant),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 装修选项标签
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF9FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTab('🖼️ 地板', 'floor'),
                    _buildTab('🎨 壁纸', 'wallpaper'),
                    _buildTab('🛋️ 家具', 'furniture'),
                  ],
                ),
              ),
              
              // 装修选项列表
              Expanded(
                flex: 2,
                child: _buildOptionsList(restaurant),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewCustomers(Restaurant restaurant) {
    final int score = _calculatePopularityScore(restaurant);
    int count = 0;
    if (score >= 60) {
      count = 3;
    } else if (score >= 30) {
      count = 2;
    } else if (score >= 10) {
      count = 1;
    }

    if (count == 0) {
      return const SizedBox.shrink();
    }

    const List<String> emojis = ['🧑‍🍳', '👩‍🍳', '😋', '😄'];

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final emoji = emojis[index % emojis.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -4,
                  duration: 900.ms,
                  delay: (index * 150).ms,
                  curve: Curves.easeInOut,
                ),
          );
        }),
      ),
    );
  }

  int _calculatePopularityScore(Restaurant restaurant) {
    int score = 0;

    final floor = DecorationOptions.floors[restaurant.floorType];
    final wallpaper = DecorationOptions.wallpapers[restaurant.wallpaperType];

    if (floor != null) {
      score += _charmFromPrice(floor['price'] as int);
    }
    if (wallpaper != null) {
      score += _charmFromPrice(wallpaper['price'] as int);
    }

    for (final furnitureId in restaurant.unlockedFurniture) {
      final furniture = DecorationOptions.furniture[furnitureId];
      if (furniture != null) {
        score += _charmFromPrice(furniture['price'] as int);
      }
    }

    return score;
  }

  int _charmFromPrice(int price) {
    if (price <= 0) return 1;
    return 1 + (price ~/ 400);
  }

  Widget _buildPopularityBar(Restaurant restaurant) {
    const int maxScore = 100;
    final int score = _calculatePopularityScore(restaurant);
    final int clampedScore = score > maxScore ? maxScore : score;
    final double progress = score <= 0
        ? 0.0
        : (score / maxScore).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 16,
              color: Color(0xFFFFA000),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '人气 ${clampedScore}/$maxScore',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 120,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7B1FA2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFF7B1FA2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsList(RestaurantProvider restaurant) {
    if (selectedTab == 'floor') {
      return _buildFloorList(restaurant);
    } else if (selectedTab == 'wallpaper') {
      return _buildWallpaperList(restaurant);
    } else {
      return _buildFurnitureList(restaurant);
    }
  }

  Widget _buildFloorList(RestaurantProvider restaurant) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: DecorationOptions.floors.entries.map((entry) {
        final isOwned = restaurant.restaurant.floorType == entry.key;
        final price = entry.value['price'] as int;
        
        return _buildDecorationCard(
          name: entry.value['nameCn'],
          color: Color(entry.value['color']),
          price: price,
          isOwned: isOwned,
          onBuy: () {
            if (restaurant.canAfford(price)) {
              showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: '购买地板',
                  message: '确定要花费 $price 金币购买${entry.value['nameCn']}吗？',
                  onConfirm: () {
                    restaurant.changeFloor(entry.key, price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('购买成功！'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('金币不足！'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildWallpaperList(RestaurantProvider restaurant) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: DecorationOptions.wallpapers.entries.map((entry) {
        final isOwned = restaurant.restaurant.wallpaperType == entry.key;
        final price = entry.value['price'] as int;
        
        return _buildDecorationCard(
          name: entry.value['nameCn'],
          color: Color(entry.value['color']),
          price: price,
          isOwned: isOwned,
          onBuy: () {
            if (restaurant.canAfford(price)) {
              showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: '购买壁纸',
                  message: '确定要花费 $price 金币购买${entry.value['nameCn']}吗？',
                  onConfirm: () {
                    restaurant.changeWallpaper(entry.key, price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('购买成功！'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('金币不足！'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildFurnitureList(RestaurantProvider restaurant) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: DecorationOptions.furniture.entries.map((entry) {
        final isOwned = restaurant.hasFurniture(entry.key);
        final price = entry.value['price'] as int;
        
        return _buildFurnitureCard(
          name: entry.value['nameCn'],
          emoji: entry.value['emoji'],
          price: price,
          isOwned: isOwned,
          onBuy: () {
            if (restaurant.canAfford(price)) {
              showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: '购买家具',
                  message: '确定要花费 $price 金币购买${entry.value['nameCn']}吗？',
                  onConfirm: () {
                    restaurant.buyFurniture(entry.key, price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('购买成功！'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('金币不足！'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDecorationCard({
    required String name,
    required Color color,
    required int price,
    required bool isOwned,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOwned
              ? [const Color(0xFFF5E9FB), const Color(0xFFFFFFFF)]
              : [const Color(0xFFFFFFFF), const Color(0xFFFDF9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isOwned
                ? Colors.purple.withOpacity(0.22)
                : Colors.black.withOpacity(0.06),
            blurRadius: isOwned ? 14 : 8,
            spreadRadius: isOwned ? 1 : 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isOwned ? const Color(0xFFBA68C8) : const Color(0xFFE0E0E0),
          width: isOwned ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isOwned ? Color(0xFF6A1B9A) : Colors.black87,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOwned ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOwned ? Icons.check_circle : Icons.monetization_on,
                size: 14,
                color: isOwned ? Color(0xFF00897B) : Color(0xFFFF6F00),
              ),
              const SizedBox(width: 4),
              Text(
                price == 0 ? '免费' : (isOwned ? '已拥有' : '$price 金币'),
                style: TextStyle(
                  color: isOwned ? Color(0xFF00897B) : Color(0xFFFF6F00),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: isOwned
            ? Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
              )
            : ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  '购买',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Widget _buildFurnitureCard({
    required String name,
    required String emoji,
    required int price,
    required bool isOwned,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOwned
              ? [const Color(0xFFF5E9FB), const Color(0xFFFFFFFF)]
              : [const Color(0xFFFFFFFF), const Color(0xFFFDF9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isOwned
                ? Colors.purple.withOpacity(0.22)
                : Colors.black.withOpacity(0.06),
            blurRadius: isOwned ? 14 : 8,
            spreadRadius: isOwned ? 1 : 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isOwned ? const Color(0xFFBA68C8) : const Color(0xFFE0E0E0),
          width: isOwned ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBA68C8), width: 2),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 36)),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isOwned ? Color(0xFF6A1B9A) : Colors.black87,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOwned ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOwned ? Icons.check_circle : Icons.monetization_on,
                size: 14,
                color: isOwned ? Color(0xFF00897B) : Color(0xFFFF6F00),
              ),
              const SizedBox(width: 4),
              Text(
                isOwned ? '已拥有' : '$price 金币',
                style: TextStyle(
                  color: isOwned ? Color(0xFF00897B) : Color(0xFFFF6F00),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: isOwned
            ? Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
              )
            : ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  '购买',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
