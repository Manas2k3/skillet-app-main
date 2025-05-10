import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/repositories/authentication_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Logger logger = Logger();
  String fullName = "User";
  String profileImageBase64 = "";
  String email = "";
  String phone = "";
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final args = Get.arguments;
      if (args is Map<String, dynamic>) {
        logger.d("Received arguments: $args");
        _setUserData(args);
      } else {
        await _fetchFromFirestore();
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _pickAndUploadImage() async {
    try {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        logger.e("Permission Denied");
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        "profileImage": base64Image,
      });

      setState(() => profileImageBase64 = base64Image);
    } catch (e) {
      logger.e("Error uploading image: $e");
    }
  }


  void _setUserData(Map<String, dynamic> data) {
    setState(() {
      String firstName = data['firstName']?.toString() ?? 'John';
      String lastName = data['lastname']?.toString() ?? 'Doe';
      fullName = "$firstName $lastName".trim();
      profileImageBase64 = data['profileImage'] ?? '';
      email = data['email'] ?? '';
      phone = data['phone'] ?? '';
    });
  }

  Future<void> _fetchFromFirestore() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      logger.e('User is not authenticated.');
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _setUserData(userData);
    } else {
      logger.e('User document does not exist in Firestore.');
    }
  }


  Future<void> _editDetails() async {
    TextEditingController firstNameController = TextEditingController(text: fullName.split(" ")[0]);
    TextEditingController lastNameController = TextEditingController(text: fullName.split(" ").length > 1 ? fullName.split(" ")[1] : "");
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneController = TextEditingController(text: phone);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: "First Name")),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: "Last Name")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              String userId = FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance.collection('Users').doc(userId).update({
                "firstName": firstNameController.text.trim(),
                "lastname": lastNameController.text.trim(),
                "email": emailController.text.trim(),
                "phone": phoneController.text.trim(),
              });

              setState(() {
                fullName = "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
                email = emailController.text.trim();
                phone = phoneController.text.trim();
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    List<Map<String, dynamic>> settings = [
      {"icon": Icons.person, "title": "Account Settings"},
      {"icon": Icons.notifications, "title": "Notifications"},
      {"icon": Icons.download_sharp, "title": "Downloads", "route": "/downloads"},
      {"icon": Icons.help_outline, "title": "Help & Support"},
      {"icon": Icons.language, "title": "Language"},
      {"icon": Icons.dark_mode, "title": "Dark Mode"},
      {"icon": Icons.info, "title": "About"},
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: settings.length + 1,
        itemBuilder: (_, index) {
          if (index == settings.length) {
            return ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Sign Out",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: AuthenticationRepository.instance.logOut,
            );
          }
          return ListTile(
            leading: Icon(settings[index]['icon'], color: Colors.white),
            title: Text(settings[index]['title'], style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (settings[index]["route"] != null) {
                Get.toNamed(settings[index]["route"]); // Navigate to downloads screen
              }
            },
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 75.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildSettingsList(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeProfileImage() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        "profileImage": "",
      });

      setState(() => profileImageBase64 = ""); // Reset to default
    } catch (e) {
      logger.e("Error removing image: $e");
    }
  }


  void _showImageOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileImageBase64.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("View Image"),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(automaticallyImplyLeading: false,leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back, color: Colors.white,)),backgroundColor: Colors.black),
                    body: Center(child: Image.memory(base64Decode(profileImageBase64))),
                  ));
                },
              ),
            if (profileImageBase64.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Image", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: _showImageOptions, // Show options instead of direct view
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(profileImageBase64))
                    : const NetworkImage(
                    'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg') as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
            TextButton(onPressed: _editDetails, child: const Text("Edit Profile", style: TextStyle(color: Colors.blue))),
          ],
        ),
      ],
    );
  }

}
