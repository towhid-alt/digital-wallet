import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'friend_request_event.dart';
part 'friend_request_state.dart';

class FriendRequestBloc extends Bloc<FriendRequestEvent, FriendRequestState> {
  final FetchService _fetchService;

  FriendRequestBloc({required FetchService fetchService})
      : _fetchService = fetchService,
        super(RequestInitial()) {
    on<listRequested>(_fetchFriendRequests);
    on<SendRequest>(_sendRequest);
  }
  /**
   * Fetch Friend Requests event handler
   */
  Future<void> _fetchFriendRequests (
    listRequested event,
    Emitter<FriendRequestState> emit,
  ) async{
    print('Inside fetchFriendRequest event handler...');
    emit (RequestLoading());

    final response = await _fetchService.fetch();

    if(response['success']){
      emit (RequestFetched(requests: response['requests']));
    } else {
      emit(RequestFetchError());
    }
  }
  /**
   * Send Friend Request event handler
   */
  Future<void> _sendRequest (
    SendRequest event,
    Emitter<FriendRequestState> emit
  ) async {
    emit(SearchingUser());

    final response = await _fetchService.send(receiverName: event.receiverName);
    if(response['success']){
      emit(UserFound(message: response['message']));
    } else {
      emit(UserNotFound(message: response['message']));
    }

  }
}
/**
 * Fetch Service for API calls
 */

class FetchService{
  final String baseurl;

  FetchService({required this.baseurl});

  /**
   * fetch Friend Requests list function
   */
  Future <Map<String,dynamic>> fetch () async {
    try{
      final response = await http.post(
        Uri.parse('$baseurl/api/requests/fetch'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.accessToken != null)
            'Authorization': 'Bearer ${AuthService.accessToken}',
        },
      );
      final data = jsonDecode(response.body);
      if(response.statusCode == 200) {
      return {
        'success': true,
        'requests': List<String>.from(data['requests']),
      };
    } else {
      return {'success': false, 'message': data['message']};
    }
    } catch(e){
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /**
   * Send friend request function
   */
  Future <Map<String, dynamic>> send({
    required String receiverName,
  }) async {
    try{
      print('Inside send() function of FriendRequestBloc...');
      final response = await http.post(
        Uri.parse('$baseurl/api/requests/send'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.accessToken != null)
            'Authorization': 'Bearer ${AuthService.accessToken}',
        },
        body: jsonEncode({
          'receiverName': receiverName
        })
      );
      print('Response received from server for friend Request');
      final data = jsonDecode(response.body);
      print('Data Received from server for Friend Request-> ');
      print(data);
      if(response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message']};
    }
    } catch(e){
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}