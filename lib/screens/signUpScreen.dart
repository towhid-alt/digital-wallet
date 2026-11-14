
import 'package:digital_wallet/bloc/auth/auth_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super
        .dispose(); //Allows Flutter's parent State class to perform its own cleanup
  }

  void _handleSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if(password.length < 6){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password should be atleast 6 characters')));
    }

    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      context.read<AuthBloc>().add(
        SignUpRequested(username: username, email: email, password: password),
      ); 
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is AuthAuthenticated) {
          // Navigate to home screen
          Navigator.pushNamed(context, '/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Owes',
                    style: TextStyle(
                      fontFamily: 'Varsity',
                      fontSize: 30,
                      color: Colors.green[400],
                    ),
                  ),
                  const SizedBox(height: 02),
                  const Text(
                    'Sign up to continue',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'Username',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        )),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      obscureText: _obscureText,
                      style: const TextStyle(color: Colors.black),
                      controller: _passwordController,
                      decoration: InputDecoration(hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        )),
                      
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              
                              //TODO: Navigate to login screen
                              Navigator.pushNamed(context, '/login'); 
                            },
                        ),
                      ],
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
