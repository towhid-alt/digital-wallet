import 'package:digital_wallet/bloc/fetchFriends/friends_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class chatHomeScreen extends StatefulWidget {
  const chatHomeScreen({super.key});

  @override
  State<chatHomeScreen> createState() => _chatHomeScreenState();
}

class _chatHomeScreenState extends State<chatHomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() {
    context.read<FriendsBloc>().add(FetchFriends());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading || state is FriendsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FriendsError) {
          return const Center(child: Text('Error fetching friends list'));
        }

        if (state is FriendsLoaded) {
          if (state.friendList.isEmpty) {
            return const Center(child: Text('No friends found'));
          }

          return Scaffold(
        backgroundColor: const Color.fromARGB(255, 22, 22, 23),
            body: ListView.separated(
              itemBuilder: (context, index) {
                final friend = state.friendList[index];
                final username =
                    friend['friendsName']?.toString() ?? 'Unknown user';
            
                return ListTile(
                  title: Text(
                    username,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {},
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white, thickness: 1, height: 1),
              itemCount: state.friendList.length,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
