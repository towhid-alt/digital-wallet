import 'package:digital_wallet/bloc/chat/chat_bloc.dart';
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
    fetchChatHistory();
  }

  Future<void> fetchChatHistory() async {
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
  }

  void _sendMessage() {}

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

            if (state is ChatLoaded) {
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
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    'Amount: ${chat['amount'] ?? 'Unknown'}',
                                  ),
                                  subtitle: Text(
                                    'Status: ${chat['status'] ?? 'Unknown'}',
                                  ),
                                ),
                              );
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
                                  hintText: 'Enter Owe detail',

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
}
