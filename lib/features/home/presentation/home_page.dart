import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/ui/widgets/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _menuItems = [
    _HomeMenuItem(label: 'CEP', route: AppRouter.cep),
    _HomeMenuItem(label: 'CNPJ', route: AppRouter.cnpj),
    _HomeMenuItem(label: 'REGISTRO.BR', route: AppRouter.dominio),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 206,
                    height: 79,
                    child: Image.asset('assets/logo/EliteLogorbranca.png'),
                  ),
                  const SizedBox(height: 130),
                  const Text(
                    'Realize consultas publicas de maneira rapida e pratica!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  const Text(
                    'O que deseja procurar hoje?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  for (final item in _menuItems) ...[
                    PrimaryButton(
                      label: item.label,
                      onPressed: () => Navigator.of(context).pushNamed(item.route),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMenuItem {
  const _HomeMenuItem({required this.label, required this.route});

  final String label;
  final String route;
}
