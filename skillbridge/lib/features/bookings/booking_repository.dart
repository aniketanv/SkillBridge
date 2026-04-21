import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/models/booking_model.dart';
import 'package:skillbridge/models/transaction_model.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestSession({
    required String skillId,
    required String teacherId,
    required String learnerId,
    required DateTime dateTime,
    required int creditCost,
  }) async {
    // Check if learner has enough credits
    final learnerDoc = await _firestore.collection('users').doc(learnerId).get();
    final int learnerBalance = learnerDoc.data()?['credits'] ?? 0;
    
    if (learnerBalance < creditCost) {
      throw Exception("Insufficient credits");
    }

    WriteBatch batch = _firestore.batch();
    
    // Deduct from learner immediately for pending hold
    batch.update(_firestore.collection('users').doc(learnerId), {
      'credits': FieldValue.increment(-creditCost)
    });

    final newBookingRef = _firestore.collection('bookings').doc();
    final booking = BookingModel(
      id: newBookingRef.id,
      skillId: skillId,
      teacherId: teacherId,
      learnerId: learnerId,
      dateTime: dateTime,
      status: 'pending',
      creditAmount: creditCost,
      createdAt: DateTime.now(),
    );

    batch.set(newBookingRef, booking.toMap());
    await batch.commit();
  }

  Future<void> acceptSession(BookingModel booking) async {
    await _firestore.collection('bookings').doc(booking.id).update({
      'status': 'accepted',
    });
  }

  Future<void> rejectSession(BookingModel booking) async {
    WriteBatch batch = _firestore.batch();
    
    // Refund buyer
    batch.update(_firestore.collection('users').doc(booking.learnerId), {
      'credits': FieldValue.increment(booking.creditAmount)
    });
    
    batch.update(_firestore.collection('bookings').doc(booking.id), {
      'status': 'rejected',
    });

    await batch.commit();
  }

  Future<void> completeSession(BookingModel booking) async {
    WriteBatch batch = _firestore.batch();

    // Pay teacher
    batch.update(_firestore.collection('users').doc(booking.teacherId), {
      'credits': FieldValue.increment(booking.creditAmount)
    });

    batch.update(_firestore.collection('bookings').doc(booking.id), {
      'status': 'completed',
    });

    // Record Transaction
    final txRef = _firestore.collection('transactions').doc();
    final transaction = TransactionModel(
      id: txRef.id,
      fromUserId: booking.learnerId,
      toUserId: booking.teacherId,
      amount: booking.creditAmount,
      type: 'earning',
      bookingId: booking.id,
      timestamp: DateTime.now(),
    );

    batch.set(txRef, transaction.toMap());

    await batch.commit();
  }

  Stream<List<BookingModel>> getMySessions(String userId) {
    // To support complex OR queries (learner OR teacher), we can fetch both or rely on two queries client-side.
    // For simplicity, we can fetch all bookings and filter client-side if rules allow it, or use Filter.or() in Firestore.
    return _firestore.collection('bookings')
        .where(Filter.or(
            Filter('learnerId', isEqualTo: userId),
            Filter('teacherId', isEqualTo: userId)
        ))
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository();
}

@riverpod
Stream<List<BookingModel>> mySessions(Ref ref, String userId) {
  return ref.watch(bookingRepositoryProvider).getMySessions(userId);
}
