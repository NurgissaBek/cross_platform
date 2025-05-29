import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final categoryC = TextEditingController(text: task.category);
    final progressC = TextEditingController(text: task.progress);

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать задачу')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: titleC,    decoration: const InputDecoration(labelText: 'Заголовок')),
          TextField(controller: descC,     decoration: const InputDecoration(labelText: 'Описание')),
          TextField(controller: categoryC, decoration: const InputDecoration(labelText: 'Категория')),
          TextField(controller: progressC, decoration: const InputDecoration(labelText: 'Прогресс (0–100%)')),

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
                progress: progressC.text.trim(),
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
