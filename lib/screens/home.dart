import 'dart:convert';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fmusic/database/song.dart';
import 'package:fmusic/global.dart';
import 'package:fmusic/main_provider.dart';
import 'package:fmusic/screens/image_place_holder.dart';
import 'package:fmusic/widget/player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> allSongs = []; //歌曲列表
  Song? nowPlaying;
  bool batchEdit = false;
  Map<String, bool> selectedFiles = {}; //选择文件
  bool currentlyDownloading = false;

  @override
  void initState() {
    super.initState();
    updatePlaylist();
  }

  Future<void> loadProviders() async {
    print(await getDatabasesPath());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? directory = prefs.getString('directory');
    final int? seedColor = prefs.getInt('seedColor');
    print("directory ${directory} ${seedColor}");
    if (directory != null && seedColor != null && context.mounted) {
      Provider.of<MainProvider>(context, listen: false).dlMusicDir = directory;
      Provider.of<MainProvider>(context, listen: false).seedColor =
          Color(seedColor);
      Provider.of<MainProvider>(context, listen: false).isDarkMode =
          prefs.getBool('isDarkMode') ?? false;
    }
  }

  Future<void> updatePlaylist() async {
    final List<Song> songs = await Global.songDao!.findAllSong();

    setState(() {
      allSongs = songs;
    });
  }

  Future<void> addToDB(Song song) async {
    await Global.songDao!.insertSong(song);
  }

  Future<void> addFile() async {
    FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'flac'],
      allowMultiple: true,
    )
        .then((value) async {
      if (value == null) return;
      final files = value.files;
      for (final file in files) {
        // final path = file.path!;
        // Metadata metadata = await MetadataGod.readMetadata(file: path);
        final track = File(file.path!);
        final metadata = await readMetadata(track, getImage: true);
        String? coverStr;
        if (metadata.pictures.isNotEmpty) {
          coverStr = base64Encode(metadata.pictures[0].bytes);
        }
        final s = Song.optional(
            name: metadata.title ?? p.basename(file.path!),
            path: file.path,
            artist: metadata.artist ?? "Unkonwn",
            album: metadata.album ?? "Unkonwn",
            cover: coverStr ?? "Unkonwn");
        await addToDB(s);
        updatePlaylist();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: addFile, //添加歌曲
                tooltip: '添加歌曲',
              ),
            ],
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Audio Player',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(
                  width: 10,
                ),
                if (currentlyDownloading)
                  const SizedBox(
                      width: 15, height: 15, child: CircularProgressIndicator())
                else
                  Text(
                    Provider.of<MainProvider>(context).dlMusicDir,
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            )),
        body: Column(children: [
          const SizedBox.shrink(),
          Expanded(
              child: FutureBuilder<List<Song>>(
                  future: Global.songDao!.findAllSong(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final songs = snapshot.data!;
                      if (songs.isEmpty) {
                        return const Center(child: Text('No songs found'));
                      } else {
                        return ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              Song song = songs[index];
                              return ListTile(
                                  leading: song.cover != "Unkonwn"
                                      ? Image.memory(base64Decode(song.cover!))
                                      : const ImagePlaceHolder(
                                          height: 50,
                                          width: 50,
                                          error: true,
                                        ),
                                  title: Text(song.name),
                                  subtitle:
                                      Text("${song.artist} - ${song.album}"),
                                  trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final nameTextController =
                                            TextEditingController(
                                                text: song.name);
                                        final artistTextController =
                                            TextEditingController(
                                                text: song.artist);
                                        final albumTextController =
                                            TextEditingController(
                                                text: song.album);
                                        if (context.mounted) {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                    title: Text(
                                                        "Edit ${song.name}"),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'Name',
                                                          ),
                                                          controller:
                                                              nameTextController,
                                                        ),
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'Artist',
                                                          ),
                                                          controller:
                                                              artistTextController,
                                                        ),
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: 'Album',
                                                          ),
                                                          controller:
                                                              albumTextController,
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            albumTextController
                                                                .dispose();
                                                            artistTextController
                                                                .dispose();
                                                            nameTextController
                                                                .dispose();
                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child:
                                                              const Text("取消")),
                                                      TextButton(
                                                          onPressed: () async {
                                                            await Global
                                                                .songDao!
                                                                .removeSong(
                                                                    song);
                                                            setState(() {});
                                                            albumTextController
                                                                .dispose();
                                                            artistTextController
                                                                .dispose();
                                                            nameTextController
                                                                .dispose();
                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child:
                                                              const Text("删除")),
                                                      TextButton(
                                                          onPressed: () async {
                                                            Song _song = Song(
                                                                song.id,
                                                                nameTextController
                                                                    .text,
                                                                song.path,
                                                                artistTextController
                                                                    .text,
                                                                albumTextController
                                                                    .text,
                                                                song.cover);

                                                            await Global
                                                                .songDao!
                                                                .updateSong(
                                                                    _song);
                                                            updatePlaylist();
                                                            setState(() {});
                                                            albumTextController
                                                                .dispose();
                                                            artistTextController
                                                                .dispose();
                                                            nameTextController
                                                                .dispose();
                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child:
                                                              const Text("修改")),
                                                    ]);
                                              });
                                        }
                                      }),
                                  onTap: () {
                                    setState(() {
                                      nowPlaying = song;
                                    });
                                  });
                            });
                      }
                    }
                  })),
          PlayerWidget(allSongs: allSongs, nowPlaying: nowPlaying)
        ]));
  }
}
