import 'package:flutter/material.dart';

import 'features/home/presentation/home_page.dart';

class DadosBrApp extends StatelessWidget {
  const DadosBrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DadosBR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const accent = Color(0xFFD89A40);
  static const card = Color(0xFF1C1C1E);
  static const muted = Color(0xFF9A9A9A);
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 243,
              height: 31,
              child: Image(
                image: AssetImage('assets/logo/EliteLogorbrancaPorExtenso.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
