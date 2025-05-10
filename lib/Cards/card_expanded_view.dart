import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';
import '../core/utils/constants/loaders.dart';
import '../presentation/course_content/course_content_page.dart';
import '../presentation/screens/cart/cart_view.dart';
import '../state_management/controllers/cart_controller.dart';
import 'card_contents.dart'; // Import your CardContents model

class CardExpandedView extends StatefulWidget {
  final CardContents cardContents;

  const CardExpandedView({super.key, required this.cardContents});

  @override
  State<CardExpandedView> createState() => _CardExpandedViewState();
}

class _CardExpandedViewState extends State<CardExpandedView> {
  bool isLoading = false;
  bool _isExpanded = true;
  bool _isPurchased = false; // Track if the course is purchased
  final CartController cartController = Get.put(CartController()); // Initialize CartController

  @override
  void initState() {
    super.initState();
    _checkIfPurchased();
  }

  Future<void> _checkIfPurchased() async {
    final userId = FirebaseAuth.instance.currentUser ?.uid;

    if (userId != null) {
      // Fetch the purchase record for the user
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Purchases')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        List<dynamic> purchasedCourses = userDoc['purchasedCourses'] ?? [];
        // Check if the current course ID is in the purchasedCourses list
        setState(() {
          _isPurchased = purchasedCourses.contains(widget.cardContents.id);
        });
      }
    } else {
      print("User  is not authenticated.");
    }
  }

  Future<void> purchaseCourse(String courseId) async {
    final userId = FirebaseAuth.instance.currentUser ?.uid;

    if (userId != null) {
      // Fetch the user's first name from the Users collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users') // Assuming you have a Users collection
          .doc(userId)
          .get();

      String firstName = userDoc['firstName'] ?? 'User  '; // Default to 'User  ' if not found

      // Create a new purchase record in the purchases collection
      await FirebaseFirestore.instance
          .collection('Purchases')
          .doc(userId)
          .update({
        'purchasedCourses': FieldValue.arrayUnion([courseId]),
        'firstName': firstName, // Store the user's first name
      });

      // Update the local state
      setState(() {
        _isPurchased = true; // Update the purchase status
      });
    } else {
      print("User  is not authenticated.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back, color: Colors.white,)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          Obx(() => badges.Badge(
            showBadge: cartController.cartItems.isNotEmpty,
            badgeContent: Text(
              '${cartController.cartItems.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            position: badges.BadgePosition.topEnd(top: 5, end: 5),
            child: IconButton(
              onPressed: () {
                // Navigate to cart page or show cart details
                Get.to(() => CartView()); // Assuming you have a CartView
              },
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white,),
            ),
          )),
        ],
        title: Text(widget.cardContents.title,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: widget.cardContents.imageUrl,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.white!,
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cardContents.title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
                    ),
                    const SizedBox(height: 8.0),
                    if (_isExpanded) ...[
                      Text(
                        widget.cardContents.subTitle,
                        style: GoogleFonts.poppins(
                            fontSize: 18.0, fontWeight: FontWeight.w300,color: Colors.white),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.cardContents.content,
                        style: GoogleFonts.poppins(fontSize: 16.0,color: Colors.white),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.cardContents.ratings.toString(),
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.star, color: Colors.amber, size: 16)
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Row(
                        children: [
                          Text("₹", style: TextStyle(fontSize: 20, color: Colors.white)),
                          Text(
                            widget.cardContents.price.toString(),
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      // Buy Now
                      GestureDetector(
                        onTap: () async {
                          if (!_isPurchased) {
                            await purchaseCourse(widget.cardContents.id.toString());
                            Loaders.successSnackBar(
                                title: 'Success!',
                                message: "Course purchased successfully!");
                            setState(() {
                              _isPurchased = true; // Update state to reflect purchase
                            });
                          } else {
                            // Navigate to CourseContentPage when already purchased
                            Get.to(() => CourseContentPage(course: widget.cardContents));
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _isPurchased ? "Go to Course" : "Buy Now",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),

                      /// Add to Cart
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true; // Show loader
                                });

                                await cartController.addToCart(
                                  widget.cardContents.id.toString(),
                                  widget.cardContents.title,
                                  widget.cardContents.imageUrl,
                                  widget.cardContents.ratings,
                                );

                                setState(() {
                                  isLoading =
                                  false; // Hide loader after operation
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height:
                                MediaQuery.of(context).size.height * 0.06,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border:
                                  Border.all(color: Colors.blue, width: 3),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                    color: Colors.blue)
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add),
                                    SizedBox(width: 8),
                                    // spacing between icon and text
                                    Text("Add to Cart"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}