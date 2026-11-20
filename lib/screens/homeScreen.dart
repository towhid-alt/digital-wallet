import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.currentUser});

  final String currentUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 23),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.rectangle,
            ),
            child: Row(
              children: [
                Text(
                  'Owes',
                  style: TextStyle(
                    fontFamily: 'Varsity',
                    fontSize: 24,
                    color: Colors.green[400],
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: [
                        const TextSpan(text: 'Logged in as: '),
                        TextSpan(
                          text: widget.currentUser,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /**
           * After Nav bar
           */
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Container(
                  margin: EdgeInsets.all(8),
                  height: 300,
                  width: 700,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 40, 43, 40),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    //border: BoxBorder.all(color: Colors.black, width: 2)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          'Available balance:',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/chatHome');
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(color: Colors.white,width: 2.0),
                              image: DecorationImage(scale: 1.0,image: AssetImage('assets/icons/transfer.png',
                              ))
                            ),

                          ),
                          const SizedBox(height: 10,),
                          Text('Send Money',style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.white),)
                        ],
                      ),
                    ),
                    const SizedBox(width: 40,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/friendRequest');
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.black,width: 2.0),
                              image: DecorationImage(scale: 1.0,image: AssetImage('assets/icons/friends.png',
                              ))
                            ),

                          ),
                          const SizedBox(height: 10,),
                          Text('Owe Request',style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.white),)
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
