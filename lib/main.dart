import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/core/theme.dart';
import 'package:localmartpro/features/auth/AuthController.dart';
import 'package:localmartpro/features/auth/view/login.dart';
import 'package:localmartpro/features/auth/view/mainScreen.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MainApp()));
  
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.read(productControllerProvider.notifier).listenProducts();

    final authState = ref.watch(authControllerProvider);
    return MaterialApp(
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      debugShowCheckedModeBanner: false,

      home: Builder(
        builder: (context) {
          if (authState.user != null) {
            return MainScreen();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
