import 'package:floor/floor.dart';

@entity
class Song {
  // 基本信息
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String path;
  final String? artist;
  final String? album;

  Song(this.id, this.name, this.path, this.artist, this.album);

  factory Song.optional({
    int? id,
    String? name,
    String? path,
    String? artist,
    String? album,
  }) =>
      Song(id, name ?? "无题", path ?? "无地址", artist ?? "无名氏", album);
}
