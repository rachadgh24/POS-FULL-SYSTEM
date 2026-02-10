// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/features/auth/AuthController.dart';
import 'package:localmartpro/features/auth/switchScreen.dart';

// final FirebaseAuth _firebase = FirebaseAuth.instance;

// final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  String email = '';
  String password = '';
  String name = '';

  // Future<bool> submit() async {
  //   final valid = formkey.currentState!.validate();
  //   if (!valid) {
  //     return false;
  //   }
  //   formkey.currentState!.save();
  //   try {
  //     final userCredential = await _firebase.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message ?? 'Registration failed')),
  //     );
  //     return false;
  //   }
  // }
  // return true;
  String? selectedRole;
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                ),

                DropdownButton<String>(
                  value: selectedRole,
                  hint: Text('Select role'),
                  items: <String>['admin', 'cashier', 'inventory']
                      .map(
                        (role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedRole = value;
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'at least 6 characters required';
                }
                return null;
              },
              onSaved: (newValue) {
                password = newValue!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'enter a valid name';
                }
                return null;
              },
              onSaved: (newValue) {
                name = newValue!;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  formkey.currentState!.save();

                  await ref
                      .read(authControllerProvider.notifier)
                      .register(email, password, selectedRole, name);
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
                }
              },
              child: Text('register'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  switchScreen(context, 'login');
                },
                child: Text('login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
