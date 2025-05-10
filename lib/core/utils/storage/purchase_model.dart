import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String purchaseId;
  final String userId;
  final String courseId;
  final String courseTitle;
  final double price;
  final String paymentStatus; // "pending", "completed", "failed"
  final String transactionId;
  final DateTime timestamp;

  Purchase({
    required this.purchaseId,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.price,
    required this.paymentStatus,
    required this.transactionId,
    required this.timestamp,
  });

  // Convert Firestore document to Purchase object
  factory Purchase.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Purchase(
      purchaseId: documentId,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      transactionId: data['transactionId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert Purchase object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'price': price,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
