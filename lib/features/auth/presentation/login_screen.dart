// lib/features/auth/screens/login_screen.dart
import 'package:broomie/core/providers/auth_provider.dart';
import 'package:broomie/features/auth/presentation/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  String? verificationId;
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    final authCtrl = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ---------- GOOGLE SIGN-IN ----------
            ElevatedButton.icon(
              onPressed: () async {
                await authCtrl.signInWithGoogle();
              },
              icon: const Icon(Icons.g_mobiledata),
              label: const Text("Sign in with Google", style: TextStyle(color: Colors.white)),
            ),

            const Divider(height: 40),

            /// ---------- EMAIL & PASSWORD ----------
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(authRepositoryProvider)
                      .signInWithEmail(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                }
              },
              child: const Text("Login with Email", style: TextStyle(color: Colors.white),),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),

            const Divider(height: 40),

            /// ---------- PHONE AUTH ----------
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "+91 8123456789",
              ),
            ),
            const SizedBox(height: 10),
            if (codeSent)
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(authRepositoryProvider);
                if (!codeSent) {
                  await repo.verifyPhoneNumber(
                    phoneNumber: phoneController.text.trim(),
                    onCodeSent: (vId) {
                      setState(() {
                        verificationId = vId;
                        codeSent = true;
                      });
                    },
                    onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? "Error")),
                    ),
                    onAutoVerify: (cred) async {
                      await FirebaseAuth.instance.signInWithCredential(cred);
                    },
                  );
                } else {
                  await repo.verifyOtp(
                    verificationId: verificationId!,
                    otp: otpController.text.trim(),
                  );
                }
              },
              child: Text(codeSent ? "Verify OTP" : "Send OTP", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
