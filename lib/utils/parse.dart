// 解析 JSON 字符串的函数
import 'dart:convert';

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

Map<String, dynamic> parseJson(String jsonString) {
  return jsonDecode(jsonString);
}

Map<int, List<DanmakuContentItem>> parseTucaoDanmu(String xmlString) {
  Map<int, List<DanmakuContentItem>> itemsGroupByTime = {};
  //List<DanmakuContentItem> items = [];

  final document = XmlDocument.parse(xmlString);

  for (final element in document.findAllElements('d')) {
    final pAttr = element.getAttribute('p');
    final text = element.innerText;

    if (pAttr != null && text.isNotEmpty) {
      final attrs = pAttr.split(',');

      if (attrs.length >= 5) {
        var time = (double.tryParse(attrs[0]) ?? 0).toInt();
        //暂时无法准确的获取开始播放视频事件，将第0秒的弹幕移动到第1秒。
        if (time == 0 ){
          time = 1;
        }
        final mode = int.tryParse(attrs[1]) ?? 0;
        DanmakuItemType type = DanmakuItemType.scroll;
        if (mode == 5) {
          type = DanmakuItemType.top;
        } else if (mode == 4) {
          type = DanmakuItemType.bottom;
        }
        //final fontSize = int.tryParse(attrs[2]) ?? 0;
        var color = (int.tryParse(attrs[3]) ?? 16777215)
            .toRadixString(16)
            .padLeft(6, "0");
        //final date = attrs[4];

        /*
        int size = 0; // default size
        if (fontSize == 18) {
          size = 1;
        } else if (fontSize == 36) {
          size = 2;
        }*/

        itemsGroupByTime.putIfAbsent(time, () => []).add(DanmakuContentItem(
              text,
              color: Color(int.parse("FF$color", radix: 16)),
              type: type,
            ));
        /*
        if (itemsGroupByTime.containsKey(time)) {
          itemsGroupByTime[time]!.add(DanmakuContentItem(
            text,
            color: Color(int.parse("FF$color", radix: 16)),
            type: type,
          ));
        } else {
          itemsGroupByTime[time] = [
            DanmakuContentItem(
              text,
              color: Color(int.parse("FF$color", radix: 16)),
              type: type,
            )
          ];
        }*/
      }
    }
  }
  return itemsGroupByTime;
}


/*
List<Map<String, dynamic>> processData(Map<String, dynamic> parsedJson) {
  //String code = parsedJson['code'];
  //int totalCount = parsedJson['total_count'];
  List<Map<String, dynamic>> result = parsedJson['result'];

  List<Map<String, dynamic>> resultMap = [];
 

  // 处理 result 列表中的每个元素
  for (var item in result) {
    String hid = item['hid'];
    String typeid = item['typeid'];
    String create = item['create'];
    String mukio = item['mukio'];
    String typename = item['typename'];
    String title = item['title'];
    String play = item['play'];
    String description = item['description'];
    String keywords = item['keywords'];
    String thumb = item['thumb'];
    String user = item['user'];
    String userid = item['userid'];
    int part = item['part'];
    List<dynamic> video = item['video'];

    // 处理 video 列表中的每个元素
    List<Map<String, dynamic>> videoList = [];
    for (var videoItem in video) {
      // 由于 videoItem 中的 key 是空字符串，所以直接访问 title
      String videoTitle = videoItem['title'];
      String videoType = videoItem['type'] ?? '';
      String videoFile = videoItem['file'] ?? '';
      videoList.add({
        'videoTitle': videoTitle,
        'videoType': videoType,
        'videoFile': videoFile,
      });
    }

    resultMap.add({
      'hid': hid,
      'typeid': typeid,
      'create': create,
      'mukio': mukio,
      'typename': typename,
      'title': title,
      'play': play,
      'description': description,
      'keywords': keywords,
      'thumb': thumb,
      'user': user,
      'userid': userid,
      'part': part,
      'video': videoList,
    });
  }
}
*/