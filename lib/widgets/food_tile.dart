import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/food_item.dart';

class FoodTile extends StatefulWidget {
  final FoodItem? food;
  final bool isSelected;
  final bool isDragTarget;
  final VoidCallback onTap;
  final int row;
  final int col;

  const FoodTile({
    Key? key,
    this.food,
    this.isSelected = false,
    this.isDragTarget = false,
    required this.onTap,
    required this.row,
    required this.col,
  }) : super(key: key);

  @override
  State<FoodTile> createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> {
  @override
  Widget build(BuildContext context) {
    // 如果有食物，使其可拖拽
    if (widget.food != null) {
      return LongPressDraggable<Map<String, dynamic>>(
        data: {
          'food': widget.food,
          'row': widget.row,
          'col': widget.col,
        },
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: _getLevelColor(widget.food!.level),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.food!.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!, width: 2),
          ),
          child: Center(
            child: Icon(
              Icons.drag_indicator,
              color: Colors.grey[500],
              size: 24,
            ),
          ),
        ),
        child: _buildTileContent(),
      );
    }

    // 空格子作为拖拽目标
    return _buildTileContent();
  }

  Widget _buildTileContent() {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.food == null
              ? ((widget.row + widget.col) % 2 == 0
                  ? Colors.orange[50]
                  : Colors.orange[100])
              : _getLevelColor(widget.food!.level),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDragTarget
                ? Colors.green
                : widget.isSelected
                    ? Colors.orange[600]!
                    : Colors.orange[100]!,
            width: widget.isDragTarget || widget.isSelected ? 2.5 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.55),
                    blurRadius: 10,
                    spreadRadius: 1.5,
                    offset: const Offset(0, 3),
                  )
                ]
              : widget.isDragTarget
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.45),
                        blurRadius: 9,
                        spreadRadius: 1.5,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
        ),
        child: widget.food == null
            ? const SizedBox()
            : Center(
                child: Text(
                  widget.food!.emoji,
                  style: const TextStyle(fontSize: 40),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.08, 1.08),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .rotate(
                  begin: 0,
                  end: 0.02,
                  duration: 500.ms,
                )
                .then()
                .rotate(
                  begin: 0.02,
                  end: -0.02,
                  duration: 1000.ms,
                )
                .then()
                .rotate(
                  begin: -0.02,
                  end: 0,
                  duration: 500.ms,
                ),
              ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return Colors.green[100]!;
    if (level <= 4) return Colors.blue[100]!;
    if (level <= 6) return Colors.purple[100]!;
    if (level <= 8) return Colors.orange[100]!;
    return Colors.pink[100]!;
  }
}
