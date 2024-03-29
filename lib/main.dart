import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fmusic/global.dart';
import 'package:fmusic/main_provider.dart';
import 'package:fmusic/screens/home.dart';
import 'package:fmusic/screens/settings.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Global.init();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(700, 800),
      center: true,
      title: '老黄播放器',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => MainProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Player',
      theme: ThemeData(
        colorSchemeSeed: Provider.of<MainProvider>(context).seedColor,
        brightness: Provider.of<MainProvider>(context).isDarkMode
            ? Brightness.dark
            : Brightness.light,
        useMaterial3: true,
      ),
      routes: {
        '/settings': (context) => const Settings(),
        '/home': (context) => const Home(),
      },
      home: const Home(),
    );
  }
}
