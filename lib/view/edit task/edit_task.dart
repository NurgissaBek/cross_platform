import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/data/category_repository.dart';
import '../../model/task_model.dart';
import '../../view model/controller/home_controller.dart';

class EditTaskPage extends StatelessWidget {
  final TaskModel task;
  final int index;

  const EditTaskPage({super.key, required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    final titleC    = TextEditingController(text: task.title);
    final descC     = TextEditingController(text: task.description);
    final categoryC  = TextEditingController(text: task.category);
    final categoryRepo = Get.find<CategoryRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать задачу'),
      actions: [
        IconButton(icon: const Icon(Icons.close),
        onPressed: ()=>Get.back(),)
      ],),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: titleC,    decoration: const InputDecoration(labelText: 'Заголовок')),
          TextField(controller: descC,     decoration: const InputDecoration(labelText: 'Описание')),
          
          Obx(() => DropdownButtonFormField<String>(
            value: categoryRepo.categories.contains(categoryC.text) ? categoryC.text : null,
            items: categoryRepo.categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              categoryC.text = val ?? '';
            },
            decoration: const InputDecoration(labelText: 'Категория'),
          )),

          TextButton(
            onPressed: () {
              final newCategoryC = TextEditingController();
              Get.defaultDialog(
                title: "Новая категория",
                content: TextField(
                  controller: newCategoryC,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      categoryRepo.addCategory(val.trim());
                      categoryC.text = val.trim();
                      Get.back();
                    }
                  },
                ),
                confirm: TextButton(
                  onPressed: () {
                    if (newCategoryC.text.trim().isNotEmpty) {
                      categoryRepo.addCategory(newCategoryC.text.trim());
                      categoryC.text = newCategoryC.text.trim();
                      Get.back();
                    }
                  },
                  child: const Text("Добавить"),
                ),
              );
            },
            child: const Text("Добавить новую категорию"),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final updated = TaskModel(
                key: task.key,
                title: titleC.text.trim(),
                description: descC.text.trim(),
                category: categoryC.text.trim(),
                image: task.image,
                date: task.date,
                time: task.time,
                periority: task.periority,
                show: task.show,
                status: task.status,
              );
              await Get.find<HomeController>().updateTask(index, updated);
              Get.back();
            },
            child: const Text('Сохранить'),
          )
        ],
      ),
    );
  }
}
