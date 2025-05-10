import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DownloadsScreen extends StatefulWidget {
  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  Box downloadsBox = Hive.box('downloads');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloads")),
      body: downloadsBox.isEmpty
          ? Center(child: Text("No downloads yet."))
          : ListView.builder(
        itemCount: downloadsBox.length,
        itemBuilder: (context, index) {
          String title = downloadsBox.keys.toList()[index];
          String path = downloadsBox.get(title);

          return ListTile(
            title: Text(title),
            leading: Icon(Icons.play_circle_filled, color: Colors.green),
            onTap: () {
              Get.to(() => OfflineVideoPlayer(videoPath: path));
            },
          );
        },
      ),
    );
  }
}

class OfflineVideoPlayer extends StatefulWidget {
  final String videoPath;
  const OfflineVideoPlayer({super.key, required this.videoPath});

  @override
  _OfflineVideoPlayerState createState() => _OfflineVideoPlayerState();
}

class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
