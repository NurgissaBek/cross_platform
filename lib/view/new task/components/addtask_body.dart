import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/view%20model/controller/add_task_controller.dart';
import 'package:to_do_app/data/category_repository.dart';
import 'package:to_do_app/view/new%20task/components/title.dart';
import 'package:to_do_app/view/new%20task/components/upper_body.dart';
import '../../sign up/components/button.dart';
import 'add_fild.dart';
import 'datetime_row.dart';
import 'image_container_list.dart';

class TaskBody extends StatelessWidget {
  TaskBody({super.key});

  final controller = Get.put(AddTaskController());

  @override
  Widget build(BuildContext context) {
    final categoryRepo = Get.find<CategoryRepository>();
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UpperBody(),
            ImageContainerList(),
            const SizedBox(height: 20),
            TitlePeriority(),
            const SizedBox(height: 20),
            const Text(
              'Категория',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final controllerCategory = controller.category.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(),
                    ),
                    value: categoryRepo.categories
                            .contains(controllerCategory.text)
                        ? controllerCategory.text
                        : null,
                    items: categoryRepo.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controllerCategory.text = val ?? '';
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      final newCategoryC = TextEditingController();
                      Get.defaultDialog(
                        title: "Новая категория",
                        content: TextField(
                          controller: newCategoryC,
                          decoration: const InputDecoration(
                              labelText: 'Категория'),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              categoryRepo.addCategory(val.trim());
                              controllerCategory.text = val.trim();
                              Get.back();
                            }
                          },
                        ),
                        confirm: TextButton(
                          onPressed: () {
                            if (newCategoryC.text.trim().isNotEmpty) {
                              categoryRepo
                                  .addCategory(newCategoryC.text.trim());
                              controllerCategory.text =
                                  newCategoryC.text.trim();
                              Get.back();
                            }
                          },
                          child: const Text("Добавить"),
                        ),
                      );
                    },
                    child: const Text("Добавить новую категорию"),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Описание',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(height: 10),
            Obx(() => AddInputField(
                  controller: controller.description.value,
                  focus: controller.descriptionFocus.value,
                  onTap: () => controller.setDescriptionFocus(),
                  onTapOutSide: () => controller.onTapOutside(),
                  hint: 'Введите описание задачи (необязательно)',
                  width: size.width,
                )),
            const SizedBox(height: 20),
            DateTimeRow(),
            const SizedBox(height: 20),
            Obx(() => AccountButton(
                  text: 'Создать задачу',
                  loading: controller.loading.value,
                  onTap: () => controller.insertDataInDatabase(),
                )),
          ],
        ),
      ),
    );
  }
}
