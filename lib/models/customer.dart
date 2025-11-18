import 'food_item.dart';

class Customer {
  final String id;
  final String name;
  final String nameCn;
  final String avatar; // emoji
  final FoodItem requestedFood;
  final int patience; // 耐心值（秒）
  final int tip; // 小费
  
  int remainingTime;
  bool isServed;
  
  Customer({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.avatar,
    required this.requestedFood,
    required this.patience,
    required this.tip,
  }) : remainingTime = patience,
       isServed = false;

  double get patiencePercentage => remainingTime / patience;
  
  bool get isAngry => remainingTime <= 0;

  void decreasePatience() {
    if (remainingTime > 0) {
      remainingTime--;
    }
  }

  void serve() {
    isServed = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameCn': nameCn,
      'avatar': avatar,
      'requestedFood': requestedFood.toJson(),
      'patience': patience,
      'tip': tip,
      'remainingTime': remainingTime,
      'isServed': isServed,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      nameCn: json['nameCn'],
      avatar: json['avatar'],
      requestedFood: FoodItem.fromJson(json['requestedFood']),
      patience: json['patience'],
      tip: json['tip'],
    )..remainingTime = json['remainingTime']
     ..isServed = json['isServed'];
  }
}

// 顾客名字库
class CustomerDatabase {
  static final List<Map<String, String>> customerNames = [
    {'name': 'Emma', 'nameCn': '艾玛', 'avatar': '👩'},
    {'name': 'Liam', 'nameCn': '利亚姆', 'avatar': '👨'},
    {'name': 'Olivia', 'nameCn': '奥利维亚', 'avatar': '👩‍🦰'},
    {'name': 'Noah', 'nameCn': '诺亚', 'avatar': '👨‍🦱'},
    {'name': 'Sophia', 'nameCn': '索菲亚', 'avatar': '👩‍🦳'},
    {'name': 'Mason', 'nameCn': '梅森', 'avatar': '👨‍🦲'},
    {'name': 'Isabella', 'nameCn': '伊莎贝拉', 'avatar': '👧'},
    {'name': 'James', 'nameCn': '詹姆斯', 'avatar': '👦'},
  ];
}
