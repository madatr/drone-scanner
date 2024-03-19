import 'dart:typed_data';

typedef FieldDecoder<T> = T? Function(ByteData);

T? decodeField<T>(
  FieldDecoder<T> decoder,
  Uint8List messageData,
  int from,
  int to,
) {
  return decoder(ByteData.sublistView(messageData, from, to));
}
