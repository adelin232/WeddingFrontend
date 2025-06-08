import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nunta_aa/upload_page.dart';
import 'package:nunta_aa/wedding_background.dart';

void main() {
  runApp(const MyApp());
}

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _goToUploadPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadPage()),
    );
  }

  late Duration _timeLeft;
  late final DateTime _weddingDate;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _weddingDate = DateTime(2026, 8, 29, 0, 0, 0);
    _timeLeft = _weddingDate.difference(DateTime.now());
    _ticker = Ticker(_updateCountdown)..start();
  }

  void _updateCountdown(Duration _) {
    final now = DateTime.now();
    setState(() {
      _timeLeft = _weddingDate.difference(now);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '$days zile, $hours ore, $minutes min, $seconds sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: WeddingBackground(
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _goToUploadPage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Încarcă fotografii'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Până la nuntă au mai rămas:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _formatDuration(_timeLeft),
                      key: ValueKey(_timeLeft.inSeconds),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
