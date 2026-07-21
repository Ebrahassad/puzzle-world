import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              '🧩 Puzzle World',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // لاحقاً نفتح صفحة التصنيفات
              },
              child: const Text(
                'ابدأ اللعب',
                style: TextStyle(fontSize: 20),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
