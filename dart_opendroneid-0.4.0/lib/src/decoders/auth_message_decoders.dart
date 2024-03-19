import 'dart:typed_data';

import 'decoders.dart';
import '../types/auth_data.dart';

AuthData decodeAuthData(ByteData input) {
  final authData = decodeRaw(input);
  return AuthData(authData: authData);
}
