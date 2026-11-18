part of 'friend_request_bloc.dart';

sealed class FriendRequestState extends Equatable {
  const FriendRequestState();
  
  @override
  List<Object> get props => [];
}

final class RequestInitial extends FriendRequestState {}

final class RequestLoading extends FriendRequestState {}

final class SearchingUser extends FriendRequestState{}

final class UserFound extends FriendRequestState{
  final String message;

  const UserFound({required this.message});

  @override
  List<Object> get props => [message];
}

final class UserNotFound extends FriendRequestState{
  final String message;

  const UserNotFound({required this.message});

  @override
  List<Object> get props => [message];
}

final class RequestFetched extends FriendRequestState{
  final List<Map<String, dynamic>> requests;

  const RequestFetched({required this.requests});

  @override
  List<Object> get props => [requests];
}

final class RequestFetchError extends FriendRequestState{}

final class RequestAccepted extends FriendRequestState{
  final int requestId;

  const RequestAccepted({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

final class RequestRejected extends FriendRequestState{
  final int requestId;

  const RequestRejected({required this.requestId});

  @override
  List<Object> get props => [requestId];
}