# DadosBR

Aplicativo Flutter para consultas públicas brasileiras, com foco em uma experiência simples, resiliente e pronta para demonstração.

## Objetivo do projeto

Entregar um app Android (com suporte multiplataforma via Flutter) para consultar:

- CEP
- CNPJ
- Domínio `.br` (Registro.br)

com:

- validação de entrada
- tratamento consistente de erros
- feedback visual de carregamento/sucesso/erro
- resultado organizado em card
- exportação e compartilhamento em PDF

## Stack e dependências

- Flutter + Dart (`>=3.6.0 <4.0.0`)
- `http`: requisições REST para APIs públicas
- `path_provider`: definição de pastas seguras para salvar arquivos
- `pdf`: geração de PDF local com o resultado da consulta
- `share_plus`: compartilhamento de PDF pelo sistema operacional
- `google_fonts`: padronização tipográfica (Montserrat)

### Por que esse conjunto

- `http` foi suficiente para o escopo (GET + timeout + parse), mantendo o projeto leve.
- `pdf` + `share_plus` atendem ao requisito funcional de gerar valor após a consulta, sem backend próprio.
- `path_provider` evita paths hardcoded e funciona de forma segura em cada plataforma.
- `google_fonts` facilita a consistência visual sem acoplar assets de fonte ao repositório.

## Arquitetura e organização

### Estrutura principal

```text
lib/
  app/                  # bootstrap visual, tema e rotas
  core/                 # infraestrutura compartilhada (network, errors, UI base)
  features/
    splash/             # tela de abertura
    home/               # menu inicial
    query/              # motor genérico de consulta/requisição/estado
    cep/                # regras e parse da consulta de CEP
    cnpj/               # regras e parse da consulta de CNPJ
    dominio/            # regras e parse da consulta de domínio .br
    registro_br/        # DTO do retorno de domínio
````

### Decisão central: motor genérico de consulta

O projeto foi desenhado para evitar três telas duplicadas, com lógica repetida.
Para isso, existe uma feature `query` com componentes reutilizáveis:

* `QueryConfig`: contrato de cada tipo de consulta
* `QueryController`: ciclo de vida da consulta (validar -> carregar -> mapear -> erro/sucesso)
* `QueryState`: estados da tela (`idle`, `loading`, `success`, `error`)
* `QueryPage`: UI única para entrada + resultado

Cada feature (`cep`, `cnpj`, `dominio`) injeta apenas sua configuração específica.

#### Por que esse desenho

* reduz duplicação de código
* acelera a manutenção
* facilita adicionar nova consulta no futuro sem reescrever o fluxo base
* melhora a testabilidade (regras de cada consulta ficam isoladas)

## Fluxo da aplicação

1. O app inicia em `SplashPage` (`/splash`).
2. Após 2 segundos, navega para `HomePage` (`/`).
3. O usuário escolhe CEP, CNPJ ou Domínio.
4. A rota abre `QueryPage(config: ...)` com a configuração da feature.
5. O controller executa validação local antes de chamar a API.
6. O resultado aparece no card com ações de baixar/compartilhar/limpar.

## Regras de negócio por consulta

### CEP

* Máscara: `#####-###`
* Normalização: remove caracteres não numéricos
* Validação: campo vazio, caracteres inválidos, tamanho diferente de 8
* Endpoint principal: `https://brasilapi.com.br/api/cep/v2/{cep}`
* Fallback de resiliência: `https://viacep.com.br/ws/{cep}/json/` quando houver timeout/erro de servidor no endpoint principal
* Resultado inclui bandeira por UF via `assets/flags/{UF}.png`

### Por que existe fallback no CEP

CEP costuma ser a consulta de maior volume e a mais sensível à indisponibilidade momentânea.
O fallback foi adicionado para melhorar a confiabilidade percebida pelo usuário final e reduzir falhas em demonstração, mantendo a BrasilAPI como fonte principal.

### CNPJ

* Máscara: `##.###.###/####-##`
* Normalização: remove caracteres não numéricos
* Validação: vazio, caracteres inválidos, tamanho e dígitos verificadores do CNPJ
* Endpoint: `https://brasilapi.com.br/api/cnpj/v1/{cnpj}`
* Resultado mostra razão social, nome fantasia, capital, natureza jurídica, CNAE principal e secundários, endereço montado

### Domínio (Registro.br)

* Entrada forçada para minúsculas
* Validação: sem espaços, sufixo `.br`, tamanho máximo, caracteres permitidos e estrutura de labels
* Endpoint: `https://brasilapi.com.br/api/registrobr/v1/{dominio}`
* Resultado: domínio, status, hosts DNS, status de publicação e expiração

## Tratamento de erro e resiliência

### Camada de rede (`ApiClient`)

* timeout configurado (12s)
* mapeamento de falhas por tipo:

  * timeout
  * sem internet/network
  * 400/422 (entrada inválida)
  * 404 (não encontrado)
  * 429 (rate limit)
  * 5xx (indisponibilidade)
  * parse inválido
* mensagens amigáveis para cada cenário
* logs detalhados em `kDebugMode`

### Camada de apresentação

* loading com `CircularProgressIndicator`
* feedback com `SnackBar` de sucesso/erro
* card de resultado com estado vazio, erro e sucesso
* ações de download/compartilhar protegidas (exigem resultado)

## UI e design system local

O projeto centraliza estilo em:

* `app/theme/app_colors.dart`
* `app/theme/app_text_styles.dart`
* `app/theme/app_spacing.dart`
* `app/theme/app_theme.dart`

### Por que centralizar tema

* evita valores soltos de cor/tamanho em várias telas
* garante consistência visual
* reduz custo de ajuste visual futuro

## Widgets reutilizáveis

* `PrimaryButton`: botão padrão com loading
* `AppTextField`: campo com formatadores e limpeza rápida
* `ResultCard`: card único para exibir qualquer resultado de consulta
* `AppSnackbars`: padrão de feedback visual

### Motivo da reutilização

Padroniza o comportamento da UI e evita divergências de experiência entre as telas de CEP/CNPJ/Domínio.

## Exportação e compartilhamento de resultado

Na `QueryPage`, após consulta bem-sucedida:

* gera PDF com timestamp e campos consultados
* salva em pasta de documentos (`path_provider`)
* compartilha arquivo temporário via `share_plus`

### Por que PDF

PDF é um formato universal para encaminhar comprovações/consultas por WhatsApp, e-mail ou armazenamento local, sem depender de backend.

## Testes

O projeto possui testes automatizados para as regras principais:

* `test/features/cep/cep_query_config_test.dart`
* `test/features/cnpj/cnpj_query_config_test.dart`
* `test/features/dominio/dominio_query_config_test.dart`
* `test/widget_test.dart`

A cobertura atual foca em:

* normalização e validação de entrada
* mapeamento de DTO para resultado exibido
* fluxo do `QueryController`
* fallback de CEP
* navegação inicial splash -> home

## Como executar localmente

### Pré-requisitos

* Flutter SDK instalado
* Android SDK configurado
* dispositivo físico ou emulador

### Passos

```bash
flutter pub get
flutter run
```

## Como rodar os testes

```bash
flutter test
```

## Como gerar APK de entrega

```bash
flutter build apk --release
```

APK gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Checklist de entrega (case)

* APK release gerado
* código-fonte completo
* `README.md` com execução, build e decisões técnicas

## Possíveis evoluções (pós-entrega)

* cache local das últimas consultas
* internacionalização das mensagens
* testes de widget para estados de erro/sucesso do `ResultCard`
* ajuste de observabilidade (analytics/log remoto)

