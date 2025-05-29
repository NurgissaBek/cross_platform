import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../res/app_color.dart';
import '../../../utils/utils.dart';
import '../../../view model/controller/home_controller.dart';
import '../../common widgets/back_button.dart';
import '../../edit task/edit_task.dart';

DateTime safeParseDate(String? rawDate) {
  try {
    return DateFormat('dd/MM/yyyy').parse(rawDate ?? '');
  } catch (_) {
    return DateTime.now();
  }
}

class ProgressContainer extends StatelessWidget {
  final int index;
  const ProgressContainer({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final tasks = controller.filteredTasks;

    // Безопасность от range error
    if (tasks.isEmpty || index >= tasks.length) return const SizedBox();
    final task = tasks[index];

    return Container(
      height: 200,
      width: 160,
      margin: const EdgeInsets.only(left: 20),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(task.image ?? 'assets/images/default.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            height: 150,
            width: 150,
            top: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 1, sigmaX: 1),
                child: const SizedBox(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.date ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                      width: 20,
                      child: PopupMenuButton(
                        padding: EdgeInsets.zero,
                        color: primaryColor,
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (value == 1) {
                            Get.to(() => EditTaskPage(task: task, index: index));
                          } else if (value == 2) {
                            controller.popupMenuSelected(value, index, context);
                          }
                        },
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.pinkAccent),
                                  Text(" Edit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.pinkAccent),
                                  Text(" Delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  task.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  task.category ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomBackButton(
                      height: 30,
                      width: 30,
                      radius: 30,
                      widget: Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlutterLogo(),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${Utils.getDaysDiffirece(safeParseDate(task.date))} Days Left',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
