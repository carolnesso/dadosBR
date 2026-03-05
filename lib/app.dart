import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';

class DadosBrApp extends StatelessWidget {
  const DadosBrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DadosBR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
