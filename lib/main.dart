import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/controller/theme_controller.dart';
import 'package:to_do_app/data/category_repository.dart';
import 'package:to_do_app/services/notification_service.dart';
import 'package:to_do_app/res/routes/app_routes.dart';
import 'firebase_options.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(CategoryRepository());
  Get.put(ThemeController());


  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app(); // используем уже инициализированное
  }
  await NotificationService().init();
  FirebaseMessaging.instance.getToken().then((token) {
    print('🔥 FCM TOKEN: $token');
  });
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: AppRoutes.routes(),
    );
  }
}

