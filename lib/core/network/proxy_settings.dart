import 'dart:convert';
import 'dart:io';

/// Safe, stable error codes only; never includes connection or credential data.
class ProxySettingsException implements IOException {
  const ProxySettingsException(this.code);
  final String code;
  @override
  String toString() => 'ProxySettingsException($code)';
}

enum ProxyProtocol { http, https, socks5 }

class ProxySettings {
  const ProxySettings({
    this.enabled = false,
    this.protocol = ProxyProtocol.http,
    this.host = '',
    this.port = 8080,
    this.username = '',
    this.password = '',
  });

  final bool enabled;
  final ProxyProtocol protocol;
  final String host;
  final int port;
  final String username;
  final String password;

  void validate() {
    if (!enabled) return;
    final ip = InternetAddress.tryParse(host);
    final domain = RegExp(
      r'^(?=.{1,253}$)[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.?$',
    );
    if (host.isEmpty || (ip == null && !domain.hasMatch(host))) {
      throw const ProxySettingsException('invalid_host');
    }
    if (port < 1 || port > 65535) {
      throw const ProxySettingsException('invalid_port');
    }
    final userBytes = utf8.encode(username);
    final passwordBytes = utf8.encode(password);
    if ((username.isEmpty && password.isNotEmpty) ||
        (protocol != ProxyProtocol.socks5 && username.contains(':')) ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(username) ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(password) ||
        (protocol == ProxyProtocol.socks5 &&
            username.isNotEmpty &&
            (userBytes.length > 255 ||
                passwordBytes.isEmpty ||
                passwordBytes.length > 255))) {
      throw const ProxySettingsException('invalid_credentials');
    }
  }

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'protocol': protocol.name,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  factory ProxySettings.fromJson(Map<String, dynamic> json) {
    final settings = ProxySettings(
      enabled: json['enabled'] as bool,
      protocol: ProxyProtocol.values.byName(json['protocol'] as String),
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
    );
    settings.validate();
    return settings;
  }
}
