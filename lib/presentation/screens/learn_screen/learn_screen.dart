import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skillet/core/utils/constants/image_constants.dart';
import 'package:uuid/uuid.dart';
import '../../../meetings/join_meeting_page.dart';
import '../../../meetings/schedule_meeting_page.dart';

class MettingScreen extends StatefulWidget {
  MettingScreen({super.key});

  @override
  State<MettingScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<MettingScreen> {

  final Logger logger = Logger();
  bool isLoading = true;
  String firstName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final args = Get.arguments;

      if (args != null && args is Map<String, dynamic>) {
        logger.d("User Data from arguments: $args");
        setState(() {
          firstName = args['firstName'] ?? 'User';
          isLoading = false;
        });
      } else {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        if (userId.isNotEmpty) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
            logger.d("User Data from Firestore: $userData");
            setState(() {
              firstName = userData['firstName'] ?? 'User';
              isLoading = false;
            });
          } else {
            logger.e('User document does not exist in Firestore.');
            setState(() => isLoading = false);
          }
        } else {
          logger.e('User is not authenticated.');
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {

    void _showJoinMeetingDialog(BuildContext context) {
      final TextEditingController _meetingIdController =
          TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Join Meeting"),
            content: TextField(
              controller: _meetingIdController,
              decoration: const InputDecoration(hintText: "Enter Meeting ID"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final meetingID = _meetingIdController.text.trim();

                  if (meetingID.isEmpty) return;

                  final status = await _requestPermissions();

                  if (!status) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Permissions required to join the meeting."),
                      ),
                    );
                    return;
                  }

                  final docSnapshot = await FirebaseFirestore.instance
                      .collection('meetings')
                      .doc(meetingID)
                      .get();

                  if (docSnapshot.exists) {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JoinMeetingPage(conferenceID: meetingID),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Invalid Room ID"),
                        content:
                        const Text("No meeting found with the provided ID."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Join"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Meetings",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final granted = await _requestPermissions();

                    if (!granted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Camera and microphone permissions are required.")),
                      );
                      return;
                    }

                    final meetingID = const Uuid().v4().substring(0, 6);
                    final user = FirebaseAuth.instance.currentUser!;

                    await _firestore.collection('meetings').doc(meetingID).set({
                      'meetingID': meetingID,
                      'creatorId': user.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                      'creatorName': firstName ?? 'Teacher',
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinMeetingPage(conferenceID: meetingID),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.video_call_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "New meeting",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                )
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showJoinMeetingDialog(context),
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Join",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                )
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const ScheduleMeetingPage(),
                    ));
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Schedule",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                )
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.upload,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ///the  
                Text(
                  "Screen share",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
