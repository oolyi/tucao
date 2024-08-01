import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/net_utils.dart';


final cacheManager = CacheManager(
  Config(
    'imageCacheKey',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 100,
  ),
);


Future<File> fetchImage(String url) async {
  final file = await cacheManager.getFileFromCache(url);
  if (file != null) {
    // 如果缓存中有文件，直接返回缓存的文件
    return file.file;
  } else {
    // 如果缓存中没有文件，使用 DIO 下载图片
    var imageData = await NetUtils().downloadImage(url);
    final file = await cacheManager.putFile(
      url,
      imageData,
    );
    return file;
  }
}

class CachedImage extends StatelessWidget {
  final String url;

  const CachedImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: fetchImage(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData) {
          return Image.file(snapshot.data!);
        } else {
          return const Icon(Icons.error);
        }
      },
    );
  }
}