import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:roydad/First.dart';
import 'package:roydad/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool theme_dark = true; // وضعیت تم
  bool lang = false; // وضعیت زبان

  // بررسی وضعیت تم از SharedPreferences
  Future<void> checkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('darkmod');
    setState(() {
      theme_dark = isDarkMode ?? false; // اگر موجود نباشد، مقدار پیش‌فرض false
    });
  }

  // بررسی وضعیت زبان از SharedPreferences
  Future<void> checkLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? langSetting = prefs.getBool('lang');
    setState(() {
      lang = langSetting ?? false; // اگر موجود نباشد، مقدار پیش‌فرض false
    });

    // تغییر زبان
    if (lang) {
      Get.updateLocale(const Locale('en')); // زبان انگلیسی
    } else {
      Get.updateLocale(const Locale('fa')); // زبان فارسی
    }
  }

  @override
  void initState() {
    super.initState();
    checkTheme(); // بررسی وضعیت تم
    checkLang(); // بررسی وضعیت زبان
  }

  // تغییر تم
  void toggleTheme() async {
    // استفاده از addPostFrameCallback برای اجرای setState بعد از اتمام build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        theme_dark = !theme_dark; // تغییر وضعیت تم
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkmod', theme_dark); // ذخیره وضعیت تم
    });
  }

  // تغییر زبان
  void toggleLanguage() async {
    setState(() {
      lang = !lang; // تغییر وضعیت زبان
    });

    // تغییر زبان
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lang', lang); // ذخیره وضعیت زبان
    if (lang) {
      Get.updateLocale(const Locale('en')); // زبان انگلیسی
    } else {
      Get.updateLocale(const Locale('fa')); // زبان فارسی
    }
  }

  final ThemeData _dark = ThemeData(
    scaffoldBackgroundColor: const Color(0xffFBF8EF),
    hintColor: const Color(0xffC9E6F0),
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 195, 190, 190),
      secondary: Color.fromARGB(255, 235, 232, 222),
    ),
  );

  final ThemeData _light = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 237, 233, 222),
    hintColor: const Color(0xffC9E6F0),
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 195, 190, 190),
      secondary: Color.fromARGB(255, 235, 232, 222),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: lang ? const Locale('en') : const Locale('fa'),
      debugShowCheckedModeBanner: false,
      theme: theme_dark ? _dark : _light, // انتخاب تم
      textDirection: TextDirection.rtl, // تنظیم جهت ثابت متن به راست به چپ
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fa'), // Persian
      ],
      home: SplScreen(
        theme_dark: theme_dark,
        lang: toggleLanguage, // تغییر زبان
        toggle: toggleTheme, // تغییر تم
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
