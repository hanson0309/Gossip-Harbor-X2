# Gossip-Harbor-X2

一个用 Flutter 编写的合成 + 餐厅经营小游戏原型。

玩家通过在棋盘上合成食物、服务顾客、赚取金币，然后用金币装修自己的小餐厅，让餐厅变得更可爱、更有人气。

---

## 游戏简介

- **合成食物**：在 5x7 棋盘上拖拽、合并相同食物提升等级。
- **服务顾客**：把食物从棋盘拖到顾客卡片上，满足顾客需求获得金币和经验。
- **餐厅装修**：使用金币购买地板、壁纸、家具，提升餐厅的人气值，人气越高预览中顾客越多越热闹。
- **体力系统**：生成新食物需要体力，体力会随时间自动恢复。

本项目主要用于尝试「可爱风 UI」和轻度休闲玩法的组合，并不代表最终上线版本。

---

## 核心玩法

### 1. 合成与点单

- 棋盘为 5x7 网格。
- 拖拽相同食物到一起可以合成更高等级的食物。
- 将食物从棋盘拖到顾客卡片上即可完成订单。
- 顾客有耐心值，使用表情 + 进度条表现，超时会离开。

### 2. 餐厅装修

- 在「餐厅装修」界面中可以：
  - 切换 **地板**、**壁纸**、**家具**。
  - 不同装饰有不同价格，部分免费，部分需要金币购买。
- 当前装修组合会影响「**人气值**」：
  - 更高级/更贵的装饰贡献更高人气。
  - 人气越高，预览区域中出现的顾客 Emoji 越多，动画也更热闹。

### 3. 成长与资源

- **金币**：通过完成顾客订单获得，用于购买装饰。
- **经验 & 等级**：完成订单获得经验，经验累积提升餐厅等级。
- **体力**：生成新食物会消耗体力，体力按分钟自动恢复到上限。

---

## 主要界面 & 模块

- `lib/screens/merge_game_screen.dart`
  - 主游戏界面：顾客队列 + 食物棋盘 + 生成食物按钮。
  - 支持拖拽合成、拖拽到顾客完成订单。

- `lib/screens/decoration_screen.dart`
  - 餐厅装修界面：
    - 顶部金币展示。
    - 餐厅预览（墙面、地板、家具、人气条、小顾客动画）。
    - 装修分类 Tab（地板 / 壁纸 / 家具）。
    - 装修项列表卡片（购买 / 已拥有样式）。

- `lib/screens/achievement_screen.dart`
  - 成就相关界面（用于后续扩展）。

- `lib/providers/game_provider.dart`
  - 管理棋盘、合成逻辑、顾客生成与服务等。

- `lib/providers/restaurant_provider.dart`
  - 管理餐厅等级、金币、体力、经验、已解锁装饰等，并用 `shared_preferences` 本地存档。

- `lib/models/restaurant.dart`
  - `Restaurant` 模型：等级、金币、经验、体力、当前地板/壁纸、已解锁家具。
  - `DecorationOptions`：地板、壁纸、家具选项及价格、颜色等配置。

- `lib/widgets/food_tile.dart`
  - 单个食物格子组件，支持显示食物、拖拽、选中等效果。

- `lib/widgets/dialog_box.dart`
  - 通用确认弹窗（购买时确认等）。

---

## 技术栈

- **Flutter**
- **provider**：状态管理
- **flutter_animate**：UI 动效（例如顾客、家具、状态图标动画）
- **shared_preferences**：简单本地存档

---

## 本地运行

### 前置条件

- 已安装 Flutter SDK（建议使用最新稳定版）。
- 已正确配置 `flutter doctor`.

### 安装依赖

```bash
flutter pub get
```

### 运行到浏览器（Chrome）

```bash
flutter run -d chrome
```

### 运行到其它设备

```bash
flutter devices   # 查看可用设备
flutter run       # 运行到当前选中的设备
```

---

## English (brief)

Gossip-Harbor-X2 is a small Flutter prototype that mixes a merge board with
customer orders and a cozy restaurant decoration loop. You merge food items
on a 5x7 grid, drag dishes to customers to earn coins and experience, and use
coins to decorate your restaurant (floors, wallpapers, furniture) to increase
its popularity. The project is mainly for experimenting with cute UI layouts
and casual game mechanics.
