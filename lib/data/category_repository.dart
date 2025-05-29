import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryRepository extends GetxController {
  RxList<String> categories = <String>[].obs;

  final String _key = 'categories';

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    categories.value = prefs.getStringList(_key) ?? ['Работа', 'Учёба', 'Дом'];
  }

  Future<void> addCategory(String category) async {
    if (!categories.contains(category)) {
      categories.add(category);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(_key, categories);
    }
  }
}
