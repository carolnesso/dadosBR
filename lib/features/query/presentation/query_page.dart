import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/network/api_client.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/result_card.dart';
import '../../../core/ui/widgets/snackbars.dart';
import '../domain/query_config.dart';
import '../domain/query_state.dart';
import 'query_controller.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({
    super.key,
    required this.config,
    this.client,
  });

  final QueryConfig config;
  final ApiClient? client;

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  final TextEditingController _textController = TextEditingController();
  late final QueryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QueryController(config: widget.config, client: widget.client)
      ..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onSearch() async {
    final message = await _controller.search(_textController.text);
    if (!mounted || message == null) return;
    AppSnackbars.error(context, message);
  }

  Future<void> _onDownload() async {
    final result = _controller.state.result;
    if (result == null) {
      AppSnackbars.error(context, 'Realize uma busca primeiro.');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/${widget.config.id}_$now.txt');
      await file.writeAsString(result.shareText);
      if (!mounted) return;
      AppSnackbars.success(context, 'Arquivo salvo em ${file.path}');
    } catch (_) {
      if (!mounted) return;
      AppSnackbars.error(context, 'Nao foi possivel salvar o arquivo.');
    }
  }

  Future<void> _onShare() async {
    final result = _controller.state.result;
    if (result == null) {
      AppSnackbars.error(context, 'Realize uma busca primeiro.');
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: result.title,
          subject: result.title,
          text: result.shareText,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbars.error(context, 'Nao foi possivel compartilhar o resultado.');
    }
  }

  void _onDelete() {
    if (!_controller.state.hasResult) {
      AppSnackbars.error(context, 'Nao ha resultado para limpar.');
      return;
    }

    _controller.clearResult();
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(81),
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 81,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left_rounded, size: 40),
                  color: AppColors.textPrimary,
                ),
                const Spacer(),
                SizedBox(
                  width: 90,
                  child: Image.asset('assets/logo/EliteLogorbranca.png'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s40),
                  Text(widget.config.title, style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.s16),
                  Text(widget.config.description, style: AppTextStyles.description),
                  const SizedBox(height: 120),
                  AppTextField(
                    hint: widget.config.hint,
                    controller: _textController,
                    keyboardType: widget.config.keyboardType,
                    inputFormatters: widget.config.inputFormatters,
                    maxLength: widget.config.maxLength,
                    onSubmitted: (_) => _onSearch(),
                  ),
                  const SizedBox(height: AppSpacing.s40),
                  PrimaryButton(
                    label: widget.config.buttonLabel,
                    isLoading: state.status == QueryStatus.loading,
                    onPressed: _onSearch,
                  ),
                  const SizedBox(height: 72),
                  const Text('Resultado', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.s12),
                  ResultCard(
                    isLoading: state.status == QueryStatus.loading,
                    fields: state.result?.fields,
                    errorMessage: state.errorMessage,
                    imageAssetPath: state.result?.imageAssetPath,
                    onDownload: _onDownload,
                    onShare: _onShare,
                    onDelete: _onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
