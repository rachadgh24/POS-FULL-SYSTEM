import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:localmartpro/features/auth/AuthState.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState(user: null, error: null)) {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = doc.data()?['role'] as String?;
        final name = doc.data()?['name'] as String?;

        state = state.copyWith(user: user, role: role, error: null, name: name);
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      state = state.copyWith(user: userCredential.user, error: null);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> register(
    String email,
    String password,
    String? role,
    String name,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'email': email, 'role': role, 'name': name});

      state = state.copyWith(user: userCredential.user, error: null);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = AuthState(user: null, role: null, error: null);
  }

  // String? role() {
  //   return state.role;
  // }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
