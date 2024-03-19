import 'dart:typed_data';

class AuthData {
  final Uint8List authData;

  AuthData({required this.authData});

  String toHexString() =>
      authData.map((byte) => _byteHexString(byte)).join(' ');

  @override
  String toString() => authData.map((byte) => _byteHexString(byte)).join(' ');

  String _byteHexString(int byte) =>
      '0x${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}
