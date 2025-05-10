import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../../Cards/card_contents.dart';
import '../../../common/widgets/video_player_screen.dart';

class MyLearning extends StatefulWidget {
  const MyLearning({super.key});

  @override
  State<MyLearning> createState() => _MyLearningState();
}

class _MyLearningState extends State<MyLearning> {
  String lastWatchedCourse = "No courses watched yet";
  String lastWatchedLecture = "";
  double lastWatchedProgress = 0.0;
  int lastLectureIndex = 0;
  String lastWatchedVideoUrl = "";

  @override
  void initState() {
    super.initState();
    _loadLastWatched();
  }

  Future<void> _loadLastWatched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastWatchedCourse = prefs.getString('lastWatchedCourse') ?? "No courses watched yet";
      lastWatchedLecture = prefs.getString('lastWatchedLecture') ?? "";
      lastWatchedProgress = prefs.getDouble('lastWatchedProgress') ?? 0.0;
      lastLectureIndex = prefs.getInt('lastLectureIndex') ?? 0;
      lastWatchedVideoUrl = prefs.getString('lastWatchedVideoUrl') ?? "";
    });
  }

  void _resumeVideo() {
    if (lastWatchedVideoUrl.isNotEmpty) {
      Get.to(() => CustomVideoPlayerScreen(
        course: CardContents(
          title: lastWatchedCourse,
          videoUrls: [lastWatchedVideoUrl],
          lectures: [
            {"title": lastWatchedLecture, "type": "Video"}
          ], id: '', imageUrl: '', price: 0.0, subTitle: '', content: '', category: '', ratings: 0.0,
        ),
        initialLectureIndex: lastLectureIndex,
          initialPosition: lastWatchedProgress, // Pass last watched position
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My Learning", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Last Watched", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            lastWatchedCourse == "No courses watched yet"
                ? Text(lastWatchedCourse, style: TextStyle(color: Colors.white70))
                : GestureDetector(
              onTap: _resumeVideo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    title: Text(lastWatchedCourse, style: TextStyle(color: Colors.white, fontSize: 16)),
                    subtitle: Text(lastWatchedLecture, style: TextStyle(color: Colors.white70)),
                  ),
                  SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: (lastWatchedProgress / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey,
                    color: Colors.red,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${lastWatchedProgress.toStringAsFixed(0)}% complete",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
        ),
      ),
    );
  }
}
