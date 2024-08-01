import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'common.dart';
import 'config_service.dart';
import 'parse.dart';

class NetUtils {
  late Dio _dio;
//  工厂模式
  factory NetUtils() => _getInstance()!;

  static NetUtils? get instance => _getInstance();
  static NetUtils? _instance;

  String _baseUrlConifg =
      "${Global.siteConfig!['protocol']}://${ConfigService().getDomain()}/api_v2/";

  NetUtils._internal() {
    // 初始化
    init();
  }

  static NetUtils? _getInstance() {
    _instance ??= NetUtils._internal();
    return _instance;
  }

  set baseUrlConfig(String newBaseUrlConfig) {
    _baseUrlConifg =
        "${Global.siteConfig!['protocol']}://$newBaseUrlConfig/api_v2/";
  }

  init() {
    BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(seconds: 10), // 连接超时时间，单位是秒
      receiveTimeout: const Duration(seconds: 10), // 接收超时时间，单位是秒
      //baseUrl: "https://www.xxxx/api",
    );
    _dio = Dio(baseOptions);
    if (ConfigService().getUseProxy()) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            // 将请求代理至 url。
            // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
            return 'PROXY ${Global.siteConfig!["proxy"]}';
          };
          return client;
        },
      );
    }
  }

  bool resetNet() {
    try {
      _dio.close(force: true);
      init();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getHttpIP() async {
    try {
      final response = await _dio.get('http://checkip.amazonaws.com/');
      return "当前网络IP为：${response.toString()}";
    } catch (e) {
      return "连接失败：$e";
    }
  }

  Future<String> getHttpProxyIP(String proxy) async {
    var dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5), // 连接超时时间，单位是秒
      receiveTimeout: const Duration(seconds: 3), // 接收超时时间，单位是秒
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY $proxy';
        };
        return client;
      },
    );
    try {
      final response = await dio.get('http://checkip.amazonaws.com/');
      dio.close();
      return "测试成功，IP为：${response.toString()}";
    } catch (e) {
      return "测试失败：$e";
    }
  }

  Future<List<Map<String, dynamic>>> getChannelData(String tid,
      {String page = '1', String pagesize = '10'}) async {
    Map<String, String> map = {};
    map["tid"] = tid;
    map['page'] = page;
    map['pagesize'] = pagesize;
    map['apikey'] = Global.siteConfig!['key'];
    final response =
        await _dio.get('${_baseUrlConifg}list.php', queryParameters: map);
    Map<String, dynamic> parsedJson = parseJson(response.toString());
    List<Map<String, dynamic>> result =
        parsedJson['result'].cast<Map<String, dynamic>>();
    return result;
  }

  Future<List<Map<String, dynamic>>> getsearchData(String q,
      {String page = '1', String pagesize = '10'}) async {
    Map<String, String> map = {};
    map['q'] = q;
    map['page'] = page;
    map['pagesize'] = pagesize;
    map['apikey'] = Global.siteConfig!['key'];
    map['order'] = 'views';
    final response =
        await _dio.get('${_baseUrlConifg}search.php', queryParameters: map);
    Map<String, dynamic> parsedJson = parseJson(response.toString());
    List<Map<String, dynamic>> result =
        parsedJson['result'].cast<Map<String, dynamic>>();
    return result;
  }

  Future<Uint8List> downloadImage(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  Future<String> getDanmaku(String hid, String part) async {
    final response = await _dio.get(
        "${Global.siteConfig!['protocol']}://${ConfigService().getDomain()}/index.php?m=mukio&c=index&a=init&playerID=11-$hid-1-$part");
    return response.toString();
  }
}
