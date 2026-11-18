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

  const FriendsLoaded({required this.friendList});

  @override
  List<Object> get props => [friendList];
}

final class FriendsError extends FriendsState {}
