import 'package:broomie/core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _codeSent = false;

Future<void> _sendCode() async {
  await ref.read(authRepositoryProvider).verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        onCodeSent: (id) => setState(() {
          _verificationId = id;
          _codeSent = true;
        }),
        onError: (e) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Error'))),
        onAutoVerify: (cred) async {
          await FirebaseAuth.instance.signInWithCredential(cred);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone login successful')),
          );
        },
      );
}

Future<void> _verifyCode() async {
  await ref.read(authRepositoryProvider).verifyOtp(
        verificationId: _verificationId,
        otp: _otpController.text.trim(),
      );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Phone login successful')),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number (+91...)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _sendCode, child: const Text('Send OTP')),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _verifyCode, child: const Text('Verify OTP')),
            ]
          ],
        ),
      ),
    );
  }
}
