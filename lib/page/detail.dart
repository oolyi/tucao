import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import '../utils/history_service.dart';
import '../widget/player_controller.dart';
import '../widget/player_view.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return DetailPageState();
  }
}

class DetailPageState extends State<DetailPage> {
  late final List<Media?> mediaList;
  Playlist? playable;
  final VideoPlayerController videoPlayerController =
      Get.put(VideoPlayerController());

  int part = 0;

  @override
  void initState() {
    super.initState();
    mediaList = Get.arguments['video']
        .map<Media?>((item) => item['file'] != null
            ? Media(item['file'], httpHeaders: {
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 6.0.1; E6653 Build/32.2.A.0.305) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2751.91 Mobile Safari/537.36',
              })
            : null)
        .toList();

    if (mediaList.contains(null)) {
      playable = null;
    } else {
      playable = Playlist(mediaList.cast<Media>(), index: 0);
      videoPlayerController.setPlayable(playable);
    }
    //添加历史记录
    HistoryService().addHistory(Get.arguments);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //Every time that user tries call pop, the method onPopInvoked is called.
        //should verify if pop already was called to prevent error
        if (didPop) {
          return;
        }
        if (videoPlayerController.androidFullscreen.value) {
          videoPlayerController.exitFullScreen();
        } else {
          Get.back();
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                playable == null
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                        child: const Center(
                            child: Text('No playable media available')))
                    : const PlayerView(),
                // 使用 Flexible 来处理空间分配
                Flexible(
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: '详情'),
                          Tab(text: '评论'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    Get.arguments['description'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: mediaList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: SizedBox(
                                          height: 40,
                                          child: InkWell(
                                            onTap: mediaList[index] == null
                                                ? null
                                                : () {
                                                    part = index;
                                                    videoPlayerController
                                                        .jumpToIndex(index);
                                                  },
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              title: Text(
                                                Get.arguments['video'][index]
                                                    ['title'],
                                                style: const TextStyle(
                                                    fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SingleChildScrollView(
                              child: Center(child: Text('暂未实现')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
