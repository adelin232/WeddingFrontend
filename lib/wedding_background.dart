import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nunta_aa/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nunta A&A',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Nunta A&A'),
    );
  }
}

class WeddingBackground extends StatelessWidget {
  final Widget child;
  const WeddingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
            kIsWeb
              ? (() {
                const bgWeb = String.fromEnvironment('BACKGROUND_WEB');
                debugPrint('BACKGROUND_WEB: $bgWeb');
                return bgWeb;
              })()
              : (() {
                const bg = String.fromEnvironment('BACKGROUND');
                debugPrint('BACKGROUND: $bg');
                return bg;
              })(),
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withOpacity(0.2), // overlay pentru lizibilitate
        ),
        child,
      ],
    );
  }
}
