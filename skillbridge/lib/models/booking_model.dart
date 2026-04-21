class BookingModel {
  final String id;
  final String skillId;
  final String teacherId;
  final String learnerId;
  final DateTime dateTime;
  final String status; // pending, accepted, rejected, completed
  final int creditAmount;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.skillId,
    required this.teacherId,
    required this.learnerId,
    required this.dateTime,
    this.status = 'pending',
    required this.creditAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillId': skillId,
      'teacherId': teacherId,
      'learnerId': learnerId,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'status': status,
      'creditAmount': creditAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      skillId: map['skillId'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      learnerId: map['learnerId'] as String? ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      status: map['status'] as String? ?? 'pending',
      creditAmount: map['creditAmount'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
