import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
// basic version
class ScheduleMeetingPage extends StatefulWidget {
  const ScheduleMeetingPage({super.key});

  @override
  State<ScheduleMeetingPage> createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {

  final _titleController = TextEditingController();
  DateTime? selectedDateTime;
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Meeting")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                selectedDateTime = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 30)),
                  initialDate: now,
                );
              },
              child: const Text("Pick Date"),
            ),
            const SizedBox(height: 24),


            ElevatedButton(
              onPressed: () async {
                final meetingID = const Uuid().v4().substring(0, 6);
                final user = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance.collection("scheduled_meetings").doc(meetingID).set({
                  "meetingID": meetingID,
                  "title": _titleController.text.trim(),
                  "scheduledFor": selectedDateTime,
                  "creatorID": user.uid,
                  "creatorName": firstName,
                });
                Navigator.pop(context);
              },
              child: const Text("Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}
