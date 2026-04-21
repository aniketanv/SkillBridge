import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/models/review_model.dart';

part 'review_repository.g.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(ReviewModel review) async {
    WriteBatch batch = _firestore.batch();
    
    // Save review
    final newReviewRef = _firestore.collection('reviews').doc();
    batch.set(newReviewRef, review.copyWith(id: newReviewRef.id).toMap());

    // Recalculate Teacher Rating (Simplified client-side logic to avoid cloud functions for now)
    final teacherDocRef = _firestore.collection('users').doc(review.teacherId);
    final teacherDoc = await teacherDocRef.get();
    
    if (teacherDoc.exists) {
      int totalRatings = teacherDoc.data()?['totalRatings'] ?? 0;
      double avgRating = (teacherDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
      
      double newAvg = ((avgRating * totalRatings) + review.rating) / (totalRatings + 1);
      
      batch.update(teacherDocRef, {
        'totalRatings': totalRatings + 1,
        'averageRating': newAvg,
      });
    }

    await batch.commit();
  }

  Stream<List<ReviewModel>> getTeacherReviews(String teacherId) {
    return _firestore.collection('reviews')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

@riverpod
ReviewRepository reviewRepository(Ref ref) {
  return ReviewRepository();
}

@riverpod
Stream<List<ReviewModel>> teacherReviews(Ref ref, String teacherId) {
  return ref.watch(reviewRepositoryProvider).getTeacherReviews(teacherId);
}
