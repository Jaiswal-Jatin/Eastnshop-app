import 'package:eastnshop/Routes/App_Pages.dart';
import 'package:eastnshop/Utils/SharedPrefUtils.dart';
import 'package:eastnshop/Utils/RefreshService.dart';
import 'package:eastnshop/Utils/LogUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await SharedPrefUtils.init();
  
  // Configure console logging to reduce noise
  _configureLogging();
  
  // Initialize global services
  Get.put(RefreshService());
  
  runApp(MyApp());
}

void _configureLogging() {
  // Set system UI overlay style to reduce system logs
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Configure system chrome to reduce verbose logging
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  
  // Disable debug logging in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  
  // Log app initialization
  LogUtils.info('🚀 App initialized with enhanced logging system');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
            theme: ThemeData(
           fontFamily: 'Poppins', ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      //home: Loadingscreen(),
    );
  }
}
