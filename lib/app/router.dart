import 'package:flutter/material.dart';

import '../features/cep/presentation/cep_query_config.dart';
import '../features/cnpj/presentation/cnpj_query_config.dart';
import '../features/dominio/presentation/dominio_query_config.dart';
import '../features/home/presentation/home_page.dart';
import '../features/query/presentation/query_page.dart';
import '../features/splash/presentation/splash_page.dart';

class AppRouter {
  static const splash = '/splash';
  static const home = '/';
  static const cep = '/cep';
  static const cnpj = '/cnpj';
  static const dominio = '/dominio';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(builder: (_) => const SplashPage());
      case home:
        return MaterialPageRoute<void>(builder: (_) => const HomePage());
      case cep:
        return MaterialPageRoute<void>(
          builder: (_) => QueryPage(config: CepQueryConfig.config),
        );
      case cnpj:
        return MaterialPageRoute<void>(
          builder: (_) => QueryPage(config: CnpjQueryConfig.config),
        );
      case dominio:
        return MaterialPageRoute<void>(
          builder: (_) => QueryPage(config: DominioQueryConfig.config),
        );
      default:
        return MaterialPageRoute<void>(builder: (_) => const HomePage());
    }
  }
}
