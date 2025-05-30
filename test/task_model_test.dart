
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/model/task_model.dart';

void main() {
  test('TaskModel toJson/fromJson symmetry', () {
    final task = TaskModel(
      key: '1',
      title: 'Test',
      category: 'General',
      description: 'desc',
      image: null,
      periority: 'High',
      time: '10:00',
      date: '2025-05-30',
      show: 'true',
      status: 'open',
    );

    final map = task.toMap();
    final fromMap = TaskModel.fromMap(map);
    expect(fromMap.title, task.title);
    expect(fromMap.key, task.key);
  });
}
