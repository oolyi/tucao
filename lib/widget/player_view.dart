import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'player_controller.dart';

import '../utils/utils.dart';

class PlayerView extends GetView<VideoPlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final androidFullscreen = controller.androidFullscreen.value;
      final screenSize = MediaQuery.of(context).size;
      final videoHeight =
          androidFullscreen ? screenSize.height : screenSize.width * 9.0 / 16.0;
      final videoWidth =
          androidFullscreen ? screenSize.width : screenSize.width;
      return Center(
        child: SizedBox(
          width: videoWidth,
          height: videoHeight,
          child: Stack(
            children: [
              Video(controller: controller.videoController),
              DanmakuScreen(
                createdController: (e) {
                  controller.danmakuController = e;
                },
                option: DanmakuOption(),
              ),
              GestureDetector(
                onTap: () async {
                  controller.togglePositioned();
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Obx(() {
                return (controller.showPositioned.value ||
                        !controller.playing.value)
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                if (controller.androidFullscreen.value) {
                                  controller.exitFullScreen();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                            const Expanded(child: SizedBox(height: 40)),
                            TextButton(
                              style: ButtonStyle(
                                padding:
                                    WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                              onPressed: () {
                                showSetSpeedSheet();
                              },
                              child: Text(
                                '${controller.playerSpeed}X',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container();
              }),
              Obx(() {
                // 自定义播放器底部组件
                return (controller.showPositioned.value ||
                        !controller.playing.value)
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              color: Colors.white,
                              icon: Icon(controller.playing.value
                                  ? Icons.pause
                                  : Icons.play_arrow),
                              onPressed: () async {
                                await controller.playOrPause();
                              },
                            ),
                            Expanded(
                              child: ProgressBar(
                                timeLabelLocation: TimeLabelLocation.none,
                                progress: controller.currentPosition.value,
                                buffered: controller.buffered.value,
                                total: controller.duration.value,
                                onSeek: (duration) {
                                  controller.videoController.player
                                      .seek(duration);
                                },
                              ),
                            ),
                            !controller.androidFullscreen.value
                                ? Container()
                                : Container(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      "${Utils.durationToString(controller.currentPosition.value)}/${Utils.durationToString(controller.duration.value)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                            IconButton(
                              color: Colors.white,
                              icon: Icon(controller.danmakuOn.value
                                  ? Icons.comment
                                  : Icons.comments_disabled),
                              onPressed: () {
                                if (controller.danmakuOn.value) {
                                  controller.danmakuController.clear();
                                }
                                controller.danmakuOn.value =
                                    !controller.danmakuOn.value;
                              },
                            ),
                            IconButton(
                              color: Colors.white,
                              icon: Icon(controller.androidFullscreen.value
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen),
                              onPressed: () {
                                if (controller.androidFullscreen.value) {
                                  controller.exitFullScreen();
                                } else {
                                  controller.enterFullScreen();
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    : Container();
              }),
            ],
          ),
        ),
      );
    });
  }

  // 选择倍速
  void showSetSpeedSheet() {
    final double currentSpeed = controller.playerSpeed.value;
    final List<double> speedsList = [
      0.25,
      0.5,
      0.75,
      1.0,
      1.25,
      1.5,
      1.75,
      2.0
    ];
    SmartDialog.show(
        useAnimation: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('播放速度'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  for (final double i in speedsList) ...<Widget>[
                    if (i == currentSpeed) ...<Widget>[
                      FilledButton(
                        onPressed: () async {
                          await controller.setPlaybackSpeed(i);
                          SmartDialog.dismiss();
                        },
                        child: Text(i.toString()),
                      ),
                    ] else ...[
                      FilledButton.tonal(
                        onPressed: () async {
                          await controller.setPlaybackSpeed(i);
                          SmartDialog.dismiss();
                        },
                        child: Text(i.toString()),
                      ),
                    ]
                  ]
                ],
              );
            }),
            actions: <Widget>[
              TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text(
                  '取消',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await controller.setPlaybackSpeed(1.0);
                  SmartDialog.dismiss();
                },
                child: const Text('默认速度'),
              ),
            ],
          );
        });
  }
}
