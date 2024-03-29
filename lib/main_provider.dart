import 'package:flutter/material.dart';

Color sC = Colors.blue;

class MainProvider extends ChangeNotifier {
  bool _isDarkMode = false; //主题模式
  Color _seedColor = sC; //颜色
  String _dlMusicDir = ""; //默认文件夹
  Duration _sleepTimerDuration = const Duration(hours: 1); //休眠时间

  bool get isDarkMode => _isDarkMode;

  Color get seedColor => _seedColor;

  String get dlMusicDir => _dlMusicDir;

  Duration get sleepTimer => _sleepTimerDuration;

  set dlMusicDir(String dir) {
    _dlMusicDir = dir;
    notifyListeners();
  }

  set sleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    notifyListeners();
  }

  set seedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
