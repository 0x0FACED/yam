import 'package:yam/l10n/generated/app_localizations.dart';

String assistantFailureText(AppLocalizations l10n, String code) =>
    switch (code) {
      'network' || 'timeout' => l10n.assistantErrorNetwork,
      'auth' || 'permission' || 'not_connected' => l10n.assistantErrorAuth,
      'rate_limit' ||
      'usage_limit' ||
      'usage_unavailable' => l10n.assistantErrorLimit,
      'no_models' => l10n.assistantErrorModels,
      'incomplete' ||
      'interrupted' ||
      'protocol' => l10n.assistantErrorInterrupted,
      'cancelled' => l10n.assistantErrorCancelled,
      'storage' => l10n.assistantErrorStorage,
      'history_storage' => l10n.assistantHistoryStorageError,
      'revocation_unconfirmed' => l10n.assistantErrorRevocation,
      'speech_permission' ||
      'microphone_permission' ||
      'speech_permission_denied' => l10n.assistantErrorSpeechPermission,
      'speech_requires_api_key' || 'no_api_key' => l10n.assistantErrorSpeechKey,
      'speech_unavailable' ||
      'speech_failed' ||
      'speech_busy' ||
      'speech_no_text' ||
      'recording_failed' ||
      'audio_too_large' => l10n.assistantErrorSpeech,
      'image_too_large' ||
      'image_unsupported' ||
      'image_invalid' ||
      'invalid_image' => l10n.assistantErrorImage,
      'media_permission' ||
      'media_failed' ||
      'media_unavailable' ||
      'image_unavailable' ||
      'image_permission_denied' => l10n.assistantErrorMedia,
      'save_failed' ||
      'commit_failed' ||
      'invalid_draft' ||
      'invalid_arguments' ||
      'food_changed' ||
      'food_not_found' ||
      'stale_food' => l10n.assistantErrorSave,
      _ => l10n.assistantErrorGeneric,
    };
