import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/network/proxy_settings.dart';
import 'package:yam/core/network/proxy_settings_controller.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_select_field.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class ProxySettingsScreen extends StatefulWidget {
  const ProxySettingsScreen({required this.controller, super.key});

  final ProxySettingsController controller;

  @override
  State<ProxySettingsScreen> createState() => _ProxySettingsScreenState();
}

class _ProxySettingsScreenState extends State<ProxySettingsScreen> {
  final _host = TextEditingController();
  final _port = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _enabled = false;
  ProxyProtocol _protocol = ProxyProtocol.http;
  bool _loading = true;
  bool _saved = false;
  String? _failure;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerChanged);
    unawaited(_initialize());
  }

  void _controllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initialize() async {
    String? failure;
    try {
      await widget.controller.initialize();
      failure = widget.controller.failureCode;
    } on ProxySettingsException catch (error) {
      failure = error.code;
    } catch (_) {
      failure = 'storage';
    }
    if (!mounted) return;
    final settings = widget.controller.settings;
    setState(() {
      _enabled = settings.enabled;
      _protocol = settings.protocol;
      _host.text = settings.host;
      _port.text = settings.port.toString();
      _username.text = settings.username;
      _password.text = settings.password;
      _failure = failure;
      _loading = false;
    });
  }

  void _edited() {
    setState(() {
      _failure = null;
      _saved = false;
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _failure = null;
      _saved = false;
    });
    final settings = ProxySettings(
      enabled: _enabled,
      protocol: _protocol,
      host: _host.text.trim(),
      port: int.tryParse(_port.text) ?? 0,
      username: _username.text,
      password: _password.text,
    );
    try {
      settings.validate();
      await widget.controller.save(settings);
      if (!mounted) return;
      setState(() {
        _failure = widget.controller.failureCode;
        _saved = _failure == null;
      });
    } on ProxySettingsException catch (error) {
      if (mounted) setState(() => _failure = error.code);
    } catch (_) {
      if (mounted) setState(() => _failure = 'storage');
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerChanged);
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final saving = widget.controller.saving;
    final helpStyle = AppTypography.label.copyWith(
      color: colors.onSurfaceVariant,
    );
    final failureText = switch (_failure) {
      'invalid_host' => l10n.proxyErrorHost,
      'invalid_port' => l10n.proxyErrorPort,
      'invalid_credentials' => l10n.proxyErrorCredentials,
      null => null,
      _ => l10n.proxyErrorStorage,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proxySettingsTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const ValueKey('proxy-settings-scroll-view'),
              padding: const EdgeInsets.all(AppSpacing.md),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(l10n.proxyScopeNote, style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                if (_loading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(l10n.proxyLoading, style: helpStyle),
                  ),
                ] else ...[
                  ExcludeFocus(
                    excluding: saving,
                    child: AbsorbPointer(
                      absorbing: saving,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          YamSelectField<bool>(
                            fieldKey: const ValueKey('proxy-enabled'),
                            label: l10n.proxyRouting,
                            value: _enabled,
                            items: [
                              YamDropdownOption(
                                value: false,
                                label: l10n.proxyDisabled,
                                key: const ValueKey('proxy-enabled-off'),
                              ),
                              YamDropdownOption(
                                value: true,
                                label: l10n.proxyEnabled,
                                key: const ValueKey('proxy-enabled-on'),
                              ),
                            ],
                            onChanged: (value) {
                              _enabled = value;
                              _edited();
                            },
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _enabled
                                ? l10n.proxyEnabledHelp
                                : l10n.proxyDisabledHelp,
                            style: helpStyle,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          YamSelectField<ProxyProtocol>(
                            fieldKey: const ValueKey('proxy-protocol'),
                            label: l10n.proxyProtocol,
                            value: _protocol,
                            items: [
                              YamDropdownOption(
                                value: ProxyProtocol.http,
                                label: l10n.proxyProtocolHttp,
                                key: const ValueKey('proxy-protocol-http'),
                              ),
                              YamDropdownOption(
                                value: ProxyProtocol.https,
                                label: l10n.proxyProtocolHttps,
                                key: const ValueKey('proxy-protocol-https'),
                              ),
                              YamDropdownOption(
                                value: ProxyProtocol.socks5,
                                label: l10n.proxyProtocolSocks5,
                                key: const ValueKey('proxy-protocol-socks5'),
                              ),
                            ],
                            onChanged: (value) {
                              _protocol = value;
                              _edited();
                            },
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.proxyProtocolHelp, style: helpStyle),
                          const SizedBox(height: AppSpacing.md),
                          YamTextField(
                            fieldKey: const ValueKey('proxy-host'),
                            label: l10n.proxyHost,
                            hintText: l10n.proxyHostHint,
                            controller: _host,
                            keyboardType: TextInputType.url,
                            errorText: _failure == 'invalid_host'
                                ? l10n.proxyErrorHost
                                : null,
                            onChanged: (_) => _edited(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          YamTextField(
                            fieldKey: const ValueKey('proxy-port'),
                            label: l10n.proxyPort,
                            controller: _port,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            errorText: _failure == 'invalid_port'
                                ? l10n.proxyErrorPort
                                : null,
                            onChanged: (_) => _edited(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.proxyAuthentication,
                            style: AppTypography.sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.proxyAuthenticationHelp, style: helpStyle),
                          const SizedBox(height: AppSpacing.md),
                          YamTextField(
                            fieldKey: const ValueKey('proxy-username'),
                            label: l10n.proxyUsername,
                            controller: _username,
                            keyboardType: TextInputType.visiblePassword,
                            errorText: _failure == 'invalid_credentials'
                                ? l10n.proxyErrorCredentials
                                : null,
                            onChanged: (_) => _edited(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          YamTextField(
                            fieldKey: const ValueKey('proxy-password'),
                            label: l10n.proxyPassword,
                            controller: _password,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            errorText: _failure == 'invalid_credentials'
                                ? l10n.proxyErrorCredentials
                                : null,
                            onChanged: (_) => _edited(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.proxyStorageNote, style: helpStyle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.proxyApplyNote, style: helpStyle),
                  if (failureText != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        failureText,
                        style: AppTypography.label.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                  if (_saved) ...[
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      liveRegion: true,
                      child: Text(l10n.proxySaved, style: AppTypography.body),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  YamPrimaryButton(
                    key: const ValueKey('proxy-save'),
                    label: saving ? l10n.proxySaving : l10n.proxySave,
                    loading: saving,
                    expanded: true,
                    onPressed: saving ? null : _save,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
