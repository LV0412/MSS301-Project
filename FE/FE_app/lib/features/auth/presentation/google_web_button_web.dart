import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_identity_services_web/id.dart' as gis;
import 'package:google_identity_services_web/loader.dart' as gis_loader;
import 'package:web/web.dart' as web;

Widget renderGoogleWebButton({
  required String clientId,
  required ValueChanged<String> onIdToken,
  required ValueChanged<Object> onError,
  double minimumWidth = 320,
}) {
  return _GoogleIdentityButton(
    clientId: clientId,
    minimumWidth: minimumWidth,
    onIdToken: onIdToken,
    onError: onError,
  );
}

class _GoogleIdentityButton extends StatefulWidget {
  const _GoogleIdentityButton({
    required this.clientId,
    required this.minimumWidth,
    required this.onIdToken,
    required this.onError,
  });

  final String clientId;
  final double minimumWidth;
  final ValueChanged<String> onIdToken;
  final ValueChanged<Object> onError;

  @override
  State<_GoogleIdentityButton> createState() => _GoogleIdentityButtonState();
}

class _GoogleIdentityButtonState extends State<_GoogleIdentityButton> {
  static Future<void>? _loadSdkFuture;
  web.HTMLElement? _buttonHost;

  @override
  void initState() {
    super.initState();
    _loadSdkFuture ??= gis_loader.loadWebSdk();
  }

  Future<void> _renderButton(web.HTMLElement host) async {
    try {
      await _loadSdkFuture;
      if (!mounted) return;

      host.textContent = '';
      gis.id.initialize(
        gis.IdConfiguration(
          client_id: widget.clientId,
          callback: (gis.CredentialResponse response) {
            final idToken = response.credential;
            if (idToken == null || idToken.isEmpty) {
              widget.onError(StateError('Google did not return an ID token.'));
              return;
            }
            widget.onIdToken(idToken);
          },
        ),
      );
      gis.id.renderButton(
        host,
        gis.GsiButtonConfiguration(
          type: gis.ButtonType.standard,
          theme: gis.ButtonTheme.outline,
          size: gis.ButtonSize.large,
          text: gis.ButtonText.continue_with,
          shape: gis.ButtonShape.rectangular,
          logo_alignment: gis.ButtonLogoAlignment.left,
          width: widget.minimumWidth,
        ),
      );
    } catch (error) {
      widget.onError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'div',
      isVisible: true,
      onElementCreated: (Object element) {
        final host = element as web.HTMLElement;
        host.style
          ..setProperty('display', 'flex')
          ..setProperty('justify-content', 'center')
          ..setProperty('align-items', 'center')
          ..setProperty('width', '100%');
        _buttonHost = host;
        unawaited(_renderButton(host));
      },
    );
  }

  @override
  void didUpdateWidget(covariant _GoogleIdentityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final host = _buttonHost;
    if (host != null && oldWidget.clientId != widget.clientId) {
      unawaited(_renderButton(host));
    }
  }
}
