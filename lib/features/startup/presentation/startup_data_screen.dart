import 'package:flutter/material.dart';
import 'package:yam/app/onboarding_access.dart';
import 'package:yam/core/ui/feedback/yam_feedback_state.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class StartupDataScreen extends StatelessWidget {
  const StartupDataScreen({
    required this.access,
    required this.onRetry,
    super.key,
  });

  final OnboardingAccess access;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: access == OnboardingAccess.failure
            ? YamFeedbackState(
                icon: Icons.storage_rounded,
                title: l10n.startupDataErrorTitle,
                message: l10n.startupDataErrorMessage,
                actionKey: const ValueKey('startup-data-retry'),
                actionLabel: l10n.actionRetry,
                onAction: onRetry,
                error: true,
              )
            : Center(
                child: Semantics(
                  label: l10n.startupDataLoading,
                  child: const CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}
