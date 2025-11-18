import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/customer.dart';

class GridItem {
  String? foodId;
  int? level;
  
  GridItem({this.foodId, this.level});
  
  bool get isEmpty => foodId == null;
  
  void clear() {
    foodId = null;
    level = null;
  }
  
  void setFood(FoodItem food) {
    foodId = food.id;
    level = food.level;
  }
}

class GameProvider with ChangeNotifier {
  // 游戏网格 (7x5) - 7行5列
  List<List<GridItem>> grid = List.generate(
    7,
    (i) => List.generate(5, (j) => GridItem()),
  );
  
  // 当前选中的格子
  int? selectedRow;
  int? selectedCol;
  
  // 游戏统计
  int totalMerges = 0;
  int highestLevel = 1;
  
  // 顾客队列
  List<Customer> customers = [];
  Timer? customerTimer;
  final Random _random = Random();
  
  GameProvider() {
    _initializeGame();
    _startCustomerSpawning();
  }

  void _initializeGame() {
    // 初始化一些基础食材
    for (int i = 0; i < 3; i++) {
      _addRandomFood();
    }
  }

  bool serveCustomerWithTile(Customer customer, int row, int col) {
    var food = getFoodAt(row, col);
    if (food == null) {
      return false;
    }
    if (food.level != customer.requestedFood.level) {
      return false;
    }
    grid[row][col].clear();
    customer.serve();
    Future.delayed(const Duration(seconds: 2), () {
      customers.remove(customer);
      notifyListeners();
    });
    notifyListeners();
    return true;
  }

