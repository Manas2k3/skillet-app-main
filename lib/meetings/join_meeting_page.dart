import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class JoinMeetingPage extends StatefulWidget {
  final String conferenceID;

  const JoinMeetingPage({super.key, required this.conferenceID});

  @override
  State<JoinMeetingPage> createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final Logger logger = Logger();
  bool isLoading = true;
  String firstName = 'User';
  String userRole = 'student'; // Default role

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
          userRole = args['role'] ?? 'student';
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
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            logger.d("User Data from Firestore: $userData");
            setState(() {
              firstName = userData['firstName'] ?? 'User';
              userRole = userData['role'] ?? 'student';
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: 1215921346,
        appSign:
        '580760c1d289faa84a93b1c428b14c2038a1260d51eae490eaadcdd6b092e91f',
        userID: user.uid,
        userName: firstName,
        conferenceID: widget.conferenceID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig()
          ..foreground = Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Meeting ID: ${widget.conferenceID}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          )
          ..onLeave = () async {
            final docRef = FirebaseFirestore.instance
                .collection('meetings')
                .doc(widget.conferenceID);
            final snapshot = await docRef.get();

            logger.i("Checking deletion eligibility...");
            logger.i("Meeting Data: ${snapshot.data()}");
            logger.i("User UID: ${user.uid}");
            logger.i("User Role: $userRole");

            if (snapshot.exists &&
                snapshot.data()?['createdBy'] == user.uid &&
                userRole.toLowerCase() == 'teacher') {
              try {
                await docRef.delete();
                logger.i("✅ Meeting ${widget.conferenceID} deleted by teacher.");
              } catch (e) {
                logger.e("❌ Error deleting meeting: $e");
              }
            } else {
              logger.w("❌ User not authorized to delete meeting.");
            }

            Navigator.of(context).pop();
          }

      ),
    );
  }
}
