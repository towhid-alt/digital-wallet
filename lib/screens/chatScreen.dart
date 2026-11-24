import 'package:digital_wallet/bloc/chat/chat_bloc.dart';
import 'package:digital_wallet/models/messages.dart';
import 'package:digital_wallet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectSocket();
    //fetchChatHistory();
  }

  void connectSocket(){
    context.read<ChatBloc>().add(ConnectSocketEvent(userId: widget.currentUserId));
  }

  /**Future<void> fetchChatHistory() async {
    try {
      context.read<ChatBloc>().add(
        FetchChat(
          currentUserId: widget.currentUserId,
          receiverId: widget.receiverId,
        ),
      );
    } catch (e) {
      print('Error fetching chats: $e');
    }
  }*/

  void _sendMessage() {
    final detail = _detailsController.text.trim();
    final amount = _amountController.text;

    context.read<ChatBloc>().add(SendMessageEvent(amount: amount, currentUserId: widget.currentUserId, detail: detail, receiverId: widget.receiverId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.text,
        title: Text(widget.receiverName, style: TextStyle(
          color: AppColors.text
        ),),
      ),
      body: Container(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatError) {
              return Center(child: Text('Chat error'));
            }

            if (state is ChatConnected) {
              return Column(
                children: [
                  Expanded(
                    child: state.chats.isEmpty
                        ? const Center(
                            child: Text(
                              'No Owes yet',
                              style: TextStyle(
                                fontSize: 46,
                                color: AppColors.text,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: state.chats.length,
                            itemBuilder: (context, index) {
                              final chat = state.chats[index];
                              final isOwnMessage = chat.senderId == widget.currentUserId;
                              return _buildOweCard(message: chat, isOwnMessage: isOwnMessage);
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.foreground
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: TextStyle(
                                  color: AppColors.text
                                ),
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Owe amount',
                                  hintStyle: TextStyle(
                                    color: AppColors.text
                                  )
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                style: TextStyle(
                                  color: AppColors.text
                                ),
                                controller: _detailsController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Owe detail(optional)',

                                  hintStyle: TextStyle(
                                    color: AppColors.text
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Initializing chat...'));
          },
        ),
      ),
    );
  }

/**
 * Owe card UI
 */
  Widget _buildOweCard({
    required Message message,
    required bool isOwnMessage,
  }){
    return Align(
      alignment: isOwnMessage? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 300,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          shape: BoxShape.rectangle,
          image: DecorationImage(image: AssetImage('assets/images/owes-card.png'),
          fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            children: [
              Text(message.amount, style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),),
              const SizedBox(height: 6,),
              Text(message.detail, style: TextStyle(
                color: Colors.white,
              ),),
              const SizedBox(height: 4,),
              Text(
                _formatTime(message.createdAt),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
