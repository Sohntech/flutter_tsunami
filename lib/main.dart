import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes.dart';
import 'controllers/auth_controller.dart';

void main() async {
  try {
    // Assurez-vous que les widgets Flutter sont initialisés
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialisez Firebase
    await Firebase.initializeApp();
    
    // Initialisez le contrôleur d'authentification globalement
    Get.put(AuthController(), permanent: true);
    
    runApp(MyApp());
  } catch (e) {
    print('Erreur lors de l\'initialisation: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisez ScreenUtilInit pour la responsivité
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Taille de design de référence
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Tsunami Money',
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fade,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: Routes.LOGIN,
          getPages: AppPages.pages,
        );
      },
    );
  }
}