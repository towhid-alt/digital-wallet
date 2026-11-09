import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Inside AuthBloc: SignUpRequested event received');
    emit(AuthLoading());

    final response = await authService.signUp(username: event.username, email: event.email, password: event.password);

    if(response['success']) {
      emit(AuthAuthenticated(userId: response['userId']));

    }else {
      emit(AuthError(message: response['message'] ?? 'AN ERROR OCCURED DURING SIGNUP'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Inside AuthBloc: LoginRequested event received');
    emit(AuthLoading());
    print('Attempting login for email: ${event.email}');
    final response = await authService.login(
      email: event.email,
      password: event.password,
    );

    if (response['success']) {
      emit(AuthAuthenticated(userId: response['userId']));
    }
  }

  void logout() {}
}

class AuthService {
  final String baseUrl;

  AuthService({this.baseUrl = 'http://localhost:5002'}); //Named parameter constructor

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Inside AuthService: login() called with email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login successful for user: $email');
        return {'success': true, 'message': data['message'], 'userId': data['userId']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    print('Inside AuthService: signUp() called with username: $username, email: $email');
    try{
      final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );
    final data = jsonDecode(response.body);

    if(response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message']};
    }
    } catch (e) {
      return { 'success': false, 'error': 'Network error: ${e.toString()}'};
    }
    
  }
}
