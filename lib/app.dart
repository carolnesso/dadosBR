import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';

class DadosBrApp extends StatelessWidget {
  const DadosBrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DadosBR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashPage(),
    );
  }
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
