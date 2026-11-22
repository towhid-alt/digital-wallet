import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FetchFriendsService _fetchFriendsService;
  FriendsBloc({required this._fetchFriendsService}) : super(FriendsInitial()) {
    on<FetchFriends>(_fetchFriends);
  }

  Future<void> _fetchFriends(
    FetchFriends event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    final response = await _fetchFriendsService.fetch();
    if (response['success']) {
      emit(FriendsLoaded(friendList: response['list'], currentUserId: response['currentUserId']));
    } else {
      emit(FriendsError());
    }
  }
}

class FetchFriendsService {
  final String baseurl;

  FetchFriendsService({required this.baseurl});

  Future<Map<String, dynamic>> fetch() async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/requests/fetchFriends'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.accessToken != null)
            'Authorization': 'Bearer ${AuthService.accessToken}',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final friends = data is List
            ? data
            : data is Map<String, dynamic>
                ? data['friends']
                : null;
        if (friends is! List) {
          return {
            'success': false,
            'error': 'Invalid friends response',
          };
        }
        return {
          'success': true,
          'list': List<Map<String, dynamic>>.from(friends),
          'currentUserId': data['currentUserId'].toString()
        };
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
