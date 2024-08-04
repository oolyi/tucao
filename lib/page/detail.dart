import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import '../utils/history_service.dart';
import '../utils/xpath_parse.dart';
import '../widget/player_controller.dart';
import '../widget/player_view.dart';

class DetailPageController extends GetxController {
  RxList videoTitleList = [].obs;
  RxBool isLoading = true.obs; // 用于跟踪加载状态
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return DetailPageState();
  }
}

class DetailPageState extends State<DetailPage> {
  final DetailPageController detailPageController =
      Get.put(DetailPageController());

  List<Media?> mediaList = [];
  Rx<Playlist?> playable = Rx<Playlist?>(null); // Rx<Playlist?> 类型的可观察对象
  VideoPlayerController? videoPlayerController;

  var httpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 6.0.1; E6653 Build/32.2.A.0.305) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2751.91 Mobile Safari/537.36',
  };

  int part = 0;

  void _loadData() async {
    // 将加载状态设置为 true
    detailPageController.isLoading.value = true;

    try {
      var videoListByHtml = await XpathParse.getVideoList(Get.arguments['hid']);
      if (videoListByHtml.isNotEmpty) {
        mediaList.clear();

        for (int index = 0; index < videoListByHtml.length; index++) {
          var item = videoListByHtml[index];
          final file = item['file'];

          if (file != 'null') {
            mediaList.add(Media(file!));
            final name = item['name'];
            detailPageController.videoTitleList.add(
              name != 'null' ? name : (index + 1).toString(),
            );
          } else {
            mediaList.add(null);
          }
        }
      }

      if (mediaList.contains(null) || mediaList.isEmpty) {
        mediaList.clear();

        for (int index = 0; index < Get.arguments['video'].length; index++) {
          var item = Get.arguments['video'][index];
          final file = item['file'];

          if (file != null) {
            mediaList.add(Media(file));
            final name = item['title'];
            detailPageController.videoTitleList.add(
              name ?? (index + 1).toString(),
            );
          } else {
            mediaList.add(null);
          }
        }
      }

      if (!mediaList.contains(null)) {
        playable.value = Playlist(mediaList.cast<Media>(), index: 0);
        Get.lazyPut<VideoPlayerController>(() => VideoPlayerController());
        videoPlayerController = Get.find<VideoPlayerController>();
        videoPlayerController!.setPlayable(playable.value!);
      }
    } finally {
      // 将加载状态设置为 false，不论成功与否
      detailPageController.isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    // 添加历史记录
    HistoryService().addHistory(Get.arguments);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        if (videoPlayerController?.androidFullscreen.value ?? false) {
          videoPlayerController?.exitFullScreen();
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
                Obx(() {
                  if (detailPageController.isLoading.value) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (playable.value == null) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                      child: const Center(
                        child: Text('No playable media available'),
                      ),
                    );
                  } else {
                    return const PlayerView();
                  }
                }),
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
                                  child: Obx(() {
                                    return ListView.builder(
                                      itemCount: detailPageController
                                          .videoTitleList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: SizedBox(
                                            height: 40,
                                            child: InkWell(
                                              onTap: detailPageController
                                                              .videoTitleList[
                                                          index] ==
                                                      null
                                                  ? null
                                                  : () {
                                                      part = index;
                                                      videoPlayerController
                                                          ?.jumpToIndex(index);
                                                    },
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                title: Text(
                                                  detailPageController
                                                      .videoTitleList[index],
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
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
