import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../global.dart';

/// 缓存
class CacheUtil {
  static const String _basePath = 'cache';
  static const String _backupPath = 'backup';
  static String? _cacheBasePath, _cacheStoragePath;

  /// 缓存名称
  final String? cacheName;

  /// 基路径
  final String basePath;

  /// 是否是备份
  final bool backup;

  CacheUtil({this.cacheName, required this.basePath, this.backup = false});

  String? _cacheDir;

  /// 请求权限
  static Future<bool> requestPermission() async {
    // 检查并请求权限
    if (Global.isDesktop) return true;
    if (await Permission.storage.status != PermissionStatus.granted) {
      var _status = await Permission.storage.request();
      if (_status != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<String?> cacheDir([bool? allCache]) async {
    try {
      await requestPermission();
    } catch (e) {}
    if (_cacheDir != null && allCache != true) return _cacheDir;
    var dir = await getCacheBasePath(backup);
    if (dir == null || dir.isEmpty) return null;
    dir = dir + _separator + 'fmusic';
    if (this.basePath == null || this.basePath.isEmpty)
      dir = dir + _separator + (backup ? _backupPath : _basePath);
    else
      dir = dir + _separator + this.basePath;
    if (allCache == true) {
      return dir + _separator;
    }
    if (cacheName != null && cacheName!.isNotEmpty)
      dir = dir + _separator + cacheName.hashCode.toString();
    _cacheDir = dir + _separator;
    print('cache dir: $_cacheDir');
    return _cacheDir;
  }

  Future<String?> getFileName(String key, bool hashCodeKey) async {
    var dir = _cacheDir ?? await cacheDir();
    if (dir == null || dir.isEmpty) return null;
    return dir + (hashCodeKey ? key.hashCode.toString() + '.data' : key);
  }

  /// 路径分隔符
  static String get _separator => Platform.pathSeparator;

  /// 获取缓存放置目录 (写了一堆，提升兼容性）
  static Future<String?> getCacheBasePath([bool? storage]) async {
    if (_cacheStoragePath == null) {
      try {
        if (Global.isDesktop) {
          _cacheStoragePath =
              (await path.getApplicationDocumentsDirectory()).path;
        } else if (Platform.isAndroid) {
          _cacheStoragePath = (await path.getExternalStorageDirectory())?.path;
          if (_cacheStoragePath != null && _cacheStoragePath!.isNotEmpty) {
            final _subStr = 'storage/emulated/0/';
            var index = _cacheStoragePath!.indexOf(_subStr);
            if (index >= 0) {
              _cacheStoragePath =
                  _cacheStoragePath!.substring(0, index + _subStr.length - 1);
            }
          }
        } else
          _cacheStoragePath =
              (await path.getApplicationDocumentsDirectory()).path;
      } catch (e) {}
    }
    if (_cacheBasePath == null) {
      _cacheBasePath = (await path.getApplicationDocumentsDirectory()).path;
      if (_cacheBasePath == null || _cacheBasePath!.isEmpty) {
        _cacheBasePath = (await path.getApplicationSupportDirectory()).path;
        if (_cacheBasePath == null || _cacheBasePath!.isEmpty) {
          _cacheBasePath = (await path.getTemporaryDirectory()).path;
        }
      }
      if (_cacheStoragePath == null || _cacheStoragePath!.isEmpty)
        _cacheStoragePath = _cacheBasePath;
    }
    return storage == true ? _cacheStoragePath : _cacheBasePath;
  }
}
