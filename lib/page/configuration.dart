import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/config_service.dart';
import '../utils/net_utils.dart';

class ConfigController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final domainTextController =
      TextEditingController(text: ConfigService().getDomain());
  final proxyTextController =
      TextEditingController(text: ConfigService().getProxy());
  RxBool useProxy = ConfigService().getUseProxy().obs;
  RxBool proxyVideo = ConfigService().getProxyVideo().obs;

  RxBool enableCheckbox =
      (ConfigService().getProxy() ?? '').isEmpty ? false.obs : true.obs;
      
  @override
  void onClose() {
    domainTextController.dispose();
    proxyTextController.dispose();
    super.onClose();
  }
}

class ConfigPage extends GetView<ConfigController> {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '域名',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              TextFormField(
                controller: controller.domainTextController,
                decoration: const InputDecoration(
                  hintText: '请输入当前可用的域名',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '域名不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                '代理',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              TextFormField(
                controller: controller.proxyTextController,
                decoration: const InputDecoration(
                  hintText: '请输入代理（仅支持http/https代理）',
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.enableCheckbox.value = false;
                    controller.useProxy.value = false;
                    controller.proxyVideo.value = false;
                  } else {
                    controller.enableCheckbox.value = true;
                  }
                },
              ),
              Row(children: [
                ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(await NetUtils().getHttpProxyIP(
                              controller.proxyTextController.text))),
                    );
                  },
                  child: const Text("测试代理"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(await NetUtils().getHttpIP())),
                    );
                  },
                  child: const Text("当前网络"),
                ),
              ]),
              Obx(() => CheckboxListTile(
                    title: const Text("使用代理"),
                    value: controller.useProxy.value,
                    onChanged: (newValue) {
                      controller.useProxy.value = newValue!;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    enabled: controller.enableCheckbox.value,
                  )),
              Obx(() => CheckboxListTile(
                    title: const Text("代理视频"),
                    value: controller.proxyVideo.value,
                    onChanged: (newValue) {
                      controller.proxyVideo.value = newValue!;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    enabled: controller.enableCheckbox.value,
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      NetUtils().baseUrlConfig =
                          controller.domainTextController.text;
                      ConfigService()
                          .setDomain(controller.domainTextController.text);
                      ConfigService()
                          .setProxy(controller.proxyTextController.text);

                      ConfigService().setUseProxy(controller.useProxy.value);
                      ConfigService()
                          .setProxyVideo(controller.proxyVideo.value);
                      NetUtils().resetNet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('配置已修改')),
                      );
                    }
                  },
                  child: const Text('确认'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
