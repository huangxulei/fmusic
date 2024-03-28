import 'package:floor/floor.dart';
import 'package:fmusic/database/song.dart';

@dao
abstract class SongDao {
  @Query('SELECT * FROM Song')
  Future<List<Song>> findAllSong();

  @Query('SELECT name FROM Song')
  Stream<List<String>> findAllSongName();

  @Query('SELECT * FROM Song WHERE id = :id')
  Stream<Song?> findSongById(int id);

  @insert
  Future<void> insertSong(Song song);
}
