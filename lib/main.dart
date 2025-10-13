import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyfunds_v1/pages/account_page.dart';
import 'firebase_options.dart';
import 'pages/signin_page.dart';
import 'pages/home_page.dart'; // 👈 your bottom nav container

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlyFunds',
      debugShowCheckedModeBanner: false,
      // initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInPage(),
        '/home': (context) => const HomePage(),
        '/account': (context) => const AccountPage(),
        // add others here...
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const HomePage(); // already signed in
    } else {
      return const SignInPage(); // not signed in
    }
  }
}