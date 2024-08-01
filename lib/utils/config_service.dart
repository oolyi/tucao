import 'package:hive/hive.dart';

import 'common.dart';

class ConfigService {
  // 定义一个私有的 Box 类型变量，用于存储配置
  late final Box _box;

  // 私有的静态变量，用于存储 ConfigService 的唯一实例
  static ConfigService? _instance;

  // 工厂构造函数，返回 ConfigService 的唯一实例
  factory ConfigService() {
    return _instance ??= ConfigService._internal();
  }

  // 私有的命名构造函数，用于初始化实例
  ConfigService._internal() {
    // 调用 init 方法进行初始化
    _initialize();
  }

  // 初始化方法，用于打开名为 'config' 的 Hive Box
  void _initialize() {
    _box = Hive.box(name: 'config');
  }

  String getDomain() {
    return _box.get("domain", defaultValue: Global.siteConfig!['domain']);
  }

  void setDomain(String domain) {
    _box.put("domain", domain);
  }

  String? getProxy() {
    if (!Global.siteConfig!.containsKey("proxy")) {
      return _box.get("proxy", defaultValue: null);
    }
    if (Global.siteConfig!.containsKey("proxy")) {
      var proxy = Global.siteConfig!['proxy'];
      if (proxy == "") {
        return _box.get("proxy", defaultValue: null);
      }else{
        return _box.get("proxy",defaultValue: proxy);
      }
    }
    return _box.get("proxy");
  }

  void setProxy(String proxy) {
    _box.put("proxy", proxy);
  }

  bool getUseProxy() {
    return _box.get("useProxy", defaultValue: false);
  }

  void setUseProxy(bool useProxy) {
    _box.put("useProxy", useProxy);
  }

  bool getProxyVideo() {
    return _box.get("proxyVideo", defaultValue: false);
  }

  void setProxyVideo(bool proxyVideo) {
    _box.put("proxyVideo", proxyVideo);
  }
}