  void _addRandomFood() {
    // 找到空格子
    List<Map<String, int>> emptySpots = [];
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j].isEmpty) {
          emptySpots.add({'row': i, 'col': j});
        }
      }
    }
    
    if (emptySpots.isEmpty) return;
    
    // 随机选择一个空格子
    var spot = emptySpots[_random.nextInt(emptySpots.length)];
    
    // 添加1-3级的随机食材（用于初始化）
    int level = _random.nextInt(3) + 1;
    var food = FoodDatabase.foods.firstWhere((f) => f.level == level);
    
    grid[spot['row']!][spot['col']!].setFood(food);
    notifyListeners();
  }

  // 公开方法：使用体力生成基础食材（仅Lv.1）
  void generateRandomFood() {
    // 找到空格子
    List<Map<String, int>> emptySpots = [];
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j].isEmpty) {
          emptySpots.add({'row': i, 'col': j});
        }
      }
    }
    
    if (emptySpots.isEmpty) return;
    
    // 随机选择一个空格子
    var spot = emptySpots[_random.nextInt(emptySpots.length)];
    
    // 只生成Lv.1的基础食材（面粉、种子、咖啡豆、鱼卵）
    final level1Foods = FoodDatabase.foods.where((f) => f.level == 1).toList();
    var food = level1Foods[_random.nextInt(level1Foods.length)];
    
    grid[spot['row']!][spot['col']!].setFood(food);
    notifyListeners();
  }

  void selectTile(int row, int col) {
    if (selectedRow == row && selectedCol == col) {
      // 取消选择
      selectedRow = null;
      selectedCol = null;
    } else if (selectedRow == null) {
      // 第一次选择
      if (!grid[row][col].isEmpty) {
        selectedRow = row;
        selectedCol = col;
      }
    } else {
      // 第二次选择 - 尝试合并或交换
      if (grid[row][col].isEmpty) {
        // 移动到空格子
        _moveTile(selectedRow!, selectedCol!, row, col);
      } else if (grid[selectedRow!][selectedCol!].level == grid[row][col].level) {
        // 合并相同等级
        _mergeTiles(selectedRow!, selectedCol!, row, col);
      }
      
      selectedRow = null;
      selectedCol = null;
    }
    notifyListeners();
  }

  // 拖拽操作
  void dragTile(int fromRow, int fromCol, int toRow, int toCol) {
    // 拖到自己身上，不做任何操作
    if (fromRow == toRow && fromCol == toCol) {
      return;
    }
    
    // 目标格子为空，移动
    if (grid[toRow][toCol].isEmpty) {
      _moveTile(fromRow, fromCol, toRow, toCol);
    } 
    // 目标格子有食物且等级相同，合并
    else if (grid[fromRow][fromCol].level == grid[toRow][toCol].level) {
      _mergeTiles(fromRow, fromCol, toRow, toCol);
    }
    
    notifyListeners();
  }

  void _moveTile(int fromRow, int fromCol, int toRow, int toCol) {
    grid[toRow][toCol].foodId = grid[fromRow][fromCol].foodId;
    grid[toRow][toCol].level = grid[fromRow][fromCol].level;
    grid[fromRow][fromCol].clear();
  }

  void _mergeTiles(int fromRow, int fromCol, int toRow, int toCol) {
    int currentLevel = grid[fromRow][fromCol].level!;
    int newLevel = currentLevel + 1;
    
    // 查找新等级的食材
    var newFood = FoodDatabase.foods.firstWhere(
      (f) => f.level == newLevel,
      orElse: () => FoodDatabase.foods.last,
    );
    
    // 合并到目标格子
    grid[toRow][toCol].setFood(newFood);
    grid[fromRow][fromCol].clear();
    
    // 更新统计
    totalMerges++;
    if (newLevel > highestLevel) {
      highestLevel = newLevel;
    }
    
    // 有概率生成新食材
    if (_random.nextDouble() < 0.3) {
      _addRandomFood();
    }
  }
  
  // 获取合成次数（用于成就系统）
  int getMergeCount() => totalMerges;

  FoodItem? getFoodAt(int row, int col) {
    var item = grid[row][col];
    if (item.isEmpty) return null;
    return FoodDatabase.getFoodById(item.foodId!);
  }

  bool hasFoodForCustomer(Customer customer) {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        var food = getFoodAt(i, j);
        if (food != null && food.level == customer.requestedFood.level) {
          return true;
        }
      }
    }
    return false;
  }

  // 顾客系统
  void _startCustomerSpawning() {
    customerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _spawnCustomer();
    });
    
    // 立即生成第一个顾客
    _spawnCustomer();
  }

  void _spawnCustomer() {
    if (customers.length >= 3) return; // 最多3个顾客
    
    var nameData = CustomerDatabase.customerNames[
      _random.nextInt(CustomerDatabase.customerNames.length)
    ];
    
    // 请求1-5级的食物
    int requestLevel = _random.nextInt(5) + 1;
    var requestedFood = FoodDatabase.foods.firstWhere(
      (f) => f.level == requestLevel,
    );
    
    var customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameData['name']!,
      nameCn: nameData['nameCn']!,
      avatar: nameData['avatar']!,
      requestedFood: requestedFood,
      patience: 30 + _random.nextInt(30), // 30-60秒
      tip: requestedFood.price ~/ 2,
    );
    
    customers.add(customer);
    notifyListeners();
  }

  void serveCustomer(Customer customer) {
    // 检查是否有对应的食物
    FoodItem? foundFood;
    int? foundRow;
    int? foundCol;
    
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        var food = getFoodAt(i, j);
        if (food != null && food.level == customer.requestedFood.level) {
          foundFood = food;
          foundRow = i;
          foundCol = j;
          break;
        }
      }
      if (foundFood != null) break;
    }
    
    if (foundFood != null && foundRow != null && foundCol != null) {
      // 移除食物
      grid[foundRow][foundCol].clear();
      
      // 标记顾客为已服务
      customer.serve();
      
      // 延迟移除顾客
      Future.delayed(const Duration(seconds: 2), () {
        customers.remove(customer);
        notifyListeners();
      });
      
      notifyListeners();
    }
  }

  void updateCustomerPatience() {
    bool needsUpdate = false;
    
    for (var customer in customers) {
      if (!customer.isServed) {
        customer.decreasePatience();
        if (customer.isAngry) {
          // 顾客生气离开
          customers.remove(customer);
          needsUpdate = true;
          break;
        }
      }
    }
    
    if (needsUpdate) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    customerTimer?.cancel();
    super.dispose();
  }
}
