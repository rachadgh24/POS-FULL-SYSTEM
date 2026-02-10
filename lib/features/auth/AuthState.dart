import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final String? error;
  final String? role;
  final String? name;

  AuthState( {this.name,this.role, this.user, this.error});

  AuthState copyWith({User? user, String? error, String? role, String? name}) {
    return AuthState(
      user: user ?? this.user,
      error: error ?? this.error,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }
}
