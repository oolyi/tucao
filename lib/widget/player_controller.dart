import 'dart:async';
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../utils/common.dart';
import '../utils/config_service.dart';
import '../utils/net_utils.dart';
import '../utils/parse.dart';

class VideoPlayerController extends GetxController {
  late final Player player = Player();
  late final VideoController videoController = VideoController(player);
  final RxBool showPositioned = false.obs;
  late DanmakuController danmakuController;

  bool danmakuPaused = false;
  RxBool danmakuOn = true.obs;
  int part = 0;
  RxBool androidFullscreen = false.obs;
  Playlist? playable;
  Timer? positionedTimer;
  Timer? playerTimer;


  Rx<Duration> currentPosition = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;
  RxBool playing = true.obs;
  RxDouble playerSpeed = 1.0.obs;

  Map<int, List<DanmakuContentItem>> _danmuItems = {};

  @override
  void onInit() async {
    super.onInit();
    _playerTimer();
    var danmustring =
        await NetUtils().getDanmaku(Get.arguments['hid'], part.toString());
    _danmuItems = parseTucaoDanmu(danmustring);
    player.stream.error.listen((e) {
      debugPrint(e);
      debugPrint(player.state.playlist.toString());
      debugPrint(Get.arguments['hid']);
    });
  }

  void setPlayable(Playlist? playlist) {
    playable = playlist;
    if (playable != null) {
      _setupPlayer();
    }
  }

  Future<void> _setupPlayer() async {
    if (player.platform is NativePlayer && ConfigService().getProxyVideo()) {
      await (player.platform as NativePlayer)
          .setProperty('http-proxy', Global.siteConfig!["proxy"]);
    }
    await player.open(playable!, play: true);

  }

  void jumpToIndex(int index) async {
    player.jump(index);
    part = index;
    danmakuController.clear();
    _danmuItems = {};
    var danmustring =
        await NetUtils().getDanmaku(Get.arguments['hid'], part.toString());
    _danmuItems = parseTucaoDanmu(danmustring);
  }

  //是否需要根据播放数据调整定时器的频率，确保视频播放的每一秒都有相应的响应
  void _playerTimer() async {
    void onTimerTick() async {
      if (!danmakuController.running || !danmakuOn.value ) {
        return;
      }
      int seconds = currentPosition.value.inSeconds;
      if (_danmuItems.containsKey(seconds)) {
        _danmuItems[seconds]!.asMap().forEach((idx, ele) async {
          await Future.delayed(
              Duration(
                  milliseconds: idx * 1000 ~/ _danmuItems[seconds]!.length),
              () => {danmakuController.addDanmaku(ele)});
        });
      }
    }

    playerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentPosition.value = player.state.position;
      buffered.value = player.state.buffer;
      duration.value = player.state.duration;
      playing.value = player.state.playing;
      onTimerTick();
    });
  }

  void togglePositioned() {
    if (showPositioned.value) {
      positionedTimer!.cancel();
      positionedTimer = null;
      showPositioned.value = !showPositioned.value;
      return;
    }
    showPositioned.value = !showPositioned.value;
    positionedTimer = Timer(const Duration(seconds: 3), () {
      showPositioned.value = !showPositioned.value;
      // 取消定时器
      positionedTimer?.cancel();
      positionedTimer = null; // 重置定时器变量
    });
  }

  void exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    late SystemUiMode mode = SystemUiMode.edgeToEdge;
    if (Platform.isAndroid &&
        (await DeviceInfoPlugin().androidInfo).version.sdkInt < 29) {
      mode = SystemUiMode.manual;
    }
    await SystemChrome.setEnabledSystemUIMode(
      mode,
      overlays: SystemUiOverlay.values,
    );
    androidFullscreen.value = false;
  }

  Future<void> enterFullScreen() async {
    await AutoOrientation.landscapeAutoMode(forceSensor: true);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    androidFullscreen.value = true;
  }

  //横屏
  Future<void> landScape() async {
    try {
      await AutoOrientation.landscapeAutoMode(forceSensor: true);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> playOrPause() async {
    await player.playOrPause();
    if (player.state.playing) {
      danmakuController.pause();
      playing.value = false;
    } else {
      danmakuController.resume();
      playing.value = true;
    }
  }

  Future setPlaybackSpeed(double playerSpeed) async {
    try {
      player.setRate(playerSpeed);
      this.playerSpeed.value = playerSpeed;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onClose() {
    playerTimer?.cancel();
    player.dispose();
    super.onClose();
  }
}
