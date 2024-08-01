import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'page/home.dart';
import 'utils/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'utils/route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //video player
  MediaKit.ensureInitialized();
  //hive
  final directory = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = directory.path;
  Global.init().whenComplete(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Global.siteConfig!["name"],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      getPages: AppRoutes.routes,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      //onGenerateRoute: onGenerateRoute,
      home: const SiteHomePage(),
    );
  }
}
