import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:skillet/presentation/screens/home_screen.dart';
import 'package:skillet/presentation/screens/learn_screen/learn_screen.dart';
import 'package:skillet/presentation/screens/profile_screen/profile_screen.dart';
import 'package:skillet/presentation/screens/search_screen/search_screen.dart';
import 'package:skillet/presentation/screens/wishlist/wishlst_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
            () => FlashyTabBar(
          selectedIndex: controller.selectedIndex.value,
          backgroundColor: Colors.black,
          showElevation: true,
          iconSize: 24.0,
          animationCurve: Curves.linear,
          onItemSelected: (index) => controller.selectedIndex.value = index,
          items: [
            FlashyTabBarItem(
              icon:  Icon(Iconsax.home, color: Colors.white),
              title: Text("Explore"),
              activeColor: Colors.blue,
              inactiveColor: Colors.black,
            ),
            FlashyTabBarItem(
              icon: Icon(Iconsax.video, color: Colors.white),
              title: Text("Meetings"),
              activeColor: Colors.blue,
              inactiveColor: Colors.black,
            ),
            FlashyTabBarItem(
              title: Text("Search"),
              icon: Icon(Iconsax.search_favorite, color: Colors.white),
              activeColor: Colors.blue,
              inactiveColor: Colors.black,
            ),
            FlashyTabBarItem(
              title: Text("Wishlist"),
              icon: Icon(Icons.favorite_outline, color: Colors.white),
              activeColor: Colors.blue,
              inactiveColor: Colors.black,
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.person_outline, color: Colors.white),
              title: Text("Profile"),
              activeColor: Colors.blue,
              inactiveColor: Colors.black,
            ),
          ],
        ),
      ),
      body: Obx(
            () => controller.screens[controller.selectedIndex.value],
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    HomeScreen(),
    MettingScreen(),
    SearchScreen(),
    MyLearning(),
    ProfileScreen(),
  ];
}
