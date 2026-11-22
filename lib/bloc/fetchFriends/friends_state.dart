part of 'friends_bloc.dart';

sealed class FriendsState extends Equatable {
  const FriendsState();
  
  @override
  List<Object> get props => [];
}

final class FriendsInitial extends FriendsState {}

final class FriendsLoading extends FriendsState{}

final class FriendsLoaded extends FriendsState {
  final List<Map<String, dynamic>> friendList;
  final String currentUserId;

  const FriendsLoaded({required this.friendList, required this.currentUserId});

  @override
  List<Object> get props => [friendList, currentUserId];
}

final class FriendsError extends FriendsState {}
