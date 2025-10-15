import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cam_app/models/detection.dart';

class DetectionRepository {
  DetectionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _userCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('detections');
  }

  Future<String> addDetection({
    required bool isStroke,
    required double confidencePercent,
    String? note,
  }) async {
    final String userId = _auth.currentUser?.uid ?? 'anonymous';
    final docRef = await _userCollection(userId).add({
      'isStroke': isStroke,
      'confidencePercent': confidencePercent,
      'createdAt': FieldValue.serverTimestamp(),
      'note': note,
    });
    return docRef.id;
  }

  Stream<List<Detection>> watchDetections() {
    final String userId = _auth.currentUser?.uid ?? 'anonymous';
    return _userCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Firestore returns Timestamp; convert safely
        final createdAtRaw = data['createdAt'];
        DateTime createdAt;
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is DateTime) {
          createdAt = createdAtRaw;
        } else {
          createdAt = DateTime.now();
        }
        return Detection(
          id: doc.id,
          isStroke: (data['isStroke'] as bool?) ?? false,
          confidencePercent: (data['confidencePercent'] as num?)?.toDouble() ?? 0.0,
          createdAt: createdAt,
          note: data['note'] as String?,
        );
      }).toList();
    });
  }
}


