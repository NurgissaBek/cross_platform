import 'package:flutter/material.dart';
import 'package:to_do_app/res/app_color.dart';
import 'package:to_do_app/view/new task/components/addtask_body.dart';

void showNewTaskModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Создать задачу'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        body: TaskBody(),
      );
    },
  );
}
