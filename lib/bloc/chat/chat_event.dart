part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class FetchChat extends ChatEvent {
  final String currentUserId;
  final String receiverId;

  const FetchChat({required this.currentUserId, required this.receiverId});

  @override
  List<Object> get props => [currentUserId, receiverId];
}

class ConnectSocketEvent extends ChatEvent {
  final String userId;

  const ConnectSocketEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DisconnectSocketEvent extends ChatEvent {}

class ReceiveMessageEvent extends ChatEvent {
  final Message chat;

  const ReceiveMessageEvent({required this.chat});

  @override
  List<Object> get props => [chat];
}

class SendMessageEvent extends ChatEvent {
  final String detail;
  final String amount;
  final String receiverId;
  final String currentUserId;

  const SendMessageEvent({
    required this.amount,
    required this.currentUserId,
    required this.detail,
    required this.receiverId,
  });

  @override
  List<Object> get props => [amount, currentUserId, receiverId,detail];
}

class ClearLocalListEvent extends ChatEvent {}

class OweAcceptedEvent extends ChatEvent {
  final String oweId;
  final String senderId;
  final String receiverId;

  const OweAcceptedEvent({required this.oweId, required this.receiverId, required this.senderId});

  @override
  List<Object> get props => [oweId, senderId, receiverId];
}

class OweRejectedEvent extends ChatEvent {
  final String oweId;
  final String senderId;
  final String receiverId;

  const OweRejectedEvent({required this.oweId, required this.receiverId, required this.senderId});

  @override
  List<Object> get props => [oweId, senderId, receiverId];
}