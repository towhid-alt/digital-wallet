
import 'package:digital_wallet/confiq/appConfigue.dart';
import 'package:digital_wallet/models/messages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  bool isConnected = false;
  /**
   * Connect to a server
   */
  void connect(String userId){
    socket = IO.io(
      AppConfig.baseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'userId': userId}
      },
    );

    socket.onConnect((_) {
      print('Socket connected');
      isConnected = true;
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      isConnected = false;
    });

    socket.onConnectError((error) {
      print('Socket connection error: $error');
    });

    socket.connect();
  }

  /**
   * Send a message
   */
  void sendMessage(Message message){
          print('Inside sendMessage emitter...');
    if(isConnected){
      socket.emit('sendMessage', {
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'detail': message.detail,
        'amount': message.amount,
      });
    }
  }

  void disconnect(){
    if(isConnected) {
      socket.disconnect();
      socket.dispose();
    }
  }

  void onMessageReceived(Function(Message) callback){
    socket.on('receiveMessage', (data) {
      try{
        final message = Message.fromJson(data);
        callback(message);
        socket.off('receiveMessage');
      } catch(e){
        print('❌Error parsing message: $e');
      }
    });
  }
}