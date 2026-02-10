// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/features/auth/AuthController.dart';
// import 'package:localmartpro/features/auth/AuthState.dart';
import 'package:localmartpro/features/auth/switchScreen.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final FirebaseAuth _firebase = FirebaseAuth.instance;

  // Future<bool> submit() async {
  //   final valid = formkey.currentState!.validate();
  //   if (!valid) {
  //     return false;
  //   }
  //   formkey.currentState!.save();
  //   try {
  //     final UserCredential userCredential = await _firebase
  //         .signInWithEmailAndPassword(
  //           email: emailController.text,
  //           password: passwordController.text,
  //         );
  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error occurred')));
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Form(
        key: formkey,
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onSaved: (value) {
                emailController.text = value!;
              },
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'at least 6 characters required';
                }

                return null;
              },
              onSaved: (newValue) {
                passwordController.text = newValue!;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .login(emailController.text, passwordController.text);
                final AuthState = ref.watch(authControllerProvider);
                if (AuthState.user != null) {
                  switchScreen(context, 'mainscreen');
                }
                if (AuthState.error != null) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AuthState.error!)));
                }
              },
              child: Text('login'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  switchScreen(context, 'register');
                },
                child: Text('register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
