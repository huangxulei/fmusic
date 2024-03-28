import 'dart:async';
import 'package:floor/floor.dart';
import 'package:fmusic/database/song.dart';
import 'package:fmusic/database/song_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Song])
abstract class AppDatabase extends FloorDatabase {
  SongDao get songDao;
}
