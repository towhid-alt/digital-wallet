part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatConnected extends ChatState {
  final List<Message> chats;
  final bool isConnected;

  const ChatConnected({required this.chats, required this.isConnected});

  @override
  List<Object> get props => [chats];
}

final class ChatError extends ChatState {
  final String error;

  const ChatError({required this.error});

  @override
  List<Object> get props => [error];
}
