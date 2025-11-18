class FoodItem {
  final String id;
  final String name;
  final String nameCn; // 中文名称
  final int level;
  final String emoji;
  final int price; // 售价
  final int mergeTime; // 合成时间（秒）
  
  FoodItem({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.level,
    required this.emoji,
    required this.price,
    this.mergeTime = 0,
  });

  // 复制并修改
  FoodItem copyWith({
    String? id,
    String? name,
    String? nameCn,
    int? level,
    String? emoji,
    int? price,
    int? mergeTime,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameCn: nameCn ?? this.nameCn,
      level: level ?? this.level,
      emoji: emoji ?? this.emoji,
      price: price ?? this.price,
      mergeTime: mergeTime ?? this.mergeTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameCn': nameCn,
      'level': level,
      'emoji': emoji,
      'price': price,
      'mergeTime': mergeTime,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      nameCn: json['nameCn'],
      level: json['level'],
      emoji: json['emoji'],
      price: json['price'],
      mergeTime: json['mergeTime'] ?? 0,
    );
  }
}

// 预定义食材等级
class FoodDatabase {
  static final List<FoodItem> foods = [
    // Level 1-5: 基础食材
    FoodItem(id: 'bread_1', name: 'Flour', nameCn: '面粉', level: 1, emoji: '🌾', price: 5),
    FoodItem(id: 'bread_2', name: 'Dough', nameCn: '面团', level: 2, emoji: '🥖', price: 15),
    FoodItem(id: 'bread_3', name: 'Bread', nameCn: '面包', level: 3, emoji: '🍞', price: 40),
    FoodItem(id: 'bread_4', name: 'Toast', nameCn: '吐司', level: 4, emoji: '🥐', price: 100),
    FoodItem(id: 'bread_5', name: 'Croissant', nameCn: '可颂', level: 5, emoji: '🥯', price: 250),
    
    // Level 1-5: 蔬菜系列
    FoodItem(id: 'veg_1', name: 'Seeds', nameCn: '种子', level: 1, emoji: '🌱', price: 5),
    FoodItem(id: 'veg_2', name: 'Sprout', nameCn: '嫩芽', level: 2, emoji: '🌿', price: 15),
    FoodItem(id: 'veg_3', name: 'Lettuce', nameCn: '生菜', level: 3, emoji: '🥬', price: 40),
    FoodItem(id: 'veg_4', name: 'Salad', nameCn: '沙拉', level: 4, emoji: '🥗', price: 100),
    FoodItem(id: 'veg_5', name: 'Caesar Salad', nameCn: '凯撒沙拉', level: 5, emoji: '🥙', price: 250),
    
    // Level 1-5: 咖啡系列
    FoodItem(id: 'coffee_1', name: 'Coffee Bean', nameCn: '咖啡豆', level: 1, emoji: '🫘', price: 5),
    FoodItem(id: 'coffee_2', name: 'Ground Coffee', nameCn: '咖啡粉', level: 2, emoji: '☕', price: 15),
    FoodItem(id: 'coffee_3', name: 'Espresso', nameCn: '浓缩咖啡', level: 3, emoji: '☕', price: 40),
    FoodItem(id: 'coffee_4', name: 'Latte', nameCn: '拿铁', level: 4, emoji: '🥤', price: 100),
    FoodItem(id: 'coffee_5', name: 'Cappuccino', nameCn: '卡布奇诺', level: 5, emoji: '🍵', price: 250),
    
    // Level 1-5: 海鲜系列
    FoodItem(id: 'seafood_1', name: 'Fish Egg', nameCn: '鱼卵', level: 1, emoji: '🥚', price: 5),
    FoodItem(id: 'seafood_2', name: 'Small Fish', nameCn: '小鱼', level: 2, emoji: '🐟', price: 15),
    FoodItem(id: 'seafood_3', name: 'Fish', nameCn: '鱼', level: 3, emoji: '🐠', price: 40),
    FoodItem(id: 'seafood_4', name: 'Grilled Fish', nameCn: '烤鱼', level: 4, emoji: '🍣', price: 100),
    FoodItem(id: 'seafood_5', name: 'Seafood Platter', nameCn: '海鲜拼盘', level: 5, emoji: '🦞', price: 250),
    
    // Level 6-10: 高级料理
    FoodItem(id: 'dessert_1', name: 'Sugar', nameCn: '糖', level: 6, emoji: '🧂', price: 500),
    FoodItem(id: 'dessert_2', name: 'Cookie', nameCn: '饼干', level: 7, emoji: '🍪', price: 1000),
    FoodItem(id: 'dessert_3', name: 'Cake', nameCn: '蛋糕', level: 8, emoji: '🍰', price: 2000),
    FoodItem(id: 'dessert_4', name: 'Ice Cream', nameCn: '冰淇淋', level: 9, emoji: '🍨', price: 4000),
    FoodItem(id: 'dessert_5', name: 'Deluxe Dessert', nameCn: '豪华甜点', level: 10, emoji: '🎂', price: 8000),
  ];

  static FoodItem? getFoodByLevel(int level) {
    try {
      return foods.firstWhere((food) => food.level == level);
    } catch (e) {
      return null;
    }
  }

  static FoodItem? getFoodById(String id) {
    try {
      return foods.firstWhere((food) => food.id == id);
    } catch (e) {
      return null;
    }
  }
}
