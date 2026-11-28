import 'package:equatable/equatable.dart';

class Message extends Equatable {
    final String id;
    final String detail;
    final String amount;
    final String senderId;
    final String receiverId;
    final String status;
    final DateTime createdAt;


const Message({
    required this.id,
    required this.detail,
    required this.amount,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
});

Message copyWith({String? status}) {
  return Message(
    id: id,
    detail: detail,
    amount: amount,
    senderId: senderId,
    receiverId: receiverId,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}

// Convert to JSON for sending over socket - FOR DATA OUT
  Map<String, dynamic> toJson() => {
    'id': id,
    'detail': detail,
    'amount': amount,
    'senderId': senderId,
    'receiverId': receiverId,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  // Create from JSON - FOR DATA IN
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    //Converting int to String
    id: json['id'].toString(),
    detail: json['detail'] ?? '',
    amount: json['amount'].toString(),
    senderId: json['senderId'].toString(),
    receiverId: json['receiverId'].toString(),
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );

@override
  List<Object?> get props => [id, detail, amount, senderId, status, receiverId, createdAt];
}