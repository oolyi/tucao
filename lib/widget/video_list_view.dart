import 'dart:typed_data';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../utils/net_utils.dart';

enum DataType { channel, search }

class VideoListView extends StatelessWidget {
  final String query;
  final DataType dataType;

  const VideoListView({required this.query, required this.dataType, super.key});

  @override
  Widget build(BuildContext context) {
    final channelController =
        Get.put(VideoListController(query, dataType), tag: query);

    return Obx(() {
      if (channelController.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (channelController.items.any((item) => item.containsKey("error"))) {
        return Center(
            child: Text(
                'Error: ${channelController.items.firstWhere((item) => item.containsKey("error"))["error"]}'));
      }

      return EasyRefresh(
        onRefresh: channelController.onRefresh,
        onLoad: channelController.onLoad,
        controller: channelController.refreshController,
        child: CustomScrollView(
          slivers: [
            if (channelController.items.any((item) => item.containsKey("noData")))
              const SliverFillRemaining(
                child: Center(child: Text('No data')),
              )
            else
              SliverToBoxAdapter(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  controller: channelController.scrollController,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: channelController.items.length,
                  itemBuilder: (context, index) {
                    final item = channelController.items[index];
                    final imageUrl = item["thumb"];
                    final title = item["title"];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/detail',
                          arguments: item,
                        );
                      },
                      child: FutureBuilder<Uint8List>(
                        future: channelController.getImage(imageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error loading image: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            try {
                              return Card(
                                child: Column(
                                  children: [
                                    Image.memory(snapshot.data!),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(title),
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              return Center(
                                  child: Text('Failed to load image: $e'));
                            }
                          } else {
                            return const Center(
                                child: Text('No image available'));
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

class VideoListController extends GetxController {
  final String query;
  final DataType dataType;
  var items = <Map<String, dynamic>>[].obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  static const int pageSize = 8;
  final Map<String, Uint8List> _imageCache = {};
  final refreshController = EasyRefreshController();
  final ScrollController scrollController = ScrollController();

  VideoListController(this.query, this.dataType);

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> newItems;
      if (dataType == DataType.channel) {
        newItems = await NetUtils().getChannelData(query,
            page: currentPage.toString(), pagesize: pageSize.toString());
      } else {
        newItems = await NetUtils().getsearchData(query,
            page: currentPage.toString(), pagesize: pageSize.toString());
      }
      items.addAll(newItems);
      currentPage++;
      hasMore.value = newItems.length == pageSize;
    } catch (e) {
      items.add({"noData": true});
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> onRefresh() async {
    currentPage.value = 1;
    items.clear();
    _imageCache.clear();
    await fetchData();
  }

  Future<void> onLoad() async {
    if (!hasMore.value) return;
    await fetchData();
  }

  Future<Uint8List> getImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url]!;
    } else {
      final imageData = await NetUtils().downloadImage(url);
      _imageCache[url] = imageData;
      return imageData;
    }
  }
}
