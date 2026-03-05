import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../cep/data/cep_search_handler.dart';
import '../../cnpj/data/cnpj_search_handler.dart';
import '../../registro_br/data/registro_br_search_handler.dart';
import '../../search/domain/search_contract.dart';
import '../../search/presentation/search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<SearchHandler> _handlers = [
    CepSearchHandler(),
    CnpjSearchHandler(),
    RegistroBrSearchHandler(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'O que deseja procurar hoje?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 28),
                  for (final handler in _handlers) ...[
                    _MenuButton(
                      label: handler.buttonLabel,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SearchPage(handler: handler),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
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

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
