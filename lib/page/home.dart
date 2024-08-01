import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/video_list_view.dart';
import '../utils/common.dart';

class SiteHomePage extends StatefulWidget {
  const SiteHomePage({super.key});

  @override
  State<SiteHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SiteHomePage> {
  @override
  void initState() {
    // 初始化数据
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Global.siteConfig?["channels"].keys.length,
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Text(
                    Global.siteConfig?["name"] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'search',
                  onPressed: () {
                    Get.toNamed(
                      '/search',
                    );
                  }),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: getTabBar(Global.siteConfig?["channels"].keys),
              ),
            )),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  Global.siteConfig?["name"] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () {
                  Get.toNamed(
                    '/config',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('历史记录'),
                onTap: () {
                  Get.toNamed(
                    '/history',
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: getTabBarView(Global.siteConfig?["channels"]),
        ),
      ),
    );
  }

  // 获取频道
  getTabBar(channels) {
    List<Widget> channelTabs = [];
    channels.forEach((channel) {
      channelTabs.add(Text(channel));
    });
    // 返回TabBar
    return TabBar(
      isScrollable: true,
      tabs: channelTabs,
    );
  }

  getTabBarView(channels) {
    List<Widget> channelTabBarViews = [];
    // 遍历外层的 Map
    channels.forEach((key, value) {
      // 遍历内层的 Map 并提取 index 值
      value.forEach((innerKey, innerValue) {
        if (innerKey == 'index') {
          channelTabBarViews.add(VideoListView(
            query: innerValue,
            dataType: DataType.channel,
          ));
        }
      });
    });
    return channelTabBarViews;
  }
}
