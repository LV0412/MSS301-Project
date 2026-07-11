import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  String get webClientId => AppConfig.googleWebClientId.trim();

  String get serverClientId => AppConfig.googleServerClientId.trim();

  Stream<String> get idTokenEvents => authenticationEvents
      .where((event) => event is GoogleSignInAuthenticationEventSignIn)
      .map(
        (event) =>
            readIdToken((event as GoogleSignInAuthenticationEventSignIn).user),
      );

  Future<void> initialize() {
    if (kIsWeb && webClientId.isEmpty) {
      throw const ApiException(
        message: 'Missing GOOGLE_CLIENT_ID for Google Sign-In.',
      );
    }
    if (!kIsWeb && serverClientId.isEmpty) {
      throw const ApiException(
        message: 'Missing GOOGLE_SERVER_CLIENT_ID for Google Sign-In.',
      );
    }

    return _initializeFuture ??= _googleSignIn.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : serverClientId,
    );
  }

  Future<String> authenticateAndReadIdToken() async {
    await initialize();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const ApiException(
        message: 'Google Sign-In on Web must use the Google-rendered button.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate();
      return readIdToken(account);
    } on GoogleSignInException catch (error) {
      throw ApiException(message: _messageFromGoogleError(error));
    }
  }

  String readIdToken(GoogleSignInAccount account) {
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException(
        message: 'Google did not return an ID token. Check OAuth client ID.',
      );
    }
    return idToken;
  }

  String _messageFromGoogleError(GoogleSignInException error) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Google sign-in was canceled.',
      _ => error.description ?? 'Could not sign in with Google.',
    };
  }

  String messageFromError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is GoogleSignInException) {
      return _messageFromGoogleError(error);
    }
    return 'Could not sign in with Google.';
  }
}
