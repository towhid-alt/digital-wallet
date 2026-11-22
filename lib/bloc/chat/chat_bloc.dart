import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  ChatBloc({required this._chatService}) : super(ChatInitial()) {
    on<FetchChat>(_fetchChat);
  }

  Future<void> _fetchChat(
    FetchChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final response = await _chatService._fetch(
      currentUserId: event.currentUserId,
      receiverId: event.receiverId,
    );

    if (response['success'] == true) {
      emit(ChatLoaded(
        chats: response['chats'],
      ));
    } else {
      emit(ChatError());
    }
  }
}

class ChatService {
  String baseurl;

  ChatService({required this.baseurl});

  Future<Map<String, dynamic>> _fetch({
    required String currentUserId,
    required String receiverId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/chats/fetchChats').replace(
          queryParameters: {
            'currentUserId': currentUserId,
            'receiverId': receiverId,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.accessToken != null)
            'Authorization': 'Bearer ${AuthService.accessToken}',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final chats = data is Map<String, dynamic>
            ? data['chats']
            : data;
        if (chats is! List) {
          return {'success': false, 'message': 'Invalid chat response'};
        }
        return {
          'success': true,
          'chats': List<Map<String, dynamic>>.from(chats),
        };
      }
      return {
        'success': false,
        'message': data is Map<String, dynamic>
            ? data['message']
            : 'Failed to fetch chats',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
