import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:digital_wallet/screens/chatHome.dart';
import 'package:digital_wallet/screens/friendRequest.dart';
import 'package:digital_wallet/screens/homeScreen.dart';
import 'package:digital_wallet/screens/loginScreen.dart';
import 'package:digital_wallet/screens/signUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _AuthGate());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/chatHome':
        return MaterialPageRoute(builder: (_) => const chatHomeScreen());
      case '/friendRequest':
        return MaterialPageRoute(builder: (_) => const requestScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Go to login'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is AuthUnauthenticated) {
          return const Signupscreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
