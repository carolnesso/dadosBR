# DadosBR

Projeto Flutter para o case DadosBR usando exclusivamente a BrasilAPI.

## Como rodar

1. `flutter pub get`
2. `flutter run`

## Como gerar APK

1. `flutter build apk --release`
2. APK gerado em `build/app/outputs/flutter-apk/app-release.apk`

## Estrutura tecnica

- `lib/core`: cliente HTTP, tratamento de erros e tema
- `lib/features/cep`: consulta de CEP (BrasilAPI CEP v2)
- `lib/features/cnpj`: consulta de CNPJ
- `lib/features/registro_br`: consulta de dominio Registro.br
- `lib/features/search`: tela reutilizavel de busca/resultado
- `lib/features/home`: menu inicial

## Decisoes tecnicas

- Arquitetura em camadas (data/domain/presentation) por feature
- `http` com timeout e mensagens amigaveis por tipo de erro
- Validacao de entrada por consulta (CEP, CNPJ, dominio)
- Estados de loading, erro, vazio e sucesso
- Acoes de salvar/compartilhar habilitadas somente apos busca
