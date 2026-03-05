import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/search_contract.dart';
import 'input_formatters.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.handler});

  final SearchHandler handler;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  SearchResultData? _result;
  bool _isLoading = false;

  bool get _hasResult => _result != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    final rawInput = _controller.text;
    final normalized = widget.handler.normalize(rawInput);
    final validationError = widget.handler.validate(rawInput, normalized);

    if (validationError != null) {
      _showSnack(validationError.message, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.handler.fetch(normalized);
      if (!mounted) return;
      setState(() => _result = result);
      _showSnack('Consulta realizada com sucesso.');
    } on AppFailure catch (failure) {
      _showSnack(failure.message, isError: true);
    } catch (_) {
      _showSnack('Erro inesperado. Tente novamente.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSave() async {
    if (!_hasResult) {
      _showSnack('Realize uma busca primeiro.', isError: true);
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/${widget.handler.id}_$now.txt');
      await file.writeAsString(_result!.shareText);
      _showSnack('Arquivo salvo em ${file.path}');
    } catch (_) {
      _showSnack('Nao foi possivel salvar o arquivo.', isError: true);
    }
  }

  Future<void> _onShare() async {
    if (!_hasResult) {
      _showSnack('Realize uma busca primeiro.', isError: true);
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: _result!.title,
          subject: _result!.title,
          text: _result!.shareText,
        ),
      );
    } catch (_) {
      _showSnack('Nao foi possivel compartilhar o resultado.', isError: true);
    }
  }

  TextInputType _keyboardType() {
    switch (widget.handler.inputKind) {
      case SearchInputKind.cep:
      case SearchInputKind.cnpj:
        return TextInputType.number;
      case SearchInputKind.domain:
      case SearchInputKind.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _inputFormatters() {
    switch (widget.handler.inputKind) {
      case SearchInputKind.cep:
        return [DigitMaskInputFormatter(mask: '#####-###', maxDigits: 8)];
      case SearchInputKind.cnpj:
        return [DigitMaskInputFormatter(mask: '##.###.###/####-##', maxDigits: 14)];
      case SearchInputKind.domain:
        return [LowerCaseDomainInputFormatter()];
      case SearchInputKind.text:
        return const [];
    }
  }

  int? _maxLength() {
    switch (widget.handler.inputKind) {
      case SearchInputKind.cep:
        return 9;
      case SearchInputKind.cnpj:
        return 18;
      case SearchInputKind.domain:
        return 253;
      case SearchInputKind.text:
        return null;
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFFFEABAB) : const Color(0xFF9EFF8B),
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.handler.title,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                Text(
                  widget.handler.description,
                  style: const TextStyle(color: AppColors.muted, fontSize: 15),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  keyboardType: _keyboardType(),
                  inputFormatters: _inputFormatters(),
                  maxLength: _maxLength(),
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _onSearch();
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: widget.handler.hint,
                    hintStyle: const TextStyle(color: AppColors.muted),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _onSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Resultado',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: _hasResult ? 240 : 62),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _onSave,
                            icon: Icon(
                              Icons.download_outlined,
                              color: _hasResult ? AppColors.accent : AppColors.muted,
                            ),
                          ),
                          IconButton(
                            onPressed: _onShare,
                            icon: Icon(
                              Icons.share_outlined,
                              color: _hasResult ? AppColors.accent : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      if (!_hasResult)
                        const Text(
                          'Os dados da pesquisa aparecerão aqui.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      else
                        _ResultContent(data: _result!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.data});

  final SearchResultData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.imageAssetPath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              data.imageAssetPath!,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 88,
                  color: const Color(0xFF2A2A2A),
                  alignment: Alignment.center,
                  child: const Text(
                    'Bandeira indisponivel',
                    style: TextStyle(color: AppColors.muted),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        for (final field in data.fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${field.label}: ',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: field.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
