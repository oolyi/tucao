import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/history_service.dart';
import '../widget/cached_image.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
      ),
      body: EasyRefresh(
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        child: Obx(() => CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index >= controller.items.length) {
                        return null;
                      }
                      return Column(
                        children: [
                          ListTile(
                            leading: SizedBox(
                              width: 100,
                              child: CachedImage(
                                  url: controller.items[index]["thumb"]),
                            ),
                            title: Text(controller.items[index]["title"]),
                            onTap: () {
                              Get.toNamed(
                                '/detail',
                                arguments: controller.items[index],
                              );
                            },
                          ),
                          const Divider(), // 添加分割线
                        ],
                      );
                    },
                    childCount: controller.items.length,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class HistoryController extends GetxController {
  RxList items = <dynamic>[].obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<dynamic> newItems;
      newItems = HistoryService().getHistory(currentPage.value, pageSize);
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

    await fetchData();
  }

  Future<void> onLoad() async {
    if (!hasMore.value) return;
    await fetchData();
  }
}
