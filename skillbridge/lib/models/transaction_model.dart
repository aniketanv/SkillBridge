class TransactionModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final int amount;
  final String type; // deduction, earning, refund
  final String bookingId;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.type,
    required this.bookingId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'type': type,
      'bookingId': bookingId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      fromUserId: map['fromUserId'] as String? ?? '',
      toUserId: map['toUserId'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      type: map['type'] as String? ?? 'payment',
      bookingId: map['bookingId'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
