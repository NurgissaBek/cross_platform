import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Data/network/firebase/firebase_services.dart';
import '../../Data/shared pref/shared_pref.dart';
import '../../model/task_model.dart';
import '../../utils/utils.dart';
import '../DbHelper/db_helper.dart';

class HomeController extends GetxController {
  // ——— Пользователь ———
  RxMap userData = {}.obs;
  RxString name = ''.obs;

  // ——— Поля UI ———
  RxBool focus = false.obs;
  RxBool hasData = false.obs;
  RxInt taskCount = 0.obs;

  // ——— Фильтры ———
  RxString selectedCategory = 'all'.obs;
  RxString selectedPriority = 'all'.obs;
  RxBool hasText = false.obs;
  RxString selectedSort = 'none'.obs;
  RxString selectedFilter = 'all'.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // ——— Списки ———
  RxList<TaskModel> list = <TaskModel>[].obs;
  RxList<TaskModel> filteredList = <TaskModel>[].obs;

  // ——— Контроллеры ———
  final TextEditingController searchController = TextEditingController();

  // ——— БД и сеть ———
  final DbHelper db = DbHelper();
  Connectivity? connectivity;

  // ——— Конструктор ———
  HomeController() {
    _setupListeners();
    getUserData();
    _setupFirebaseSync();
    getTaskData();
  }

  void _setupListeners() {
    searchController.addListener(() => applyFilters());

    everAll([
      selectedFilter,
      selectedCategory,
      selectedPriority,
      selectedSort,
      selectedDate,
    ], (_) => applyFilters());
  }

  // ——— Основная фильтрация ———
  void applyFilters() {
    List<TaskModel> temp = list.where((t) => t.show == 'yes').toList();

    final q = searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      temp = temp.where((t) => t.title!.toLowerCase().contains(q)).toList();
    }

    if (selectedFilter.value != 'all') {
      temp = temp.where((t) => t.status == selectedFilter.value).toList();
    }

    if (selectedCategory.value != 'all') {
      temp = temp.where((t) => t.category == selectedCategory.value).toList();
    }

    if (selectedPriority.value != 'all') {
      temp = temp.where((t) => t.periority == selectedPriority.value).toList();
    }

    if (selectedDate.value != null) {
      final date = DateFormat('dd/MM/yyyy').format(selectedDate.value!);
      temp = temp.where((t) => t.date == date).toList();
    }

    switch (selectedSort.value) {
      case 'title_asc':
        temp.sort((a, b) => a.title!.compareTo(b.title!));
        break;
      case 'title_desc':
        temp.sort((a, b) => b.title!.compareTo(a.title!));
        break;
      case 'date_asc':
        temp.sort((a, b) => a.date!.compareTo(b.date!));
        break;
      case 'date_desc':
        temp.sort((a, b) => b.date!.compareTo(a.date!));
        break;
      case 'priority_high':
        temp.sort((a, b) => b.periority!.compareTo(a.periority!));
        break;
      case 'priority_low':
        temp.sort((a, b) => a.periority!.compareTo(b.periority!));
        break;
    }

    filteredList.value = temp;
    taskCount.value = temp.length;
    hasData.value = temp.isNotEmpty;
  }

  // ——— Получение задач из SQLite ———
  Future<void> getTaskData() async {
    list.value = await db.getData();
    final temp = await db.getPendingUploads();
    list.addAll(temp);
    applyFilters();
  }

  // ——— Получение данных пользователя ———
  Future<void> getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }

  void getName() {
    name.value = userData['NAME']
        .toString()
        .split(' ')
        .first;
  }

  void checkText() {
    hasText.value = searchController.text.isNotEmpty;
    update();
  }

  void popupMenuSelected(int value, int index, BuildContext context) async {
    if (value == 2) {
      Utils.showWarningDailog(context, () => removeFromList(index));
    }
  }


  // ——— Очистка поиска ———
  void onClear(BuildContext context) {
    searchController.clear();
    FocusScope.of(context).unfocus();
    applyFilters();
  }

  void onTapField() {
    focus.value = true;
  }

  void onTapOutside(BuildContext context) {
    focus.value = false;
    FocusScope.of(context).unfocus();
  }

  // ——— Удаление задачи ———
  void removeFromList(int index) {
    final task = filteredList[index];
    db.removeFromList(task.copyWith(show: 'no')).then((_) => getTaskData());
  }

  // ——— Обновление задачи ———
  Future<void> updateTask(int index, TaskModel updatedTask) async {
    list[index] = updatedTask;
    await db.update(updatedTask);

    final connection = await connectivity?.checkConnectivity();
    if (connection == ConnectivityResult.mobile ||
        connection == ConnectivityResult.wifi) {
      await FirebaseService.update(updatedTask.key!, 'title', updatedTask.title!);
      await FirebaseService.update(updatedTask.key!, 'description', updatedTask.description!);
      await FirebaseService.update(updatedTask.key!, 'category', updatedTask.category!);
    } else {
      await db.insert(updatedTask);
    }

    applyFilters();
  }

  // ——— Синхронизация с Firebase ———
  void _setupFirebaseSync() {
    final email = FirebaseService.auth.currentUser?.email;
    if (email == null) return;

    final node = email.substring(0, email.indexOf('@'));

    FirebaseDatabase.instance.ref('Tasks').child(node).onValue.listen((event) async {
      getTaskData();

      for (var element in event.snapshot.children) {
        if (!await db.isRowExists(element.child('key').value.toString(), 'Tasks')) {
          db.insert(TaskModel(
            key: element.child('key').value.toString(),
            time: element.child('time').value.toString(),
            status: element.child('status').value.toString(),
            date: element.child('date').value.toString(),
            periority: element.child('periority').value.toString(),
            description: element.child('description').value.toString(),
            category: element.child('category').value.toString(),
            title: element.child('title').value.toString(),
            image: element.child('image').value.toString(),
            show: element.child('show').value.toString(),
          )).then((_) => getTaskData());
        }
      }
    });

    FirebaseDatabase.instance.ref('Tasks').child(node).onChildChanged.listen((event) async {
      getTaskData();
      for (var element in event.snapshot.children) {
        db.update(TaskModel(
          key: element.child('key').value.toString(),
          time: element.child('time').value.toString(),
          status: element.child('status').value.toString(),
          date: element.child('date').value.toString(),
          periority: element.child('periority').value.toString(),
          description: element.child('description').value.toString(),
          category: element.child('category').value.toString(),
          title: element.child('title').value.toString(),
          image: element.child('image').value.toString(),
          show: element.child('show').value.toString(),
        )).then((_) => getTaskData());
      }
    });

    connectivity = Connectivity();
    connectivity!.onConnectivityChanged.listen((event) async {
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi) {
        var uploadList = await db.getPendingUploads();
        for (var task in uploadList) {
          db.insert(task);
          db.delete(task.key!, 'PendingUploads');
        }
        uploadList.clear();

        var deleteList = await db.getPendingDeletes();
        for (var task in deleteList) {
          FirebaseService.update(task.key!, 'show', 'no');
          db.delete(task.key!, 'PendingDeletes');
        }

        getTaskData();
      }
    });
  }
}
