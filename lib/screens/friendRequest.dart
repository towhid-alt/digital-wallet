import 'package:flutter/material.dart';

class requestScreen extends StatefulWidget {
  const requestScreen({super.key});

  @override
  State<requestScreen> createState() => _requestScreenState();
}

class _requestScreenState extends State<requestScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                const Text('Send owe request using username',style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                const SizedBox(height: 20,),
                Container(
                  margin: EdgeInsets.all(10.0),
                  width: 300,
                  height: 50,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username'
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(onPressed: () {}, child: Text('Send Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),),
                  style: ElevatedButton.styleFrom(
                    //foregroundColor: Colors.green,
                    backgroundColor: Colors.green[400],
                  ),),
                )
              ],
            ),
        ),
      ),
    );
  }
}