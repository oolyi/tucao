import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryService {
  // 定义一个私有的 Box 类型变量，用于存储配置
  late final Box _box;

  // 私有的静态变量，用于存储 HistoryService 的唯一实例
  static HistoryService? _instance;

  // 工厂构造函数，返回 HistoryService 的唯一实例
  factory HistoryService() {
    return _instance ??= HistoryService._internal();
  }

  // 私有的命名构造函数，用于初始化实例
  HistoryService._internal() {
    // 调用 init 方法进行初始化
    _initialize();
  }

  // 初始化方法，用于打开名为 'history' 的 Hive Box
  void _initialize() {
    _box = Hive.box(name: 'history');
  }

  void addHistory(dynamic history) {
    if (_box.containsKey(history["thumb"])) {
      _box.delete(history["thumb"]);
    }
    if (_box.length >= 100) {
      _box.deleteAt(0); // 删除最旧的数据
    }
    _box.put(history["thumb"], history);
  }

  List<dynamic> getHistory(int page, int pageSize) {
    try {
      if (pageSize > _box.length) {
        return _box.getRange(0, _box.length).reversed.toList();
      }
      if (page * pageSize > _box.length) {
        return _box
            .getRange(0, pageSize - (page * pageSize - _box.length))
            .reversed
            .toList();
      }
      return _box
          .getRange(_box.length - page * pageSize,
              _box.length - (page - 1) * pageSize)
          .reversed
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  int getTotal() {
    return _box.length;
  }
}
