import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/default_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:restaurant_management_fierbase/push_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restaurant_management_fierbase/screens/splash_screen/splash_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:restaurant_management_fierbase/utils/const_local_string.dart';
import 'apptheme/app_colors.dart';
import 'firebase/firebase_options.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await GetStorage.init();
    HttpOverrides.global = MyHttpOverrides();
    await notificationSetup();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      splitScreenMode: true,
      builder: (context, child) {
        String savedLanguage = getStorage.read('selected_language') ?? 'en';
        Locale initialLocale;
        if (savedLanguage == 'gu') {
          initialLocale = const Locale('gu', 'IN');
        } else if (savedLanguage == 'hi') {
          initialLocale = const Locale('hi', 'IN');
        } else {
          initialLocale = const Locale('en', 'US');
        }
        return GetMaterialApp(
          title: 'Roadyz',
          translations: LocaleString(),
          locale: initialLocale,
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('gu', 'IN'), // Gujarati
            Locale('hi', 'IN'), // Hindi (optional)
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.black),
          ),
          onGenerateRoute: (RouteSettings settings) {
            return GetPageRoute(page: () => const SplashScreen());
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}