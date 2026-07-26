import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestPage(),
    ),
  );
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  Future<void> testGoogleAds(BuildContext context) async {
    await MobileAds.instance.initialize();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Google Ads Initialized"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => testGoogleAds(context),
          child: const Text("Test Google Ads"),
        ),
      ),
    );
  }
}