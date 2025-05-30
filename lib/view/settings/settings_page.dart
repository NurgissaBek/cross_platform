
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController controller = Get.find<ThemeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(
        () => SwitchListTile(
          title: const Text('Dark Mode'),
          value: controller.themeMode.value == ThemeMode.dark,
          onChanged: controller.toggleTheme,
        ),
      ),
    );
  }
}
