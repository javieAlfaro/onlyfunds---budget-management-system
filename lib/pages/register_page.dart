import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyfunds_v1/auth_service.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';
import 'package:onlyfunds_v1/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCred = await authService.value.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      await UserService().createUserRecord(
        uid: userCred.user!.uid,
        username: userNameController.text.trim(),
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // void register() async {
  //   try {
  //     await authService.value.createAccount(email: emailController.text, password: passwordController.text);
  //     popPage();
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       errorMessage = e.message ?? 'There is an error';
  //     });
  //   }
  // }

  // void popPage() {
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                hintText: "Username",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage, style: TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            Button(
              text: isLoading ? "Loading..." : "Sign Up",
              onPressed: isLoading ? null : _signUp,
              width: 250,
            ),
            TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: const Text(
              "Already have an account? Sign In",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
