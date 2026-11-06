import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/features/assistant/presentation/assistant_failure_text.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

/// Presentation only: Markdown never fetches images or launches arbitrary URIs.
class AssistantMarkdown extends StatelessWidget {
  const AssistantMarkdown({required this.text, super.key});

  final String text;

  Future<void> _openLink(BuildContext context, String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return;
    }
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Show the same localized network failure as other assistant UI actions.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          assistantFailureText(AppLocalizations.of(context), 'network'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final body = AppTypography.productTitle.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
    final heading = AppTypography.sectionTitle.copyWith(
      color: colors.onSurface,
    );
    return MarkdownBody(
      data: text,
      selectable: true,
      fitContent: false,
      onTapLink: (_, href, _) => unawaited(_openLink(context, href)),
      // Provider text is untrusted. Even remote image URLs must not cause I/O.
      imageBuilder: (_, _, alt) => Text(alt ?? '', style: body),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: body,
        h1: AppTypography.screenTitle.copyWith(color: colors.onSurface),
        h2: heading,
        h3: heading,
        h4: body.copyWith(fontWeight: FontWeight.w600),
        h5: body.copyWith(fontWeight: FontWeight.w600),
        h6: body.copyWith(fontWeight: FontWeight.w600),
        a: TextStyle(
          color: colors.primary,
          decoration: TextDecoration.underline,
        ),
        code: AppTypography.body.copyWith(
          color: colors.onSurface,
          fontFamily: 'monospace',
          backgroundColor: colors.surfaceContainer,
        ),
        blockSpacing: AppSpacing.sm,
        listIndent: AppSpacing.lg,
        listBullet: body,
        listBulletPadding: const EdgeInsets.only(right: AppSpacing.xs),
        blockquote: body.copyWith(color: colors.onSurfaceVariant),
        blockquotePadding: const EdgeInsets.all(AppSpacing.sm),
        blockquoteDecoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border(left: BorderSide(color: colors.primary, width: 2)),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        codeblockPadding: const EdgeInsets.all(AppSpacing.md),
        codeblockDecoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        tableHead: body.copyWith(fontWeight: FontWeight.w600),
        tableBody: body,
        tableHeadAlign: TextAlign.left,
        tableColumnWidth: const IntrinsicColumnWidth(),
        tableBorder: TableBorder.all(
          color: colors.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        tableHeadCellsDecoration: BoxDecoration(color: colors.surfaceContainer),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
      ),
    );
  }
}
