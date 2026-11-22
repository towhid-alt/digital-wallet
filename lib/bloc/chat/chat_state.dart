part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<Map<String,dynamic>> chats;

  const ChatLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}

final class ChatError extends ChatState {}
