import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SiteSearchController extends GetxController {
  TextEditingController searchController = TextEditingController();
  final query = ''.obs;

  void doSearch() async {
    query.value = searchController.text;
  }
}
