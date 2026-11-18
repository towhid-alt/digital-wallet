import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:digital_wallet/bloc/fetchFriends/friends_bloc.dart';
import 'package:digital_wallet/bloc/friendRequests/friend_request_bloc.dart';
import 'package:digital_wallet/presentation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String serverUrl = 'http://localhost:5002'; 
  MyApp({super.key});
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: AuthService(baseUrl: serverUrl),
           
        ),
        ),

        BlocProvider(create: (context) => FriendRequestBloc(fetchService: FetchService(baseurl: serverUrl))),

        BlocProvider(create: (context) => FriendsBloc(fetchFriendsService: FetchFriendsService(baseurl: serverUrl)))

      ],
      child: MaterialApp(
        title: 'Digital wallet',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: _appRouter.onGenerateRoute,
        initialRoute: '/',
      ),
    );
  }
}