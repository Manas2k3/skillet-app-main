import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Cards/card_contents.dart';
import '../../common/widgets/video_player_screen.dart';

class CourseContentPage extends StatelessWidget {
  final CardContents course;

  const CourseContentPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final lectures = course.lectures ?? []; // Ensure it's not null

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back, color: Colors.white,)),
        title: Text(
          course.title,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: lectures.isNotEmpty
          ? ListView.builder(
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];

                return ListTile(
                  title: Text(lecture["title"] ?? "Unknown Lecture", style: GoogleFonts.poppins(color: Colors.white),),
                  subtitle: Text(style: GoogleFonts.poppins(color: Colors.white),
                      "${lecture["type"]} - ${lecture["duration"]}".trim()),
                  leading: Icon(
                    color: Colors.white,
                    lecture["type"] == "Video"
                        ? Icons.video_library
                        : Icons.article,
                  ),
                  onTap: () {
                    if (lecture["type"] == "Video" &&
                        course.videoUrls != null &&
                        course.videoUrls!.length > index) {
                      Get.to(() => CustomVideoPlayerScreen(
                            course: course,
                            initialLectureIndex: index, // 🔥 Pass Lecture Index
                          ));
                    }
                  },
                );
              },
            )
          : const Center(
              child: Text(
                "No lectures available",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
    );
  }
}
