import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skillet/presentation/screens/cart/cart_view.dart';

import '../../Cards/CardCustomRoundedWidget.dart';
import '../../Cards/card_contents.dart';
import '../../Cards/card_expanded_view.dart';
import '../../features/authentication/google_auth/google_auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final Logger logger = Logger();
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String firstName = 'User'; // Default value
  String lastName = ''; // Default value for last name

  Future<void> _fetchUserData() async {
    try {
      final args = Get.arguments;

      if (args != null && args is Map<String, dynamic>) {
        logger.d("User Data from arguments: $args");
        setState(() {
          firstName = args['firstName'] ?? 'User';
          lastName = args['lastName'] ?? '';
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
              lastName = userData['lastName'] ?? '';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            Get.to(CartView());
          }, icon: Icon(Icons.shopping_cart_outlined, color: Colors.white,))
        ],
        title: Text(
          "Hello, $firstName",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Recommended for you",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 250,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                enableInfiniteScroll: true,
                viewportFraction: 0.8,
              ),
              items: cardContentList.map((course) {
                return Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      onTap: () {
                        // Navigate to Expanded View with Selected Course Data
                        Get.to(() => CardExpandedView(cardContents: course));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                                child: CachedNetworkImage(
                                  imageUrl: course.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover, // Better UI
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          height: 200, // Set an appropriate height
                                          color: Colors.white,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, size: 50),
                                ),
                              ),
                            ),
                            CardCustomRoundedWidget(course: course),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
