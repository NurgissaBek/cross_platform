
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:to_do_app/controller/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Theme toggles correctly', () async {
    final controller = ThemeController();
    controller.toggleTheme(true);
    expect(controller.themeMode.value, ThemeMode.dark);

    controller.toggleTheme(false);
    expect(controller.themeMode.value, ThemeMode.light);
  });
}
