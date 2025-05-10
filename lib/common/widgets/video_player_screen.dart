import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:screenshot_guard/screenshot_guard.dart';
import '../../Cards/card_contents.dart';

class CustomVideoPlayerScreen extends StatefulWidget {
  final CardContents course;
  final int initialLectureIndex;
  final double? initialPosition;  // Nullable initialPosition

  const CustomVideoPlayerScreen({
    Key? key,
    required this.course,
    required this.initialLectureIndex,
    this.initialPosition,  // Nullable parameter
  }) : super(key: key);

  @override
  _CustomVideoPlayerScreenState createState() => _CustomVideoPlayerScreenState();
}


class _CustomVideoPlayerScreenState extends State<CustomVideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int currentLectureIndex = 0;
  final ScreenshotGuard _screenshotGuardPlugin = ScreenshotGuard();
  double _currentPosition = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    currentLectureIndex = widget.initialLectureIndex;
    _initializeVideo(widget.course.videoUrls![currentLectureIndex]);
    _screenshotGuardPlugin.enableSecureFlag(enable: true);
  }


  void _initializeVideo(String videoUrl) {
    _disposeCurrentVideo();

    _videoController = videoUrl.startsWith('assets/')
        ? VideoPlayerController.asset(videoUrl)
        : VideoPlayerController.network(videoUrl);

    _videoController!.initialize().then((_) {
      setState(() {
        _videoController!.seekTo(Duration(seconds: widget.initialPosition?.toInt() ?? 0)); // Seek to last position
      });
    }).catchError((error) {
      debugPrint("Video initialization error: $error");
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.white,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white54,
      ),
    );

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_videoController!.value.isInitialized && _videoController!.value.isPlaying) {
        setState(() {
          _currentPosition = _videoController!.value.position.inSeconds.toDouble();
        });
        _saveLastWatched();
      }
    });
  }

  Future<void> _saveLastWatched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastWatchedCourse', widget.course.title);
    await prefs.setString('lastWatchedLecture', _getCurrentLectureTitle());
    await prefs.setDouble('lastWatchedProgress', _currentPosition);  // Save position every second
  }


  void _disposeCurrentVideo() {
    _timer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
  }

  @override
  void dispose() {
    _disposeCurrentVideo();
    _screenshotGuardPlugin.enableSecureFlag(enable: false);
    super.dispose();
  }

  String _getCurrentLectureTitle() {
    return (widget.course.lectures != null &&
        currentLectureIndex < widget.course.lectures!.length)
        ? widget.course.lectures![currentLectureIndex]["title"] ?? "Untitled Lecture"
        : "Untitled Lecture";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _getCurrentLectureTitle(),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _videoPlayerWidget(),
          _buildVideoDetails(),
          _buildLectureList(),
        ],
      ),
    );
  }

  Widget _videoPlayerWidget() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildVideoDetails() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getCurrentLectureTitle(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _buildTag("CC"),
              _buildTag("1.0X"),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLectureList() {
    final lectures = widget.course.lectures ?? [];

    return Expanded(
      child: ListView.builder(
        itemCount: lectures.length,
        itemBuilder: (context, index) {
          final lecture = lectures[index];

          return ListTile(
            leading: Icon(
              lecture["type"] == "Video" ? Icons.play_circle_fill : Icons.article,
              color: Colors.white,
            ),
            title: Text(
              lecture["title"]!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              "${lecture["type"]} - ${lecture["duration"]}".trim(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              if (lecture["type"] == "Video" && widget.course.videoUrls!.isNotEmpty) {
                setState(() {
                  currentLectureIndex = index;
                });
                _initializeVideo(widget.course.videoUrls![index]);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
