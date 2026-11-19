import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckSessionRequested>(_onCheckSessionRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    add(const CheckSessionRequested());
  }

  Future<void> _onCheckSessionRequested(
    CheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await authService.restoreSession();
      if (session == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(userId: session['userId']));
      }
    } catch (error) {
      emit(AuthError(message: 'Unable to restore saved session: $error'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final response = await authService.signUp(
      username: event.username,
      email: event.email,
      password: event.password,
    );

    if (response['success']) {
      emit(AuthAuthenticated(userId: response['userId']));
    } else {
      emit(
        AuthError(
          message:
              response['message'] ??
              response['error'] ??
              'AN ERROR OCCURED DURING SIGNUP',
        ),
      );
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final response = await authService.login(
      email: event.email,
      password: event.password,
    );
    if (response['success']) {
      emit(AuthAuthenticated(userId: response['userId']));
    } else {
      emit(
        AuthError(
          message:
              response['message'] ??
              response['error'] ??
              'AN ERROR OCCURED DURING LOGIN',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.logout();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(message: 'Unable to log out: $error'));
    }
  }
}

class AuthService {
  final String baseUrl;
  final FlutterSecureStorage _storage;
  static String? accessToken;
  static const _tokenKey = 'accessToken';
  static const _userIdKey = 'userId';

  AuthService({required this.baseUrl, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, String>?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userId = await _storage.read(key: _userIdKey);

    if (token == null || userId == null) {
      await logout();
      return null;
    }

    accessToken = token;
    return {'token': token, 'userId': userId};
  }

  Future<void> _saveSession({
    required String token,
    required Object userId,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    accessToken = token;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    accessToken = null;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] as String?;
        final userId = data['userId'];
        if (token == null || userId == null) {
          return {
            'success': false,
            'message': 'Login response is missing session data',
          };
        }
        await _saveSession(token: token, userId: userId);
        return {
          'success': true,
          'message': data['message'],
          'userId': data['userId'],
        };
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] as String?;
        final userId = data['userId'];
        if (token == null || userId == null) {
          return {
            'success': false,
            'message': 'Sign-up response is missing session data',
          };
        }
        await _saveSession(token: token, userId: userId);
        return {'success': true, 'message': data['message'], 'userId': userId};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
