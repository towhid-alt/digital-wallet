import 'package:digital_wallet/screens/chatHome.dart';
import 'package:digital_wallet/screens/friendRequest.dart';
import 'package:digital_wallet/screens/homeScreen.dart';
import 'package:digital_wallet/screens/loginScreen.dart';
import 'package:digital_wallet/screens/signUpScreen.dart';
import 'package:flutter/material.dart';

class AppRouter {

  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const Signupscreen());
      
      case '/login':
       return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/chatHome':
        return MaterialPageRoute(builder: (_) => const chatHomeScreen());

      case '/friendRequest':
        return MaterialPageRoute(builder: (_) => const requestScreen());
        
        default:
        return MaterialPageRoute(builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}'),),
        ));
      
      
    }
  }
}