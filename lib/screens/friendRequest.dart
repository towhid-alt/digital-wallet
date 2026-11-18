import 'package:digital_wallet/bloc/friendRequests/friend_request_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class requestScreen extends StatefulWidget {
  const requestScreen({super.key});

  @override
  State<requestScreen> createState() => _requestScreenState();
}

class _requestScreenState extends State<requestScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String searchResultText = '';
  List<Map<String, dynamic>> friendRequest = [];

  @override
  void initState(){
    super.initState();
    fetchRequests();
  }

  @override
  void dispose(){
    _usernameController.dispose();
    super.dispose();
  }

  void _handleSendRequest() {//FIXME: Change to Future<void>...async..., if code is breaking
    String username = _usernameController.text.trim();

    context.read<FriendRequestBloc>().add(SendRequest(receiverName: username));
  }

  void fetchRequests(){
    context.read<FriendRequestBloc>().add(listRequested());
  }

  void _acceptRequest(int requestId){
    context.read<FriendRequestBloc>().add(AcceptRequest(requestId: requestId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendRequestBloc, FriendRequestState>(
      listener: (context, state) {
          if(state is UserFound) {
            searchResultText = "Request sent successfully";
          }
          if(state is UserNotFound){
            searchResultText = "Username not found";
          }
          if(state is RequestFetched){
            friendRequest = state.requests;
          }
          if(state is RequestAccepted){
            friendRequest.removeWhere((request) => request['id'] == state.requestId);
          }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 22, 22, 23),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Send owe request using username',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    width: 300,
                    height: 50,
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7,),
                  Text(searchResultText,style: TextStyle(color:state is UserFound? Colors.green : Colors.red),),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _handleSendRequest();
                      },

                      style: ElevatedButton.styleFrom(
                        //foregroundColor: Colors.green,
                        backgroundColor: Colors.green[400],
                      ),
                      child: Text(
                        'Send Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Friend Requests',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  /**
                   * List View Builder for Friend Requests list
                   */
                  Container(
                    width: 600,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final request = friendRequest[index];
                        final requestId = request['id'] as int;
                        final senderName =
                            request['sender']['username'] as String;
                        return ListTile(
                          key: ValueKey(requestId),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  senderName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 445),
                              IconButton(
                                onPressed: () {
                                    _acceptRequest(requestId);
                                },
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () {

                                },
                                icon: const Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white,
                        thickness: 1,
                        height: 1,
                      ),
                      itemCount: friendRequest.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
