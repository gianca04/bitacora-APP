import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AppShell provides the app bar and drawer. Here we return the page
    // content only so it renders inside the shared shell.
    return const Center(child: Text('About Page'));
  }
}
