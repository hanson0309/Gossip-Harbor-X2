import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  Restaurant restaurant = Restaurant();
  bool _isLoaded = false;
  Timer? _energyTimer;

  RestaurantProvider() {
    _loadData();
    _startEnergyTimer();
  }

  Future<void> _loadData() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('restaurant_data');
    
    if (data != null) {
      try {
        restaurant = Restaurant.fromJson(jsonDecode(data));
        // 加载后立即更新体力值
        restaurant.updateEnergy();
      } catch (e) {
        // 如果加载失败，使用默认值
        restaurant = Restaurant();
      }
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  // 启动体力自动恢复定时器（每分钟检查一次）
  void _startEnergyTimer() {
    _energyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      restaurant.updateEnergy();
      _saveData();
      notifyListeners();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('restaurant_data', jsonEncode(restaurant.toJson()));
  }

  void earnCoins(int amount) {
    restaurant.addCoins(amount);
    _saveData();
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (restaurant.coins >= amount) {
      restaurant.spendCoins(amount);
      _saveData();
      notifyListeners();
    }
  }

  void earnExperience(int amount) {
    restaurant.addExperience(amount);
    _saveData();
    notifyListeners();
  }

  bool canAfford(int price) {
    return restaurant.coins >= price;
  }

  void changeFloor(String type, int price) {
    if (canAfford(price)) {
      spendCoins(price);
      restaurant.changeFloor(type);
      _saveData();
      notifyListeners();
    }
  }

  void changeWallpaper(String type, int price) {
    if (canAfford(price)) {
      spendCoins(price);
      restaurant.changeWallpaper(type);
      _saveData();
      notifyListeners();
    }
  }

  void buyFurniture(String furnitureId, int price) {
    if (canAfford(price)) {
      spendCoins(price);
      restaurant.unlockFurniture(furnitureId);
      _saveData();
      notifyListeners();
    }
  }

  bool hasFurniture(String furnitureId) {
    return restaurant.unlockedFurniture.contains(furnitureId);
  }

  bool useEnergy(int amount) {
    if (restaurant.useEnergy(amount)) {
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // 使用体力生成食材
  bool useEnergyToGenerateFood(int energyCost) {
    return useEnergy(energyCost);
  }

  // 手动更新体力（用于UI刷新）
  void updateEnergy() {
    restaurant.updateEnergy();
    notifyListeners();
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }
}
