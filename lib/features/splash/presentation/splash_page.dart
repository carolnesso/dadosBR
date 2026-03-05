import 'package:flutter/material.dart';

import '../../../app/router.dart';

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
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 243,
          height: 31,
          child: Image(
            image: AssetImage('assets/logo/EliteLogorbrancaPorExtenso.png'),
          ),
        ),
      ),
    );
  }
}
