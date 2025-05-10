import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state_management/controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Your Cart', style: GoogleFonts.poppins()),
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(child: Text('Your cart is empty', style: GoogleFonts.poppins()));
        }

        return ListView.builder(
          itemCount: cartController.cartItems.length,
          itemBuilder: (context, index) {
            final item = cartController.cartItems[index];
            return ListTile(
              title: Text(item['title'], style: GoogleFonts.poppins()),
              subtitle: Text('Rating: ${item['ratings']}', style: GoogleFonts.poppins()),
              leading: Image.network(item['imageUrl']),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () {
                  cartController.removeFromCart(item['courseId']);
                },
              ),
            );
          },
        );
      }),
    );
  }
}