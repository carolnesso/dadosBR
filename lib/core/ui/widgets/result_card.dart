import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.isLoading,
    required this.fields,
    required this.errorMessage,
    required this.imageAssetPath,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
  });

  final bool isLoading;
  final Map<String, String>? fields;
  final String? errorMessage;
  final String? imageAssetPath;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  bool get _hasResult => fields != null && fields!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final iconColor = _hasResult ? AppColors.accent : AppColors.muted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: _hasResult ? 240 : 86),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1F1F23), Color(0xFF17171A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onDownload,
                icon: Icon(Icons.download_outlined, color: iconColor),
              ),
              IconButton(
                onPressed: onShare,
                icon: Icon(Icons.share_outlined, color: iconColor),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: iconColor),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (errorMessage != null && !_hasResult)
            Text(errorMessage!, style: AppTextStyles.description)
          else if (!_hasResult)
            const Text('\n Os dados da pesquisa aparecerão aqui.', style: AppTextStyles.description)
          else ...[
            if (imageAssetPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.asset(
                  imageAssetPath!,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 88,
                    color: const Color(0xFF2A2A2A),
                    alignment: Alignment.center,
                    child: const Text('Bandeira indisponivel', style: AppTextStyles.description),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            for (final entry in fields!.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: AppTextStyles.resultLabel,
                      ),
                      TextSpan(
                        text: entry.value,
                        style: AppTextStyles.resultValue,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
