part of 'friend_request_bloc.dart';

sealed class FriendRequestEvent extends Equatable {
  const FriendRequestEvent();

  @override
  List<Object> get props => [];
}

class listRequested extends FriendRequestEvent {
  /*final int userId;

  const listRequested({required this.userId});

  @override
  List<Object> get props => [userId];*/
}

class SendRequest extends FriendRequestEvent {
  final String receiverName;

  const SendRequest({required this.receiverName});

  @override
  List<Object> get props => [receiverName];
}

class AcceptRequest extends FriendRequestEvent {
  final int requestId;

  const AcceptRequest({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RejectRequest extends FriendRequestEvent {
  final int requestId;

  const RejectRequest({required this.requestId});

  @override
  List<Object> get props => [requestId];
}