import 'package:flutter/widgets.dart';

Widget renderGoogleWebButton({
  required String clientId,
  required ValueChanged<String> onIdToken,
  required ValueChanged<Object> onError,
  double minimumWidth = 320,
}) {
  throw StateError('Google web button is only available on Flutter Web.');
}
