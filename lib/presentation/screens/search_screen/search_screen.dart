import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Cards/card_contents.dart';
import '../../../Cards/card_expanded_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<CardContents> filteredCourses = cardContentList; // Initially show all courses
  String searchQuery = ''; // Search query

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      filteredCourses = cardContentList.where((course) {
        return course.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Search Courses",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
              child: Text(
                "No results found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return ListTile(
                  title: Text(course.title, style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.subTitle, style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4), // Add some space between subtitle and rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 16), // Star icon
                          SizedBox(width: 4), // Space between icon and rating
                          Text(
                            course.ratings.toString(), // Assuming rating is a double or int
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  leading: CachedNetworkImage(
                    imageUrl: course.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                  ),
                  onTap: () {
                    Get.to(() => CardExpandedView(cardContents: course));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}