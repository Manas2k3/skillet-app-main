import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/constants/loaders.dart';

class CartController extends GetxController {
  var cartItems =
      <Map<String, dynamic>>[].obs; // Observable list to track cart items

  @override
  void onInit() {
    super.onInit();
    loadCartItems(); // Load cart items when the controller is initialized
  }

  Future<void> loadCartItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Cart').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> courses = userDoc['courses'] ?? [];
        cartItems.assignAll(courses
            .map((course) => {
                  'courseId': course['courseId'],
                  'title': course['title'],
                  'imageUrl': course['imageUrl'],
                  'ratings': course['ratings'],
                })
            .toList());
      }
    }
  }

  Future<void> addToCart(
      String courseId, String title, String imageUrl, double ratings) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Loaders.errorSnackBar(title: 'Error', message: 'No internet connection');
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Check if the item is already in the cart
      if (!cartItems.any((item) => item['courseId'] == courseId)) {
        // Add course details to the observable list
        cartItems.add({
          'courseId': courseId,
          'title': title,
          'imageUrl': imageUrl,
          'ratings': ratings,
        });

        // Save to Firestore
        await FirebaseFirestore.instance.collection('Cart').doc(userId).set({
          'courses': FieldValue.arrayUnion([
            {
              'courseId': courseId,
              'title': title,
              'imageUrl': imageUrl,
              'ratings': ratings,
            }
          ]),
        }, SetOptions(merge: true));

        Loaders.successSnackBar(title: 'Success', message: 'Added to cart');
      } else {
        Loaders.warningSnackBar(
            title: 'Hold On!', message: 'You can add this course only once.');
      }
    } else {
      Loaders.errorSnackBar(
          title: 'Error', message: 'User  is not authenticated');
    }
  }

  Future<void> removeFromCart(String courseId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Find the item to remove
      final itemToRemove = cartItems.firstWhere(
          (item) => item['courseId'] == courseId,
          orElse: () => {} // Return an empty map if not found
          );

      // Check if the item was found
      if (itemToRemove.isNotEmpty) {
        // Remove from local list
        cartItems.remove(itemToRemove);

        // Update Firestore
        try {
          await FirebaseFirestore.instance
              .collection('Cart')
              .doc(userId)
              .update({
            'courses': FieldValue.arrayRemove([itemToRemove]),
            // Remove the entire object
          });
          Loaders.successSnackBar(
              title: 'Success', message: 'Removed from cart');
        } catch (e) {
          Loaders.errorSnackBar(
              title: 'Error', message: 'Failed to remove item from cart: $e');
        }
      } else {
        Loaders.warningSnackBar(
            title: 'Warning', message: 'Item not found in cart');
      }
    } else {
      Loaders.errorSnackBar(
          title: 'Error', message: 'User  is not authenticated');
    }
  }
}
