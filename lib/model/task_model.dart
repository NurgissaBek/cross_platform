import 'dart:core';

class TaskModel {
  String? key;
  String? title;
  String? category;
  String? description;
  String? image;
  String? periority;
  String? time;
  String? date;
  String? show;
  String? status;

  TaskModel(
      {required this.key,
      required this.time,
      required this.date,
      required this.periority,
      required this.description,
      required this.category,
      required this.title,
      required this.image,
      required this.show,
      required this.status});

  TaskModel copyWith({
    String? key,
    String? title,
    String? category,
    String? description,
    String? image,
    String? periority,
    String? time,
    String? date,
    String? show,
    String? status,
  }) {
    return TaskModel(
      key: key ?? this.key,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
      periority: periority ?? this.periority,
      time: time ?? this.time,
      date: date ?? this.date,
      show: show ?? this.show,
      status: status ?? this.status,
    );
  }

  TaskModel.fromMap(Map<String, dynamic> res) {
    key = res['key'];
    title = res['title'];
    category = res['category'];
    description = res['description'];
    image = res['image'];
    periority = res['periority'];
    show = res['show'];
    time = res['time'];
    date = res['date'];
    status=res['status'];
  }

  Map<String, Object?> toMap() {
    return {
      'key': key,
      'title': title,
      'category': category,
      'description': description,
      'image': image,
      'periority': periority,
      'time': time,
      'date': date,
      'show': show,
      'status' : status,
    };
  }
}
