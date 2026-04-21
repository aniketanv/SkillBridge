class ReviewModel {
  final String id;
  final String bookingId;
  final String teacherId;
  final String learnerId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.teacherId,
    required this.learnerId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'teacherId': teacherId,
      'learnerId': learnerId,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      bookingId: map['bookingId'] as String,
      teacherId: map['teacherId'] as String,
      learnerId: map['learnerId'] as String,
      rating: map['rating'] as int,
      reviewText: map['reviewText'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
