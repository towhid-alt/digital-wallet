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
