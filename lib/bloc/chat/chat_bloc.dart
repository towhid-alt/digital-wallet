import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:digital_wallet/models/messages.dart';
import 'package:digital_wallet/services/socket_service.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final Uuid _uuid = const Uuid();
  final SocketService _socketService = SocketService();

  List<Message> chats = [];

  ChatBloc({required this._chatService}) : super(ChatInitial()) {
    on<FetchChat>(_fetchChat);
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<ClearLocalListEvent>(_onClearList);
    on<OweAcceptedEvent>(_onOweAccept);
    on<OweRejectedEvent>(_onOweReject);
  }

  List<Message> updateChats ({required String oweId, required String updatedStatus}) {
    return chats
        .map((chat) => chat.id == oweId
            ? chat.copyWith(status: updatedStatus)
            : chat)
        .toList();
  }

  void _onOweAccept(
    OweAcceptedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final response = await _chatService._oweAccept(oweId: event.oweId, senderId: event.senderId, receiverId: event.receiverId);
    if(response['success']){
      chats = updateChats(oweId: event.oweId, updatedStatus: 'ACCEPTED');
      emit(ChatConnected(chats: chats, isConnected: true));
    } else {
      emit(ChatError(error: response['message']));
    }
  }

  void _onOweReject(
    OweRejectedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final response = await _chatService._oweReject(oweId: event.oweId, senderId: event.senderId, receiverId: event.receiverId);
    if(response['success']){
      chats = updateChats(oweId: event.oweId, updatedStatus: 'REJECTED');
      emit(ChatConnected(chats: chats, isConnected: true));
    } else {
      emit(ChatError(error: response['message']));
    }
  }

  /**
   * Handle socket connection
   */
  void _onConnectSocket(
    ConnectSocketEvent event,
    Emitter<ChatState> emit,
  ) async {
    try{
      emit(ChatLoading());

      //Connect to socket
      _socketService.connect(event.userId);
      
      //Listen for incoming messages
      _socketService.onMessageReceived((message) {
        add(ReceiveMessageEvent(chat: message));
      });

      emit(ChatConnected(chats: chats, isConnected: true));
    } catch(e) {
      emit(ChatError(error: 'Error connecting socket: $e'));
    }
  }

  /**
   * Handle disconnection
   */
  void _onDisconnectSocket(
    DisconnectSocketEvent event,
    Emitter<ChatState> emit,
  ) async {
    _socketService.disconnect();
    emit(ChatInitial());
  }

/**
 * Fetch chat handler
 */
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
      final fetchedChats = response['chats'];
      if (fetchedChats is List<Message>) {
        chats = List<Message>.of(fetchedChats);
      }
      emit(ChatConnected(
        chats: chats, isConnected: true,
      ));
    } else {
      emit(ChatError(
        error: response['message']?.toString() ??
            'Error fetching chats',
      ));
    }
  }

  /**
   * Handle Sending messages
   */
  void _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit
  ) async{ 
    try{
      //Create new message
      final message = Message(id: _uuid.v4(), detail: event.detail, amount: event.amount, senderId: event.currentUserId, receiverId: event.receiverId, createdAt: DateTime.now(), status: 'PENDING');
      //Add to local list
      chats = [...chats, message];
      _socketService.sendMessage(message);
      //Update state
      if (state is ChatConnected){
        emit(ChatConnected(chats: chats, isConnected: true));
      }
    } catch (e){
      emit(ChatError(error: 'Failed to send message: $e'));
    }
  }

  void _onReceiveMessage(
    ReceiveMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    chats = [...chats, event.chat];

    if(state is ChatConnected){
      emit(ChatConnected(chats: chats, isConnected: true));
    }
  }

  void _onClearList (
    ClearLocalListEvent event,
    Emitter<ChatState> emit,
  ) {
    chats = [];
  }
}

/**
 * Chat Services
 */

class ChatService {
  String baseurl;

  ChatService({required this.baseurl});

  /**
   * Fetch chats
   */
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
      final List<dynamic> data = jsonDecode(response.body);
      //Converting to message model
      final List<Message> fetchedChat = data.map((messageJson) => Message.fromJson(messageJson)).toList();
      if (response.statusCode == 200) {
       return {'success': true, 'chats': fetchedChat};
      } else {
        return {'success': false, 'message':'Error fetching chat'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /**
   * Owe Accepted
   */
  Future<Map<String, dynamic>> _oweAccept({
    required String oweId,
    required String senderId,
    required String receiverId
  })async {
    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/owes/accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'oweId': oweId,
          'senderId': senderId,
          'receiverId': receiverId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200){
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch(e){
      return {'success': false, 'message': 'Error: $e'};
    }
  }
   /**
   * Owe Rejected
   */
  Future<Map<String, dynamic>> _oweReject({
    required String oweId,
    required String senderId,
    required String receiverId
  })async {
    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/owes/delete'),
        headers: {'Content-Type': 'application/json'},
        body:jsonEncode({'oweId': oweId,
        'senderId': senderId,
        'receiverId': receiverId}) 
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200){
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch(e){
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
