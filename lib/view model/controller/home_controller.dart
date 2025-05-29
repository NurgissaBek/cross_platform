import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:to_do_app/Data/network/firebase/firebase_services.dart';
import 'package:to_do_app/Data/shared%20pref/shared_pref.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';
import '../../model/task_model.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  RxMap userData = {}.obs;
  RxString name = ''.obs;
  RxBool focus = false.obs;
  RxBool hasText = false.obs;
  RxInt taskCount = 0.obs;
  RxBool hasData = false.obs;

  RxString selectedCategory = 'all'.obs;
  RxString selectedPriority = 'all'.obs;
  RxString selectedSort = 'none'.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  RxString selectedFilter = 'all'.obs;

  final DbHelper db = DbHelper();
  RxList<TaskModel> list = <TaskModel>[].obs;
  Connectivity? connectivity;
  final TextEditingController searchController = TextEditingController(); // ✅


  List<TaskModel> get filteredTasks {
    List<TaskModel> filtered = list.where((t) => t.show == 'yes').toList();

    final q = searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        filtered = filtered.where((t) =>
          (t.title?.toLowerCase() ?? '').contains(q)
        ).toList();
      }


    if (selectedFilter.value != 'all') {
      filtered = filtered.where((t) => t.status == selectedFilter.value).toList();
    }

    if (selectedCategory.value != 'all') {
      filtered = filtered.where((t) => t.category == selectedCategory.value).toList();
    }

    if (selectedPriority.value != 'all') {
      filtered = filtered.where((t) => t.periority == selectedPriority.value).toList();
    }

    if (selectedDate.value != null) {
      final date = DateFormat('dd/MM/yyyy').format(selectedDate.value!);
      filtered = filtered.where((t) => t.date == date).toList();
    }

    switch (selectedSort.value) {
      case 'title_asc':
        filtered.sort((a, b) => a.title!.compareTo(b.title!));
        break;
      case 'title_desc':
        filtered.sort((a, b) => b.title!.compareTo(a.title!));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date!.compareTo(b.date!));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.date!.compareTo(a.date!));
        break;
      case 'priority_high':
        filtered.sort((a, b) => b.periority!.compareTo(a.periority!));
        break;
      case 'priority_low':
        filtered.sort((a, b) => a.periority!.compareTo(b.periority!));
        break;
    }

    return filtered;
  }

  HomeController() {
    _setupSearchListener();
    _setupRecalculationOnFilterChange();

    if (userData['NAME'] == null) {
      getUserData();
    }

    _setupFirebaseSync();
    getTaskData();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      checkData();
    });
  }

  void _setupRecalculationOnFilterChange() {
    everAll([
      selectedFilter,
      selectedCategory,
      selectedPriority,
      selectedSort,
      selectedDate,
    ], (_) {
      checkData();
    });
  }

  void _setupFirebaseSync() {
    String? email = FirebaseService.auth.currentUser?.email;
    if (email == null) return;
    String node = email.substring(0, email.indexOf('@'));

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
        var list = await db.getPendingUploads();
        for (var task in list) {
          db.insert(task);
          db.delete(task.key!, 'PendingUploads');
        }
        list.clear();
        list = await db.getPendingDeletes();
        for (var task in list) {
          FirebaseService.update(task.key!, 'show', 'no');
          db.delete(task.key!, 'PendingDeletes');
        }
        getTaskData();
      }
    });
  }

  void checkData() {
    final count = filteredTasks.length;
    taskCount.value = count;
    hasData.value = count > 0;
  }

  void popupMenuSelected(int value, int index, BuildContext context) async {
    if (value == 2) {
      Utils.showWarningDailog(context, () => removeFromList(index));
    }
  }

  Future<void> getTaskData() async {
    list.value = await db.getData();
    final temp = await db.getPendingUploads();
    list.addAll(temp);
    checkData();
  }

  Future<List<TaskModel>> getFututeData() => db.getData();

  void onClear(BuildContext context) {
    searchController.text = '';
    hasText.value = false;
    onTapOutside(context);
    checkData();
  }

  void onTapOutside(BuildContext context) {
    focus.value = false;
    FocusScope.of(context).unfocus();
  }

  void checkText() {
    hasText.value = searchController.text.isNotEmpty;
    update();
  }

  void onTapField() {
    focus.value = true;
  }

  Future<void> getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }

  void getName() {
    name.value = userData['NAME']
        .toString()
        .substring(0, userData['NAME'].toString().indexOf(' '));
  }

  void removeFromList(int index) {
    db.removeFromList(TaskModel(
      key: list[index].key,
      status: list[index].status,
      time: list[index].time,
      date: list[index].date,
      periority: list[index].periority,
      description: list[index].description,
      category: list[index].category,
      title: list[index].title,
      image: list[index].image,
      show: 'no',
    )).then((_) => getTaskData());
  }

  Future<void> updateTask(int index, TaskModel updatedTask) async {
    list[index] = updatedTask;
    update();

    await db.update(updatedTask);

    final connection = await connectivity?.checkConnectivity();
    if (connection == ConnectivityResult.mobile || connection == ConnectivityResult.wifi) {
      await FirebaseService.update(updatedTask.key!, 'title', updatedTask.title!);
      await FirebaseService.update(updatedTask.key!, 'description', updatedTask.description!);
      await FirebaseService.update(updatedTask.key!, 'category', updatedTask.category!);
    } else {
      await db.insert(updatedTask);
    }
  }
}
