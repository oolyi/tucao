import 'package:get/get.dart';

import '../page/configuration.dart';
import '../page/detail.dart';
import '../page/history.dart';
import '../page/home.dart';
import '../page/search.dart';
import '../page/search_controller.dart';

class AppRoutes {
  AppRoutes._();
  static final routes = [
    GetPage(
      name: "/home",
      page: () => const SiteHomePage(),
    ),
    GetPage(
      name: "/detail",
      page: () => const DetailPage(),
    ),
    GetPage(
      name: "/config",
      page: () => const ConfigPage(),
            bindings: [
        BindingsBuilder.put(() => ConfigController()),
      ],
    ),
    GetPage(
      name: "/search",
      page: () => const SearchPage(),
      bindings: [
        BindingsBuilder.put(() => SiteSearchController()),
      ],
    ),
        GetPage(
      name: "/history",
      page: () => const HistoryPage(),
    ),
  ];
}
