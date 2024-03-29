import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fmusic/database/database.dart';
import 'package:fmusic/database/song_dao.dart';
import 'package:fmusic/utils/cache_util.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/src/factory_mixin.dart' as impl;

class Global with ChangeNotifier {
  static late bool _isDesktop;
  static bool get isDesktop => _isDesktop;

  /// 默认分隔线高度
  static double lineSize = 0.35;

  static SongDao? _songDao;
  static SongDao? get songDao => _songDao;

  static Future<bool> init() async {
    _isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    if (isDesktop) {
      sqflite.databaseFactory = databaseFactoryFfi;
      final factory =
          sqflite.databaseFactory as impl.SqfliteDatabaseFactoryMixin;
      factory.setDatabasesPathOrNull(
          await CacheUtil(backup: true, basePath: "database").cacheDir());
    }
    final database =
        await $FloorAppDatabase.databaseBuilder('audio.db').build();
    _songDao = database.songDao;
    print("delay global init");
    return true;
  }
}
