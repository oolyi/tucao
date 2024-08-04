import 'package:tucao/utils/config_service.dart';
import 'package:tucao/utils/net_utils.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

class XpathParse {

  static final String chapterResult = ConfigService().getChapterResult();

  static Future<List<Map<String, String>>> getVideoList(String hid) async {
    
    var htmlString = await NetUtils().getHtmlStringByHid(hid);
    var document = HtmlXPath.html(htmlString);
    var elements = document.query(chapterResult);
    var videoString = elements.nodes[0].text;
    return _parseVideoList(videoString!);
  }

  static List<Map<String, String>> _parseVideoList(String videoString) {
    List<Map<String, String>> videoList = [];

    // 按 '**' 分割字符串
    List<String> videos = videoString.split('**');

    for (String video in videos) {
      // 提取 type, file 和 name 信息
      RegExp typeRegExp = RegExp(r'type=([^&]+)');
      RegExp fileRegExp = RegExp(r'file=([^|]+)');
      RegExp nameRegExp = RegExp(r'\|(.+)');

      String? type = typeRegExp.firstMatch(video)?.group(1);
      String? file = fileRegExp.firstMatch(video)?.group(1);
      String? name = nameRegExp.firstMatch(video)?.group(1);

      // 使用默认值处理 null 情况
      type ??= 'null'; // 如果 type 为 null，使用 'null'
      file ??= 'null'; // 如果 file 为 null，使用 'null'
      name ??= 'null'; // 如果 name 为 null，使用 'null'

      videoList.add({
        'type': type,
        'file': file,
        'name': name,
      });
    }

    return videoList;
  }
}
