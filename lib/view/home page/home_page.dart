import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/res/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:to_do_app/res/assets/app_icons.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';
import 'package:to_do_app/view/common%20widgets/back_button.dart';
import 'package:to_do_app/view/home%20page/components/progress_task.dart';
import 'package:to_do_app/view/home%20page/components/search_field.dart';
import 'package:to_do_app/view/new%20task/new_task.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      floatingActionButton: GestureDetector(
        onTap: () => showNewTaskModal(context),
        child: Container(
          height: 65,
          width: 65,
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            gradient: const LinearGradient(colors: [
              Colors.pinkAccent,
              Colors.purpleAccent,
            ]),
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // запас под FAB
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(AppIcon.menu,
                        color: Colors.white, height: 30, width: 30),
                    Column(
                      children: [
                        Obx(
                          () => Text(
                            'Hi, ${controller.name}',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        Text(
                          Utils.formatDate(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Get.toNamed('/profile'),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              /// Search
              SearchField(),
              const SizedBox(height: 30),

              /// Progress Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Obx(() => controller.hasData.value
                    ? RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: 'Progress  ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          ),
                          TextSpan(
                            text: '(${controller.taskCount}) ',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                          ),
                        ]),
                      )
                    : const SizedBox()),
              ),
              const SizedBox(height: 15),

              /// Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => DropdownButton<String>(
                          value: controller.selectedFilter.value,
                          dropdownColor: primaryColor,
                          items: ['all', 'completed', 'unComplete']
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(val,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            controller.selectedFilter.value = val!;
                            controller.applyFilters();
                            controller.update();
                          },
                        )),
                    Obx(() => DropdownButton<String>(
                          value: controller.selectedCategory.value,
                          dropdownColor: primaryColor,
                          items: [
                            'all',
                            ...controller.list
                                .map((e) => e.category)
                                .toSet()
                          ]
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(val ?? '',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            controller.selectedCategory.value = val!;
                            controller.applyFilters();
                            controller.update();
                          },
                        )),
                    Obx(() => DropdownButton<String>(
                          value: controller.selectedPriority.value,
                          dropdownColor: primaryColor,
                          items: ['all', 'Low', 'High']
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(val,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            controller.selectedPriority.value = val!;
                            controller.applyFilters();
                            controller.update();
                          },
                        )),
                    Obx(() => DropdownButton<String>(
                          value: controller.selectedSort.value,
                          dropdownColor: primaryColor,
                          items: [
                            'none',
                            'title_asc',
                            'title_desc',
                            'date_asc',
                            'date_desc',
                            'priority_high',
                            'priority_low',
                          ]
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(
                                        val.replaceAll('_', ' '),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            controller.selectedSort.value = val!;
                            controller.applyFilters();
                            controller.update();
                          },
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ProgressTask(),
              const SizedBox(height: 30),

              /// Tasks Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Obx(() => controller.hasData.value
                    ? const Text(
                        'Tasks',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      )
                    : const SizedBox()),
              ),
              const SizedBox(height: 20),

              /// Task List
              Obx(() => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.filteredList.length,
                    itemBuilder: (context, index) {
                      final task = controller.filteredList[index];
                      if (task.show == 'yes') {
                        return Column(
                          children: [
                            Container(
                              height: 70,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.pinkAccent,
                                        border: Border.all(
                                            color: Colors.white)),
                                    child: const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    'Create ${task.title} for\n${task.category}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  const CircleAvatar(
                                    radius: 5,
                                    backgroundColor: Colors.purpleAccent,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
