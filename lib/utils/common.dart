// 全局类，用以储存全局需要用到的信息
import 'dart:convert';

import 'package:flutter/services.dart';

class Global {
  static Map<String, dynamic>? siteConfig;

  static Future init() async {
    Map<String, dynamic> siteConfigJson = json.decode(await loadJsonData());
    siteConfig = siteConfigJson;
  }

  static Future<String> loadJsonData() async {
    String jsonStr = await rootBundle.loadString('assets/config.json');
    return jsonStr;
  }
}
