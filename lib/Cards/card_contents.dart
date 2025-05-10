// Updated CardContents class
class CardContents {
  final String id;
  final String title;
  final String imageUrl;
  final List<String>? videoUrls;
  final String subTitle;
  final double price;
  final String content;
  final String category;
  final double ratings;
  bool isPurchased;
  final List<Map<String, String>>?
      lectures; // New optional parameter for lectures

  CardContents({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.videoUrls,
    required this.price,
    required this.subTitle,
    required this.content,
    required this.category,
    required this.ratings,
    this.isPurchased = false,
    this.lectures, // Optional parameter
  });
}

/// List of all the Card Contents of the courses
List<CardContents> cardContentList = [
  CardContents(
    id: "PY101",
    // Changed ID to a more descriptive format
    title: "The Fundamentals of Python",
    imageUrl:
        "https://logos-world.net/wp-content/uploads/2021/10/Python-Logo.jpg",
    subTitle:
        "The entire course including the fundamentals of Python Programming starting from scratch",
    content: "",
    category: "Python",
    price: 549.00,
    isPurchased: false,
    ratings: 4.5,
  ),
  CardContents(
    id: "ML103",
    // Changed ID
    title: "Introduction to Machine Learning",
    imageUrl:
        "https://emeritus.org/in/wp-content/uploads/sites/3/2023/03/types-of-machine-learning.jpg.optimal.jpg",
    subTitle:
        "Learn the basics of machine learning, including supervised and unsupervised learning",
    content: "",
    category: "AI/ML",
    videoUrls: [
      'assets/course_videos/ml_demo.mp4',
      'assets/course_videos/machine_learning/ml_demo2.mp4',
    ],
    lectures: [
      {
        "title": "Introduction to Machine Learning",
        "type": "Video",
        "duration": "01:05 mins"
      },
      {"title": "Supervised Learning, Linear Regression", "type": "Video", "duration": "01:05 mins"},
    ],
    price: 499.00,
    isPurchased: false,
    ratings: 4.6,
  ),
  CardContents(
    id: "FL102",
    title: "Mastering Flutter",
    imageUrl:
        "https://tamediacdn.techaheadcorp.com/wp-content/uploads/2023/11/16044301/The-History-Of-Flutter-A-Comprehensive-Overview-Of-The-Development-Framework.webp",
    subTitle:
        "A complete guide to Flutter for building cross-platform mobile applications",
    content: "",
    category: "Flutter",
    videoUrls: [
      'assets/course_videos/e4u_vid_sample.mp4',
      'assets/course_videos/video_sample2.mp4',
    ],
    price: 559.00,
    isPurchased: false,
    ratings: 4.7,
    lectures: [
      {
        "title": "Introduction to the Course",
        "type": "Video",
        "duration": "02:05 mins"
      },
      {"title": "What is Flutter?", "type": "Video", "duration": "07:52 mins"},
    ],
  ),
  CardContents(
    id: "WD104",
    // Changed ID
    title: "Web Development with React",
    imageUrl:
        "https://cdn.hashnode.com/res/hashnode/image/upload/v1603797780927/S6loCK6fY.png",
    subTitle:
        "Learn to build modern web applications using React and its ecosystem",
    content: "",
    category: "Web Development",
    price: 699.00,
    isPurchased: false,
    ratings: 4.8,
  ),
  CardContents(
    id: "DSA105",
    // Changed ID
    title: "Data Structures and Algorithms",
    imageUrl:
        "https://notes.edureify.com/wp-content/uploads/2024/03/images-64.jpeg",
    subTitle:
        "A deep dive into DSA to crack coding interviews and competitive programming",
    content: "",
    category: "Computer Science",
    price: 799.00,
    isPurchased: false,
    ratings: 4.9,
  ),
  CardContents(
    id: "IOS107",
    // Changed ID
    title: "iOS App Development with Swift",
    imageUrl:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5GDLleaUcBOpcf2FtAW5xY19eGB6QuFWt2A&s",
    subTitle: "Learn how to build iOS apps using Swift and SwiftUI",
    content: "Officially created in collaboration with the Apple's Swift Team",
    category: "iOS Development",
    price: 499.00,
    isPurchased: false,
    ratings: 4.6,
  ),
  CardContents(
    id: "CYB108",
    // Changed ID
    title: "Cybersecurity Fundamentals",
    imageUrl:
        "https://www.1stformationsblog.co.uk/wp-content/uploads/2021/10/shutterstock_505066678.jpg",
    subTitle:
        "An introductory course on ethical hacking and cybersecurity principles",
    content: "",
    category: "Cybersecurity",
    price: 499.00,
    isPurchased: false,
    ratings: 4.8,
  ),
  CardContents(
    id: "BC109",
    // Changed ID
    title: "Blockchain and Cryptocurrency",
    imageUrl:
        "https://wminers.com/wp-content/uploads/2021/05/blockchain-and-cryptocurrency.jpg",
    subTitle:
        "Understand the fundamentals of blockchain technology and cryptocurrencies",
    content: "",
    category: "Blockchain",
    price: 459.00,
    isPurchased: false,
    ratings: 4.5,
  ),
  CardContents(
    id: "CC110",
    // Changed ID
    title: "Cloud Computing with AWS",
    imageUrl:
        "https://miro.medium.com/v2/resize:fit:1200/1*5G6xWDi4lZJxvLfep7dOTQ.jpeg",
    subTitle: "Master AWS cloud services and solutions architecture",
    content: "",
    category: "Cloud Computing",
    price: 449.00,
    isPurchased: false,
    ratings: 4.9,
  ),
];
