import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.all(8),
              height: 300,
              width: 700,
              decoration: BoxDecoration(
                color: Colors.green[200],
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
                        color: Colors.black,
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
                          border: Border.all(color: Colors.black,width: 2.0),
                          image: DecorationImage(scale: 1.0,image: AssetImage('assets/icons/transfer.png',
                          ))
                        ),
                        
                      ),
                      const SizedBox(height: 10,),
                      Text('Send Money',style: TextStyle(fontWeight: FontWeight.bold),)
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
                          color: Colors.green,
                          border: Border.all(color: Colors.black,width: 2.0),
                          image: DecorationImage(scale: 1.0,image: AssetImage('assets/icons/friends.png',
                          ))
                        ),
                        
                      ),
                      const SizedBox(height: 10,),
                      Text('Owe Request',style: TextStyle(fontWeight: FontWeight.bold),)
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}