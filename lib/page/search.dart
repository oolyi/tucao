import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/video_list_view.dart';
import './search_controller.dart';

class SearchPage extends GetView<SiteSearchController> {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "搜点什么吧",
            suffixIcon: IconButton(
              onPressed: controller.doSearch,
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (e) {
            controller.doSearch();
          },
        ),
      ),
      body: Obx(() {
        if (controller.query.isEmpty) {
          return const Center(child: Text("请输入搜索内容"));
        } else {
          return VideoListView(
            key: ValueKey(controller.query.value), // 使用 ValueKey 确保每次搜索更新 ChannelView
            query: controller.query.value,
            dataType: DataType.search,
          );
        }
      }),
    );
  }
}
