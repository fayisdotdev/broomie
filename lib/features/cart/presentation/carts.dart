import 'package:flutter/material.dart';

class CartsScreen extends StatelessWidget {
  const CartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My carts')),
      body: const Center(child: Text('Carts Page')),
    );
  }
}
